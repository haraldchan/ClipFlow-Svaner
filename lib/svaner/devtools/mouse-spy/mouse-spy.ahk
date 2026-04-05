#SingleInstance Force
; svaner
#Include ..\..\useSvaner.ahk
; store
#Include stores\mouse-store.ahk
; components
#Include information.ahk
#Include record.ahk
#Include settings.ahk

if (!A_IsAdmin) {
    Run("*RunAs " . A_ScriptFullPath)
}

MouseSpySvaner := Svaner({
    gui: {
        options: "+AlwaysOnTop",
        title: "MouseSpy"
    },
    font: {
        options: "s9", 
        name: "Tahoma"
    },
    events: {
        close: (*) => ExitApp()
    }
})
MouseSpy(MouseSpySvaner)
MouseSpySvaner.Show()


/**
 * @param {Svaner} App 
 */
MouseSpy(App) {
    config := JSON.parse(FileRead("./mousespy.config.json", "UTF-8"))
    suspendText := computed(mouseStore.followMouse, isFollowing => isFollowing ? "(Hold Ctrl or Shift to suspend updates)" : "(Update suspended)", { name: "suspendText" })
    
    return (
        ; { follow switch
        App.AddCheckBox("vfollow-status x10 w100 h20 Checked", "Follow Mouse", { check: mouseStore.followMouse }).bind(),
        App.AddText("vsuspend-status x+10 h20 w260 0x200 +Right", "{1}", suspendText),
        ; }

        ; { tabs
        App.AddTab3("vtab3 x10 w370", OrderedMap(
            "Information", () => MouseSpy_Information(App, config, App.gui.Title, suspendText),
            "Record",      () => MouseSpy_Record(App, config),
            "Settings",    () => MouseSpy_Settings(App, config, App.gui.Title),
        ))
        ; }
    )
}

; DevToolsUI()