class Struct {
    /**
     * Creates predefined set of fields with specific data types.
     * ```
     * Person := Struct({
     *  name: String,
     *  age:  Integer,
     *  tel:  Number
     * })
     * ```
     * @param {Object} structObject An object defining the structure and data types for each field.
     */
    __New(structObject) {
        this.structObject := structObject
        this.typeMap := Map()

        for key, type in this.structObject.OwnProps() {
            this.typeMap[key] := type
        }
    }

    /**
     * Returns a Struct instance fulfills predefined data structure.
     * @param {Object|Map|OrderedMap} data 
     * ```
     * staff := Person.new({ 
     *   name: "Amy", 
     *   age:   29, 
     *   tel:   88372153
     * })
     * ```
     * @returns {Struct.StructInstance} 
     */
    new(data) {
        return Struct.StructInstance(data, this.typeMap)
    }

    /**
     * Validates if a value satisfies Struct.
     * @param {Any} value 
     * @returns {Any | false}
     */
    validate(value) {
        return Struct.satisfies(value, this)
    }

    static patch() => Any.Prototype.satisfies := ObjBindMethod(Struct, "satisfies")
    /**
     * Validates if a value satisfies datatype.
     * @param {Any} value 
     * @param {Any} datatype 
     * @returns {Any | false} 
     */
    static satisfies(value, datatype) {
        if (datatype is Array) {
            switch {
                case (datatype.Length == 1 && datatype[1] is Struct):
                    for item in value {
                        if (!datatype[1].validate(item)) {
                            return false
                        }
                    }
                    return value
                case (datatype.Length == 1):  
                    for item in value {
                        if !(item is datatype) {
                            return false
                        }
                    }
                    return value
                default:
                    if (!ArrayExt.find(datatype, t => t.base == value.base && t == value)) {
                        return false
                    }
                    return value
            }
        } 
        else if (datatype is Struct) {
            try {
                datatype.new(value)
                return value
            }
            catch {
                return false
            }
        }
        else {
            return value is datatype ? value : false
        }
    }

    class StructInstance {
        __New(data, typeMap) {
            this.data := data
            this.typeMap := typeMap
            this._keys := []
            this._values := []

            this._validateFields(data, typeMap)

            for key, val in (data is Map ? data : data.OwnProps()) {
                k := key
                v := val
                this._keys.Push(key)

                ; objects
                if (val.base == Object.Prototype || val is Map) {
                    this._values.Push(Struct.StructInstance(val, typeMap[key].typeMap))
                    continue
                }

                ; array of a certain type
                if (val is Array) {
                    this._validateArrayTypes(val, typeMap, key)
                }

                ; primitive
                if (val is Primitive) {
                    this._validatePrimitiveType(val, typeMap, key)
                }

                this._values.Push(val)
            }
        }

        __Item[key] {
            get {
                if (!ArrayExt.find(this._keys, k => k = key)) {
                    throw ValueError(Format("Key:{1} not found.", key))
                }

                return this._values[ArrayExt.findIndex(this._keys, item => item = key)]
            }

            set {
                ; field not found
                if (!this._keys.find(k => k = key)) {
                    throw ValueError(Format("Key:`"{1}`" not found.", key))
                }

                ; object validation
                if (value.base == Object.Prototype || value is Map || value is Struct.StructInstance) {
                    matching := value is Struct.StructInstance
                        ? this.typeMap[key].new(value.mapify())
                        : this.typeMap[key].new(value)
                    matching := ""
                }
                ; array item validation
                else if (value is Array) {
                    this._validateArrayTypes(value, this.typeMap, key)
                }
                ; primitives
                else if (value is Primitive) {
                    this._validatePrimitiveType(value, this.typeMap, key)
                }

                this._values := this._values.with(this._keys.findIndex(item => item = key), value)
            }
        }

        __Enum(NumberOfVars) {
            return NumberOfVars == 1 ? enumK : enumKV

            enumK(&key) {
                if (A_Index > this._keys.Length) {
                    return false
                }

                key := this._keys[A_Index]
            }

            enumKV(&key, &value) {
                if (A_Index > this._keys.Length) {
                    return false
                }

                key := this._keys[A_Index]
                value := this._values[A_Index]
            }
        }

        _getTypeName(classType) {
            if (classType is Array) {
                itemType := this._getTypeName(classType[1])
                return "Array<" . itemType . ">"
            }

            return classType.Prototype.__Class
        }

        _validateFields(data, typeMap) {
            errMsg := "Struct fields not match, {1}: `"{2}`""
            dataKeys := []

            if (data is Map) {
                dataKeys := MapExt.keys(data)
            } else if (data.base == Object.Prototype) {
                for key in data.OwnProps() {
                    dataKeys.Push(key)
                }
            }

            ; unknown field
            for key in dataKeys {
                if (!typeMap.has(key)) {
                    throw ValueError(Format(errMsg, "unknown", key))
                }
            }

            ; missing field
            for key, type in typeMap {
                k := key
                if (!ArrayExt.find(dataKeys, dKey => dKey = k)) {
                    throw ValueError(Format(errMsg, "missing", key))
                }
            }
        }

        _validateArrayTypes(value, typeMap, key) {
            ; array of a certain type
            if !(typeMap[key] is Array) {
                throw TypeError(Format(
                    "Type mismatch .`n`nExpected: {1}, current: {2}",
                    this._getTypeName(typeMap[key]),
                    Type(value),
                ))
            }
            ; array of same type values, e.g. [String]
            else if (mismatchedIndex := ArrayExt.findIndex(value, item => !(item is typeMap[key][1]))) {
                throw TypeError(Format(
                    "Expected item type of index:{1} does not match.`n`nExpected: {2}, current: {3}",
                    mismatchedIndex,
                    this._getTypeName(typeMap[key][1]),
                    Type(value[mismatchedIndex])
                ))
            }
        }

        _validatePrimitiveType(value, typeMap, key) {
            ; literal type
            if (typeMap[key] is Primitive) {
                if (value != typeMap[key]) {
                    throw TypeError(Format("Type mismatch.`n`nExpected: {1}, current: {2}", typeMap[key], value), -1, value)
                }
            }
            ; literal types
            else if (typeMap[key] is Array && ArrayExt.every(typeMap[key], t => t is Primitive)) {
                if (!ArrayExt.find(typeMap[key], item => item = value)) {
                    throw TypeError(Format("Type mismatch.`n`nAssignables: {1}", ArrayExt.join(typeMap[key], " | ")), -1, value)
                }
            }
            else {
                if !(value is typeMap[key]) {
                    throw TypeError(Format(
                        "Expected value type of key:`"{1}`" does not match.`n`nExpected: {2}, current: {3}",
                        key,
                        this._getTypeName(typeMap[key]),
                        Type(value)
                    ))
                }
            }
        }

        /**
         * Returns a Map of converted StructInstance.
         * @returns {Map} 
         */
        mapify() {
            resMap := Map()

            for index, key in this._keys {
                val := this._values[index]
                resMap[key] := val is Struct.StructInstance ? val.mapify() : val
            }

            return resMap
        }

        /**
         * Returns a boolean indicating whether an element with the specified key exists in this struct instance or not.
         * @param key The key of the element to test for presence in the struct instance.
         * @returns {Boolean} true if an element with the specified key exists in the struct instance; otherwise false.
         */
        has(key) => ArrayExt.find(this._keys, item => item = key) ? true : false

        /**
         * Returns a JSON format string of converted StructInstance.
         * @returns {String} 
         */
        stringify() => JSON.stringify(this.mapify())
    }
}