/**
 * Unpacks an array or object into multiple variables by reference.
 * 
 * ```
 * arr := [1, 2, 3]
 * unpack([&a, &b, &c], arr)  ; assigns: a := 1, b := 2, c := 3
 * 
 * staff := { name: "John", age: 33 }
 * unpack({ name: &name, age: &age }, staff)  ; assigns: name := "John", age := 33
 * 
 * nested := { user: { name: "Jane", location: { city: "Paris" } } }
 * unpack({ user: { name: &userName, location: { city: &city } } }, nested)
 * ; assigns: userName := "Jane", city := "Paris"
 * ```
 * 
 * Supports deep nesting and type-safe value mapping from the source object or array.
 * 
 * @param {Array | Object | useStore} source - An array, Map, or plain object whose values are unpack into outputVars.
 * @param {Array<VarRef> | Object<string, VarRef>} outputVars - An array or object containing VarRefs to receive values.
 * @throws {ValueError} If a key or index is missing in the source.
 */
unpack(source, outputVars) {
    TypeChecker.checkType(outputVars, [Array, Map, Object.Prototype, useStore])
    TypeChecker.checkType(source, [Array, Map, Object.Prototype, useStore])

    _refs(rawRefs) {
        if (rawRefs is Array) {
            return pipe(
                x => ArrayExt.map(x, (&var) => value => var := value)
            )(rawRefs)

        } else if (rawRefs is Map || (rawRefs.base == Object.Prototype) || rawRefs is useStore) {
            out := {}
            for k, v in (rawRefs is Map ? rawRefs : rawRefs.OwnProps()) {
                if (v is Map || v.base == Object.Prototype) {
                    out.%k% := _refs(v)
                } else {
                    out.%k% := ((&var) => value => var := value)(v)
                }
            }

            return out
        }
    }

    _resolve(setters, source) {
        if (setters is Func) {
            setters(source)
            return
        }

        if (source is Array) {
            for setter in setters {
                if (A_Index > source.Length) {
                    throw IndexError("Index out of range", -1, A_Index)
                }

                _resolve(setter, source[A_Index])
            }
        }

        if (source is Map || source.base == Object.Prototype || source is useStore) {
            isMap := source is Map

            for k, setter in setters.OwnProps() {
                if (setter is Map || setter.base == Object.Prototype || source is useStore) {
                    _resolve(setter, isMap ? source[k] : source.%k%)
                }

                if (isMap ? source.has(k) : source.HasOwnProp(k)) {
                    _resolve(setter, isMap ? source[k] : source.%k%)
                } else {
                    throw ValueError("Key not found.", -1, k)
                }
            }
        }
    }

    _resolve(_refs(outputVars), source)
}