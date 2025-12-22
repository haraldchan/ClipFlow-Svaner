#Include ..\useSvaner.ahk

class debugger extends signal {
	notifyChange() {
		if (ARConfig.useDevtoolsUI) {
			; CALL_TREE.updateTimeStamp.set(A_Now . A_MSec)
			DebuggerList.getLatest()
		}
	}
}

class DebuggerList {
	static debuggers := signal([])

	/**
	 * Append debugger to DebuggerList.debuggers
	 * @param {debugger} debugger 
	 */
	static addDebugger(debugger) {
		listed := {
			signalName: debugger.value.signalName,
			signalType: debugger.value.signalType,
			value: (debugger.value.signalInstance.value is Object) 
				? JSON.stringify(debugger.value.signalInstance.value, 0, "") 
				: debugger.value.signalInstance.value,
			caller: ArrayExt.at(debugger.value.callerChain, -1)["callerName"],
			debugger: debugger
		}

		this.debuggers.set(ArrayExt.append([this.debuggers.value*], listed))
	}

	/**
	 * Retrieve latest debuggers
	 */
	static getLatest() {
		new := [this.debuggers.value*]

		for d in new {
			d.value := d.debugger.value.signalInstance.value is Object 
				? JSON.stringify(d.debugger.value.signalInstance.value, 0, "")
				: d.debugger.value.signalInstance.value
		}

		this.debuggers.set(new)
	}
}

class DebugUtils {
	static getCallerFromStack(stack) {
		l := ") : ["
		r := "]"

		callerName := pipe(
			s => StrSplit(s, l)[2],
			s => !StringExt.startsWith(s, "[") && StrSplit(s, r)[1],
			s => StrReplace(s, ".Prototype.__New", "")
		)(stack)

		callerFile := StrSplit(stack, ".ahk")[1] . ".ahk"

		return Map(
			"callerName", callerName,
			"callerFile", callerFile
		)
	}

	static getCallerChainAndFilename(callStacks, signalName) {
		callerChain := []

		startIndex := ArrayExt.findIndex(callStacks, item => InStr(item, "Object.Call"))
		endIndex := ArrayExt.findIndex(callStacks, item => !InStr(item, ") : ["))
		trimmedCallStacks := ArrayExt.slice(callStacks, startIndex + 1, endIndex)

		for stack in trimmedCallStacks {
			caller := DebugUtils.getCallerFromStack(stack)
			if (!caller["callerName"]) {
				continue
			}

			callerChain.InsertAt(1, caller)
		}

		fromFile := StrSplit(callStacks[startIndex], ".ahk")[1] . ".ahk"

		return [callerChain, fromFile]
	}

	/**
	 * Creates a debugger.
	 * @param {signal} signal
	 * @returns {debugger}
	 */
	static createDebugger(signal) {
		try {
			throw Error()
		} catch Error as err {
			stacks := StrSplit(err.Stack, "`r`n")
			
			signalName := signal.name
			signalType := match(stacks[2], Map(
				s => InStr(s, "[signal.Prototype.__New]"), "signal",
				s => InStr(s, "[computed.Prototype.__New]"), "computed",
			))

			cf := DebugUtils.getCallerChainAndFilename(stacks, signalName)
			callerChain := cf[1]
			fromFile := cf[2]

			debuggerObj := {
				signalInstance: signal,
				signalName: signalName,
				signalType: signalType,
				callerChain: callerChain,
				fromFile: fromFile,
			}

			return debugger(debuggerObj)
		}
	}
}