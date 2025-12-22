/**
 * @typedef {Object} ReplaceSleep
 * @property {() => 1 | 0} isReplace
 * @property {() => String} stepFiller
 */

/**
 * @typedef {Object} Props
 * @property {signal} recordedLog
 * @property {signal} isKeyRecording
 * @property {signal} loglinePrint
 * @property {ReplaceSleep} replaceSleep
 * @property {1 | 0} saveLog 
 */

/**
 * @param {Props} props 
 * @returns {InputHook} 
 */
KeyRecorder(props) {
    ih := InputHook("V")
    ih.KeyOpt("{All}", "N")
    ih.KeyOpt("{Esc}", "E")
    ih.Modifiers := ["LControl", "RControl", "LShift", "RShift", "LAlt", "RAlt"]
    
    ; custom properties
    ih.curLine := ""
    ih.strokeRecord := { key: "", state: "" }
    ih.ticker := 0
    ih.saveLog := props.saveLog
    ih.recordedLog := props.recordedLog
    ih.isKeyRecording := props.isKeyRecording
    ih.loglinePrint := props.loglinePrint

    ih.OnKeyDown := KeyRecorder_Logger.Bind(,,,"Down", props.replaceSleep)
    ih.OnKeyUp := KeyRecorder_Logger.Bind(,,,"Up", props.replaceSleep)
    ih.OnEnd := (ih) => ih.isKeyRecording.set(false)

    return ih
}

/**
 * 
 * @param {InputHook} ih 
 * @param {Number} vk 
 * @param {Number} sc 
 * @param {String} state 
 * @param {ReplaceSleep} replaceSleep 
 */
KeyRecorder_Logger(ih, vk, sc, state, replaceSleep) {
    keyName := GetKeyName(Format("vk{:x}sc{:x}", VK, SC))
    elapsed := ih.ticker ? A_TickCount - ih.ticker : 0 
    isModifier := ih.Modifiers.find(m => keyName == m)

    scriptLine := Format(
        "{3}Send `"{{1}{2}}`"", 
        keyName, 
        isModifier ? (" " . state) : "",
        match(replaceSleep.isReplace(), Map(
            replace => replace == true,
            replaceSleep.stepFiller() . "`r`n",
            replace => !replace && elapsed,  "Sleep " . elapsed . "`r`n",
            replace => !replace && !elapsed, ""
        ))
    )

    ; prevent recording same key on keep pushing down.
    if (ih.strokeRecord.key == keyName) {
        if (ih.strokeRecord.state == "Down" && state == "Up") {
            scriptLine := ""
        } 
        else if (ih.strokeRecord.state == state) {
            return
        }
    }

    strokeRecord := { 
        key: keyName, 
        state: state, 
        elapsed: elapsed , 
        script: scriptLine 
    }

    logLine := { vk: vk, sc: sc, keyName: keyName, updn: state, elapsed: elapsed . "ms" }
    newLogLines := [ih.loglinePrint.value*].unshift(logLine)
    if (newLogLines.Length > 3) {
        newLogLines.Pop()
    }
    ih.logLinePrint.set(newLogLines)

    ih.strokeRecord := strokeRecord
    ih.ticker := A_TickCount
    
    if (scriptLine) {
        ih.recordedLog.set(ih.recordedLog.value . "`r`n" . scriptLine)
    }

    if (ih.saveLog) {
        FileAppend(logLine, "./keylog.txt", "utf-8")
    }
}




