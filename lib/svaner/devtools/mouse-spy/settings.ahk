/**
 * @param {Svaner} App 
 * @param {Map} config 
 * @param {String} MouseSpyWindowTitle 
 */
MouseSpy_Settings(App, config, MouseSpyWindowTitle) {
    unpack(mouseStore, { 
        curMouseInfo:      &curMouseInfo,
        anchorPos:         &anchorPos,
        followMouse:       &followMouse,
        methods: { 
            updater:       &updater,
            handleMousePosUpdate: &handleMousePosUpdate,
            moveToAnchor:  &moveToAnchor
        }
    })

    hotkeySetup := {
        markAnchor: {
            defaultHotkey: "+!s",
            hotkey: config["hotkeys"]["markAnchor"],
            callback: (*) => anchorPos.set(handleMousePosUpdate())
        },
        moveToAnchor: {
            defaultHotkey: "+!q",
            hotkey: config["hotkeys"]["moveToAnchor"],
            callback: moveToAnchor
        }
    }

    setHotkeys() {
        CoordMode("Mouse", "Screen")

        HotIfWinExist(MouseSpyWindowTitle)
        Hotkey "~*Ctrl", (*) => followMouse.set(false)
        Hotkey "~*Ctrl up", (*) => followMouse.set(true)
        Hotkey "~*Shift", (*) => followMouse.set(false)
        Hotkey "~*Shift up", (*) => followMouse.set(true)
        
        if (!hotkeySetup.moveToAnchor.hotkey) {
            hotkeySetup.moveToAnchor.hotkey := hotkeySetup.moveToAnchor.defaultHotkey
            config["hotkeys"]["moveToAnchor"] := hotkeySetup.moveToAnchor.defaultHotkey
            App["move-to-anchor-hotkey"].Value := hotkeySetup.moveToAnchor.defaultHotkey
            handleConfigUpdate()
        }
        if (!hotkeySetup.markAnchor.hotkey) {
            hotkeySetup.markAnchor.hotkey := hotkeySetup.markAnchor.defaultHotkey
            config["hotkeys"]["markAnchor"] := hotkeySetup.markAnchor.defaultHotkey
            App["mark-anchor-hotkey"].Value := hotkeySetup.markAnchor.defaultHotkey
            handleConfigUpdate()
        }
        Hotkey hotkeySetup.moveToAnchor.hotkey, hotkeySetup.moveToAnchor.callback, "On"
        
        HotIf((*) => WinExist(MouseSpyWindowTitle) && App["use-mouse-pos-anchor"].Value)
        Hotkey hotkeySetup.markAnchor.hotkey, hotkeySetup.markAnchor.callback, "On"
    }

    handleConfigUpdate() {
        FileDelete("./mousespy.config.json")
        FileAppend(JSON.stringify(config), "./mousespy.config.json", "UTF-8")
    }
    
    handleSetHotkeys(ctrl, _) {
        curHotkeyName := pipe(
            name => StrReplace(name, "-hotkey", ""),
            name => StrSplit(name, "-"),
            name => ArrayExt.map(name, (chunk, index) => index > 1 ? StrTitle(chunk) : chunk),
            name => ArrayExt.join(name, "")
        )(ctrl.Name)

        Sleep 200
        try {
            Hotkey hotkeySetup.%curHotkeyName%.hotkey, hotkeySetup.%curHotkeyName%.callback, "Off"
            hotkeySetup.%curHotkeyName%.hotkey := ctrl.Value
            
            Hotkey hotkeySetup.%curHotkeyName%.hotkey, hotkeySetup.%curHotkeyName%.callback, "On"
            
            config["hotkeys"][curHotkeyName] := ctrl.Value
            handleConfigUpdate()
        }
    }

    handleUpdateIntervalUpdate(ctrl, _) {
        SetTimer(updater, ctrl.Value)
        
        config["misc"]["updateInterval"] := ctrl.Value
        handleConfigUpdate()
    }

    App.defineDirectives(
        "@use:setting-item-text", "xs10 yp+22 w100 h20 0x200"
    )

    return (
        StackBox(App,
            {
                name: "hotkey-setup",
                fontOptions: "s10 bold",
                groupbox: {
                    title: "Record Options",
                    options: "Section @align[xyw]:window-info-stackbox h80"
                }
            },
            () => [
                ; anchor marking
                App.AddText("@use:setting-item-text", "Mark Anchor:"),
                App.AddHotkey("vmark-anchor-hotkey x+10", config["hotkeys"]["markAnchor"]).onChange(handleSetHotkeys),
                
                ; move to anchor
                App.AddText("@use:setting-item-text yp+25", "Move to Anchor:"),
                App.AddHotkey("vmove-to-anchor-hotkey x+10", config["hotkeys"]["moveToAnchor"]).onChange(handleSetHotkeys)
            ]
        ),

        StackBox(App,
            {
                name: "misc-settings",
                fontOptions: "s10 bold",
                groupbox: {
                    title: "Misc",
                    options: "Section @align[xw]:window-info-stackbox y+5 h160"
                }
            },
            () => [
                ; refresh interval
                App.AddText("@use:setting-item-text", "Update Interval:"),
                App.AddEdit("vupdate-interval x+10 w110 h20 Number", config["misc"]["updateInterval"]).onBlur(handleUpdateIntervalUpdate),
                App.AddText("x+5 w50 h20 0x200", "ms"),
            ]
        ),

        setHotkeys()
    )
}