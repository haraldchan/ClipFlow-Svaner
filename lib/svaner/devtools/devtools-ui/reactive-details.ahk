; TODO:
/**
 * Pt. Dynamic Control for different type of value
 *  - String|Number: Edit
 *  
 *  - Object|Map|Array<String|Number>: 2-col ListView for key/val or index/val
 *  
 *  - Array<Object|Map>: multi-col ListView
 * 
 * Pt. Hence, needs a type validating func, perhaps Struct.New is useful.
 */

/**
 * @param {Object} debuggerObj
 */
ReactiveDetails(debuggerObj) {
    App := Svaner({
        gui: { 
            title: debuggerObj.signalName
        },
        font: { 
            name: "Tahoma" 
        }
    })

    signalName := debuggerObj.signalName
    signalType := debuggerObj.signalType
    signalInstance := debuggerObj.debugger.value.signalInstance

    createListViewContent(signalValue) {
        /** @type {Gui.ListView} */
        LV := App["lv-primitive"]

        LV.ModifyCol(1, 100)
        LV.ModifyCol(2, 200)
        
        for indexOrKey, value in (signalValue is Map ? signalValue : signalValue.OwnProps()) {
            LV.Add(, indexOrKey, value)    
        }
    }

    structredLvOptions := {
        option: {
            lvOptions: "vlv-structure @lv:label-tip w300"
        },
        columnDetails: {
            keys: [signalInstance.value]
        }
    }

    mountValueControls(signalInstance) {
        ; primitive values
        if !(signalInstance.value is Object) {
            App.AddEdit("x+10 w150 h20 ReadOnly", signalInstance.value)
        } 
        ; structured array
        else if (signalInstance.value is Array && ArrayExt.every(signalInstance.value, item => item is Object)) {
            App.AddListView(
                { lvOptions: "vlv-structure @lv:label-tip w300" },
                { keys: MapExt.keys(JSON.parse(JSON.stringify(signalInstance.value[1])))},
                signalInstance
            )
        }
        ; array of primitives
        else if (signalInstance.value is Object) {
            App.AddListView("vlv-primitive @lv:label-tip w300", [signalInstance.value is Array ? "Index" : "Key", "Value"])
            createListViewContent(signalInstance.value)
        }
    }

    return (
        App.AddText("vsignal-name w70 h20", "Signal Name:"),
        App.AddEdit("x+10 w150 h20 ReadOnly", signalName),
        App.AddText("@align[XWH]:signal-name", "Signal Type:"),
        App.AddEdit("x+10 w150 h20 ReadOnly", signalType),
        
        App.AddText("@align[XWH]:signal-name", "Current Value:"),

        mountValueControls(signalInstance),

        App.Show()
    )
}