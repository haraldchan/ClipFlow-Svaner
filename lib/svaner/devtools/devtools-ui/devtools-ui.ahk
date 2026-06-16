; #Include "./components.ahk"
#Include "./reactives.ahk"

if (SvanerConfig.debugMode) {
    ; global CALL_TREE := CallTree()
}

DevToolsUI() {
    if (!SvanerConfig.debugMode) {
        return
    }

    SvanerConfig.useDevtoolsUI := true

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