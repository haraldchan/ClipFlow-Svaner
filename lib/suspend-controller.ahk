class SuspendController {
    __New(customMessage) {
        this.customMessage := customMessage
        OnMessage(this.customMessage, (wParam, *) => Suspend(wParam == 1 ? true : false))
    }

    /**
     * Change suspend states.
     * @param {1 | 0} state 
     */
    handleSpcriptSuspendState(state) {
        DetectHiddenWindows(true)

        curHwnd := WinExist("A") ; current script
        for hwnd in WinGetList("ahk_class AutoHotkey") {
            if (hwnd != curHwnd) {
                SendMessage(this.customMessage, state, , , hwnd) ; force suspend others
            }
        }

        ; ensure self is active
        Suspend(false)
    }

    suspendOtherScripts() => this.handleSpcriptSuspendState(1)

    restoreAllScripts() => this.handleSpcriptSuspendState(0)
}