class computed extends signal {
    /**
     * @typedef {Object} ComputedOptions
     * @property {String} [name]
     * @property {true | false} [asMap=false]
     */
    /**
     * Create a computed signal which derives a reactive value.
     * ```
     * count := signal(2)
     * 
     * doubled := computed(count, c => c * 2) ; doubled.value : 4
     * ```
     * @param {signal | Array<signal>} depend The signal derives from.
     * @param {Func} mutation computation function expression.
     * @param {ComputedOptions} [options]
     * ```
     * doubled := computed(count, c => { doubled: c * 2 }, 
     *   {   
     *      name: "doubled",  ; named signals can be pick up by DevToolsUI
     *      asMap: true       ; converts object-type value to Map -> Map("num", 1)
     *   }
     * ) 
     * ```     * @return {computed}
     */
    __New(depend, mutation, options := { name: "", asMap: false }) {
        TypeChecker.checkType(depend, [signal, computed, Array], "First parameter is not a signal.")
        TypeChecker.checkType(mutation, Func, "Second parameter is not a Function.")

        ; options
        this.name := options.HasOwnProp("name") ? options.name : ""
        this.asMap := options.HasOwnProp("asMap") ? options.asMap : false
        
        this.signal := depend
        this.mutation := mutation
        this.prevValue := 0

        ; subscribers
        this.subs := []
        this.comps := []
        this.effects := []
        
        ; debugger
        this.debugger := false

        if (this.signal is Array) {
            for s in this.signal {
                s.addComp(this)
            }

            this.insertPrevCount := this.signal.Length * 2 == this.mutation.MaxParams 
                ? this.mutation.MaxParams
                : Mod(this.mutation.MaxParams, this.signal.Length)
            
            values := []
            for s in this.signal {
                if (A_Index <= this.insertPrevCount) {
                    values.Push(s.prevValue, s.value)
                } else {
                    values.Push(s.value)
                }
            }

            ; this.value := this._mapify(this.mutation.Call(values*))
            this.value := this.asMap ? this._mapify(this.mutation.Call(values*)) : this.mutation.Call(values*)
        } else {
            this.signal.addComp(this)
            ; this.value := this._mapify(this.mutation.Call(this.signal.value))
            this.value := this.asMap ? this._mapify(this.mutation.Call(this.signal.value)) : this.mutation.Call(this.signal.value)
        }

        ; ; debug mode
        if (!IsSet(DebugUtils) && !IsSet(debugger)) {
            return
        }

        if (ARConfig.debugMode && this.name && !(this is debugger)) {
            this.createDebugger := DebugUtils.createDebugger
            this.debugger := this.createDebugger(this)
            DebuggerList.addDebugger(this.debugger)

            ; if (InStr(this.debugger.value["fromFile"], "AddReactive\devtools\devtools-ui")) {
            ;     this.debugger := false
            ; } else {
            ;     IsSet(CALL_TREE) && CALL_TREE.addDebugger(this.debugger)
            ; }
        }
    }

    /**
     * Interface for subscribed signal to sync value to date.
     * @param {signal} subbedSignal subscribed signal
     */
    sync(subbedSignal) {
        this.prevValue := this.value

        if (this.signal is Array) {
            values := []
            for s in this.signal {
                if (A_Index <= this.insertPrevCount) {
                    values.Push(s.prevValue, s.value)
                } else {
                    values.Push(s.value)
                }
            }
            ; this.value := this._mapify(this.mutation.Call(values*))
            this.value := this.asMap ? this._mapify(this.mutation.Call(values*)) : this.mutation.Call(values*)
        } else {
            ; this.value := this._mapify(this.mutation.Call(subbedSignal.value))
            this.value := this.asMap ? this._mapify(this.mutation.Call(subbedSignal.value)) : this.mutation.Call(subbedSignal.value)
        }

        ; notify all subscribers to update
        for ctrl in this.subs {
            ctrl.update(this)
        }

        ; notify all computed signals
        for comp in this.comps {
            comp.sync(this)
        }

        ; run all effectss
        for effect in this.effects {
            if (effect.depend is signal) {
                e := effect.effectFn
                if (effect.effectFn.MaxParams == 1) {
                    e(this.value)
                } else if (effect.effectFn.MaxParams == 2) {
                    e(this.value, this.prevValue)
                } else {
                    e()
                }
            } else if (effect.depend is Array) {
                e := effect.effectFn
                e(effect.depend.map(dep => dep.value)*)
            }
        }

        ; notify debugger
        ; if (ARConfig.debugMode && this.name && this.debugger) {
        ;     this.debugger.notifyChange()
        ; }
    }

    /**
     * Interface for AddReactiveControl instances to subscribe.
     * @param {AddReactive} AddReactiveControl 
     */
    addSub(AddReactiveControl) {
        this.subs.Push(AddReactiveControl)
    }

    /**
     * Interface for computed instances to subscribe.
     * @param {computed} computed 
     */
    addComp(computed) {
        this.comps.Push(computed)
    }

    /**
     * Interface for effect instances to subscribe.
     * @param {effect} effect
     */
    addEffect(effect) {
        this.effects.Push(effect)
    }
}