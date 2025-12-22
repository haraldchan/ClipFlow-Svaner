class signal {
    /**
     * @typedef {Object} SignalOptions
     * @property {String} [name] 
     * @property {true | false} [forceUpdate=false]
     * @property {true | false} [asMap=false]
     */
    /**
     * Creates a reactive signal variable.
     * @param {Any} initialValue The initial value of the signal.This argument is ignored after the initial render. 
     * ```
     * count := signal(0)
     * current := count.value ; current: 0
     * 
     * ; change the value by .set(value) or .set(callback)
     * count.set(3)
     * count.set(cur => cur + 2)
     * ```
     * 
     * @param {SignalOptions} [options]
     * ```
     * counter := signal({ num: 1 }, 
     *   {   
     *      name: "counter",  ; named signals can be pick up by DevToolsUI
     *      forceUpdate: true ; triggers subscribers update and effects when set/update was called, even if the value is the same as previous
     *      asMap: true       ; converts object-type value to Map -> Map("num", 1)
     *   }
     * ) 
     * ```
     * @return {Signal}
     */
    __New(initialValue, options := { name: "", forceUpdate: false, asMap: false }) {
        ; options
        this.name := options.HasOwnProp("name") ? options.name : ""
        this.forceUpdate := options.HasOwnProp("forceUpdate") ? options.forceUpdate : false
        this.asMap := options.HasOwnProp("asMap") ? options.asMap : false

        ; initialize value
        this.value := this.asMap ? this._mapify(initialValue) : initialValue
        this.initValue := this.value
        this.prevValue := 0

        ; subscribers
        this.subs := []
        this.comps := []
        this.effects := []

        ; type for Struct
        this.type := ""

        ; debugger
        this.debugger := false

        ; debug mode
        if (!IsSet(DebugUtils) && !IsSet(debugger)) {
            return
        }

        if (ARConfig.debugMode && this.name && !(this is debugger)) {
            ; this.createDebugger := DebugUtils.createDebugger
            this.debugger := DebugUtils.createDebugger(this)
            DebuggerList.addDebugger(this.debugger)

            ; if (InStr(this.debugger.value["fromFile"], "AddReactive\devtools\devtools-ui")) {
            ;     this.debugger := false
            ; } else {
            ;     IsSet(CALL_TREE) && CALL_TREE.addDebugger(this.debugger)
            ; }
        }
    }

    /**
     * Set the new value of the signal.
     * @param {any} newSignalValue New state of the signal. Also accept function object.
     * @returns {void} 
     */
    set(newSignalValue) {
        if (!this.forceUpdate && newSignalValue == this.value) {
            return
        }
        this.prevValue := this.value

        this.value := newSignalValue is Func ? newSignalValue(this.value) : newSignalValue
        if (this.asMap) {
            this.value := this._mapify(this.value)
        }

        ; validates new value if it matches the Struct
        this._validateType(this.type, this.value)

        ; notify all subscribers to update
        for ctrl in this.subs {
            ctrl.update(this)
        }

        ; notify all computed signals
        for comp in this.comps {
            comp.sync(this)
        }

        ; run all effects
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
        if (ARConfig.debugMode && this.name && this.debugger) {
            this.debugger.notifyChange()
        }
    }

    /**
     * Updates a specific field of Object/Map value.
     * @param {Array | Any} key index/key of the field.
     * @param newValue New value to assign of mutation function.
     */
    update(key, newValue) {
        if (!(this.value is Object)) {
            throw TypeError(Format("update can only handle Array/Object/Map; `n`nCurrent Type: {2}", Type(newValue)))
        }

        updater := this.value
        if (key is Array) {
            this._setExactMatch(key, updater, newValue)
        } else {
            this._setFirstMatch(key, updater, newValue)
        }

        prevStatusOfForceUpdate := this.forceUpdate
        this.forceUpdate := true
        this.set(updater)
        this.forceUpdate := prevStatusOfForceUpdate
    }

    /**
     * Resets the signal to its initial value.
     */
    reset() => this.set(this.initValue)

    ; find nested key by exact query path
    _setExactMatch(keys, item, newValue, index := 1) {
        if (index == keys.Length) {
            if (item.base == Object.Prototype) {
                item.%keys[index]% := newValue is Func ? newValue(item.%keys[index]%) : newValue
            }
            else {
                item[keys[index]] := newValue is Func ? newValue(item[keys[index]]) : newValue
            }
            return
        }

        for k, v in (item.base == Object.Prototype ? item.OwnProps() : item) {
            if (k == keys[index]) {
                this._setExactMatch(keys, v, newValue, index + 1)
            }
        }
    }

    ; find the first matching key
    _setFirstMatch(key, item, newValue) {
        if (item.base == Object.Prototype ? item.HasOwnProp(key) : item.Has(key)) {
            if (item.base == Object.Prototype) {
                item.%key% := newValue is Func ? newValue(item.%key%) : newValue
            }
            else {
                item[key] := newValue is Func ? newValue(item[key]) : newValue
            }
            return
        }

        for k, v in (item.base == Object.Prototype ? item.OwnProps() : item) {
            if (v is Map || v.base == Object.Prototype) {
                this._setFirstMatch(key, v, newValue)
            }
        }
    }

    /**
     * Sets the type of value.
     * ```
     * num := signal(0).as(Integer)
     * 
     * str := signal("").as(String)
     * ```
     * @param {Class|Struct} type Classes or Struct to set.
     */
    as(datatype) {
        this.type := datatype
        this._validateType(this.type, this.value)

        return this
    }

    ; to validate type if enabled .as
    _validateType(datatype, valueToValidate) {
        if (!datatype) {
            return
        }

        if (datatype is Struct) {
            ; try creating the same struct instance for validate.
            validateInstance := this.type.new(valueToValidate is Struct.StructInstance ? valueToValidate.mapify() : valueToValidate)
            validateInstance := ""
        } else if (datatype is Array) {
            switch {
                case (datatype.Length == 1 && datatype[1] is Struct):
                    for item in valueToValidate {
                        validateInstance := this.type[1].new(item is Struct.StructInstance ? item.mapify() : item)
                        validateInstance := ""
                    }
                case (datatype.Length == 1):
                    for item in valueToValidate {
                        TypeChecker.checkType(item, datatype)
                    }
                default:
                    if (!ArrayExt.find(datatype, t => t == valueToValidate)) {
                        errMsg := Format("Type mismatch.`n`nAssignables: {1}", ArrayExt.join(datatype, " | "))
                        throw ValueError(errMsg, -1, valueToValidate)
                    }
            }
        }
        else {
            TypeChecker.checkType(valueToValidate, datatype)
        }
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

    /**
     * Reformat an Object to Map.
     * @param {Object} obj Object to be change.
     * @returns {Any|Map}
     */
    _mapify(obj) {
        if (obj is Primitive) {
            return obj
        }

        if (obj.base == Object.Prototype || obj is Map) {
            res := Map()
            for key, val in (obj is Map ? obj : obj.OwnProps()) {
                if (val.base == Object.Prototype || val is Array || val is Map) {
                    res[key] := this._mapify(val)
                } else {
                    res[key] := val
                }
            }

            return res
        }

        if (obj is Array) {
            res := []
            for item in obj {
                if (item.base == Object.Prototype || item is Map) {
                    res.Push(this._mapify(item))
                } else {
                    res.Push(item)
                }
            }

            return res
        }
    }
}