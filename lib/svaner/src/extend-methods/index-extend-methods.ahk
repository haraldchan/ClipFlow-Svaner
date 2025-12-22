#Include extend-array-methods.ahk
#Include extend-string-methods.ahk
#Include extend-number-methods.ahk
#Include extend-gui-methods.ahk
#Include extend-map-methods.ahk

patchMethods() {
    if (!ARConfig.useExtendMethods) {
        return
    }

    ArrayExt.patch()
    StringExt.patch()
    NumberExt.patch()
    GuiExt.patch()
    MapExt.patch()
    
    if (ARConfig.enableExtendMethods.any.HasOwnProp("satisfies")) {
        if (ARConfig.enableExtendMethods.any.satisfies) {
            Struct.patch()
        }
    }
}

patchMethods()