class TypeChecker {
    /**
     * Checks the type of a value.
     * @param {Any} val Value to be checked
     * @param {Any|Array} typeChecking A type or multiple types to check
     * @param {String} errMsg Error message to show
     */
    static checkType(val, typeChecking, errMsg := 0) {
        if (!val) {
            return
        }

        if (typeChecking is Array) {
            for t in typeChecking {
                if (t == Object.Prototype) {
                    if (this.isPlainObject(val)) {
                        return
                    }
                } else if (t is Func && t.name == "IsTime") {
                    if (IsTime(val)) {
                        return
                    }
                } else if (val is t) {
                    return
                } else {
                    continue
                }
            }

            throw TypeError(
                errMsg != 0
                    ? Format("{1}; `n`nCurrent Type: {2}", errMsg, Type(val))
                : Format("Expect Type: {1}. Current Type: {2}", this.getTypeName(typeChecking), Type(val)),
                -1,
                val
            )
        } else if (typeChecking == Object.Prototype) {
            if (!this.isPlainObject(val)) {
                throw TypeError(
                    errMsg != 0
                        ? Format("{1}; `n`nCurrent Type: {2}", errMsg, Type(val))
                    : Format("Expect Type: {1}. Current Type: {2}", "Plain Object", Type(val)),
                    -1,
                    val
                )
            }
        } else if (typeChecking is Func && typeChecking.name == "IsTime") {
            if (!IsTime(val)) {
                throw ValueError(
                    errMsg != 0
                        ? Format("{1}; `n`nCurrent Type: {2}", errMsg, Type(val))
                    : Format("Invalid date-time stamp."),
                    -1,
                    val
                )
            }

        } else if (!(val is typeChecking)) {
            throw TypeError(
                errMsg != 0
                    ? Format("{1}; `n`nCurrent Type: {2}", errMsg, Type(val))
                : Format("Expect Type: {1}. Current Type: {2}", this.getTypeName(typeChecking), Type(val)),
                -1,
                val
            )
        }

        return true
    }

    static checkTypeDepend(depend) {
        if (depend = 0) {
            return
        }
        errMsg := "Parameter #3 (depend) is not a signal or an array containing signals"
        if (depend is Array) {
            for item in depend {
                if (!(item is signal)) {
                    throw TypeError(Format("{1}; `n`nCurrent Type: {2}", errMsg, Type(depend)), -1, depend)
                }
            }
        } 
        else if (depend.base == Object.Prototype) {
            for key, val in depend.OwnProps() {
                if !(val is signal) {
                    throw TypeError(Format("{1}; `n`nCurrent Type: {2}", errMsg, Type(depend)), -1, depend)
                }
            }
        }
        else if (!(depend is signal)) {
            throw TypeError(Format("{1}; `n`nCurrent Type: {2}", errMsg, Type(depend)), -1, depend)
        } 

        return true
    }

    /**
     * Check if the object is plain and returns true or false
     * @param {Object} obj Object to check.
     * @returns {Boolean} 
     */
    static isPlainObject(obj) {
        return obj.base == Object.Prototype ? true : false
    }

    static getTypeName(classType) {
        if (classType is Array) {
            itemType := this.getTypeName(classType[1])
            return "Array<" . itemType . ">"
        }

        return classType.Prototype.__Class
    }
}