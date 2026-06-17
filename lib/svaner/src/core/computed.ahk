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
     *      forceUpdate: true ; triggers subscribers update and effects when set/update was called, even if the value is the same as previous
     *      asMap: true       ; converts object-type value to Map -> Map("num", 1)
     *   }
     * ) 
     * ```     
     * @return {computed}
     */
    __New(depend, mutation, options := { name: "", asMap: false }) {
        TypeChecker.checkType(depend, [signal, computed, Array], "First parameter is not a signal.")
        TypeChecker.checkType(mutation, Func, "Second parameter is not a Function.")

        ; options
        this.name := options.HasOwnProp("name") ? options.name : ""
        this.forceUpdate := options.HasOwnProp("forceUpdate") ? options.forceUpdate : false
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

        values := []
        if (this.signal is Array) {
            for s in this.signal {
                s.addComp(this)
            }

            this.insertPrevCount := this.signal.Length * 2 == this.mutation.MaxParams 
                ? this.mutation.MaxParams
                : Mod(this.mutation.MaxParams, this.signal.Length)
            
            for s in this.signal {
                if (A_Index <= this.insertPrevCount) {
                    values.Push(s.prevValue, s.value)
                } else {
                    values.Push(s.value)
                }
            }
        } 
        else {
            this.signal.addComp(this)

            if (this.mutation.MaxParams == 2) {
                values.Push(this.signal.prevValue, this.signal.value)
            }
            else {
                values.Push(this.signal.value)
            }
        }
        
        this._value := this.asMap ? this._mapify(mutation(values*)) : mutation(values*)

        ; debug mode
        if (!IsSet(DebugUtils) && !IsSet(debugger)) {
            return
        }

        if (SvanerConfig.debugMode && this.name && !(this is debugger)) {
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

    value {
        get => this._value
    }

    /**
     * Interface for subscribed signal to sync value to date.
     * @param {signal} subbedSignal subscribed signal
     */
    sync(subbedSignal) {
        if (!this.forceUpdate && subbedSignal.value == this.value) {
            return
        }
        this.prevValue := this.value

        values := []
        if (this.signal is Array) {
            for s in this.signal {
                if (A_Index <= this.insertPrevCount) {
                    values.Push(s.value, s.prevValue)
                } else {
                    values.Push(s.value)
                }
            }
        }
        else {
            if (this.mutation.MaxParams == 2) {
                values.Push(subbedSignal.prevValue, subbedSignal.value)
            }
            else {
                values.Push(subbedSignal.value)
            }
        }
        
        m := this.mutation
        this._value := this.asMap ? this._mapify(m(values*)) : m(values*)
        
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
        ; if (SvanerConfig.debugMode && this.name && this.debugger) {
        ;     this.debugger.notifyChange()
        ; }
    }

    /**
     * Interface for AddReactiveControl instances to subscribe.
     * @param {AddReactive} AddReactiveControl 
     */
    addSub(SvanerControl) {
        if (ArrayExt.find(this.subs, ctrl => ctrl == SvanerControl)) {
            return
        }
        this.subs.Push(SvanerControl)
    }

    /**
     * Interface for computed instances to subscribe.
     * @param {computed} computed 
     */
    addComp(computed) {
        if (ArrayExt.find(this.comps, comp => comp == computed)) {
            return
        }
        this.comps.Push(computed)
    }

    /**
     * Interface for effect instances to subscribe.
     * @param {effect} effect
     */
    addEffect(effect) {
        if (ArrayExt.find(this.effects, e => e.effectFn == effect.effectFn)) {
            return
        }
        this.effects.Push(effect)
    }
}
