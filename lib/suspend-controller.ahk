class SuspendController {
    __New(customMessage) {
        this.customMessage := customMessage
        OnMessage(this.customMessage, this.handleSuspend)
    }

    handleSuspend(wParam, *) {
        Suspend(wParam == 1 ? true : false)
    }

    suspendOtherScripts() {
        DetectHiddenWindows(true)

        curHwnd := WinExist("A") ; current script
        for hwnd in WinGetList("ahk_class AutoHotkey") {
            if (hwnd != curHwnd) {
                PostMessage(this.customMessage, 1, , , hwnd) ; force suspend others
            }
        }

        ; ensure self is active
        PostMessage(0x0401, 0, , , curHwnd)
    }

    restoreAllScripts() {
        DetectHiddenWindows(true)
        for hwnd in WinGetList("ahk_class AutoHotkey") {
                PostMessage(0x0401, 0, , , hwnd)
        }
    }
}