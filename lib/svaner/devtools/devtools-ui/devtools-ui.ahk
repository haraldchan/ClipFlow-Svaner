; #Include "./components.ahk"
#Include "./reactives.ahk"

if (ARConfig.debugMode) {
    ; global CALL_TREE := CallTree()
}

DevToolsUI() {
    if (!ARConfig.debugMode) {
        return
    }

    ARConfig.useDevtoolsUI := true

    dtUI := Svaner({
        gui: {
            title: "AddReactive DevTools"
        },
        font: {
            name: "Verdana"
        }
    })

    return (
        Tabs := dtUI.AddTab3(, ["Reactives", "Components", "Code Preview", "Replay"]),
        
        Tabs.UseTab("Reactives"),
        Reactives(dtUI),

        dtUI.Show()
    )
}