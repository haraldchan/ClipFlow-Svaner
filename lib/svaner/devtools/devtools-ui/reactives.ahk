#Include "./reactive-details.ahk"

/**
 * @param {Svaner} App 
 */
Reactives(App) {
    lvOptions := {
        lvOptions: "xs10 yp+20 w350 r10 LV0x4000 Grid NoSortHdr"
    }

    columnDetails := {
        keys: ["signalName", "caller", "value"],
        titles: ["Signal Name", "Component", "Value"],
        widths: [120, 100, 100]
    }

    signals := computed(DebuggerList.debuggers, cur => ArrayExt.filter(cur, item => item.signalType == "signal"))
    computeds := computed(DebuggerList.debuggers, cur => ArrayExt.filter(cur, item => item.signalType == "computed"))
    
    handleShowSignalDetails(LV, row, signalList) {
        if (row == 0 || row > 10000) {
            return
        }

        ReactiveDetails(signalList[row])
    }

    return (
        StackBox(App,
            {
                name: "signals",
                fontOptions: "bold",
                groupbox: {
                    title: "Signals / States",
                    options: "vsignals-stackbox Section w380 r11"
                }
            },
            () => [
                App.AddListView(lvOptions, columnDetails, signals)
                   .onDoubleClick((LV, row) => handleShowSignalDetails(LV, row, signals.value))
            ]
        ),

        StackBox(App,
            {
                name: "computeds",
                fontOptions: "bold",
                groupbox: {
                    title: "Computeds / Deriveds",
                    options: "Section @align[XWH]:signals-stackbox y+5"
                }
            },
            () => [
                App.AddListView(lvOptions, columnDetails, computeds)
                   .onDoubleClick((LV, row) => handleShowSignalDetails(LV, row, computeds.value))
            ]
        )
    )
}