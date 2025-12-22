/**
 * Set placeholder value for AddReactive ListView such as loading or error.
 * @param {signal} depend Signal that provides list content.
 * @param {Object | Array} columnDetails An object or Array containing the keys for column values.
 * @param {String} placeHolder Text as placeholder.
 */
useListPlaceholder(depend, columnDetails, placeHolder) {
    TypeChecker.checkType(depend, signal, "First Parameter is not a signal.")
    TypeChecker.checkType(depend.value, Array, "useListPlaceholder can only work with Array signals.")
    TypeChecker.checkType(columnDetails, [Object, Array], "Second Parameter is not an Object.")
    TypeChecker.checkType(placeholder, String, "Third Parameter is not an String.")

    setLoadingValue(columnKeys) {
        loadingValue := OrderedMap()

        for key in columnKeys {
            loadingValue[key] := placeHolder
        }

        return loadingValue
    }

    columnKeys := ((columnDetails is Object) && !(columnDetails is Array))
        ? columnDetails.keys
        : columnDetails

    depend.set([setLoadingValue(columnKeys)])
}