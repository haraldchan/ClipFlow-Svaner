#Include clipboard-history\clipboard-history.ahk
#Include listener-hub\listener-hub.ahk

/**
 * @param {Svaner} App
 */
ControlCenter(App) {
    return (
        ListenerHub(App),
        ClipboardHistory(App)
    )
}