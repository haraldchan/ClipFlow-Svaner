#Include extend-array-methods.ahk
#Include extend-string-methods.ahk
#Include extend-number-methods.ahk
#Include extend-gui-methods.ahk
#Include extend-map-methods.ahk

patchMethods() {
    if (!SvanerConfig.useExtendMethods) {
        return
    }

    ArrayExt.patch()
    StringExt.patch()
    NumberExt.patch()
    GuiExt.patch()
    MapExt.patch()
    
    if (SvanerConfig.enableExtendMethods.any.HasOwnProp("satisfies")) {
        if (SvanerConfig.enableExtendMethods.any.satisfies) {
            Struct.patch()
        }
    }
}

patchMethods()