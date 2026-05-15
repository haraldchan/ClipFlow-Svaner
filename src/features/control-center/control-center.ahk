#Include clipboard-history\clipboard-history.ahk
#Include listener-hub\listener-hub.ahk
#Include error-logger.ahk

/**
 * @param {Svaner} App
 */
ControlCenter(App) {
    handleErrorToLogToggle(ctrl, _) {
        OnError(errorLogger, ctrl.Value)
    }

    onMount() {
        App["errorToLog"].Value := USE_ERROR_LOG
    }

    return (
        ; listener controls
        ListenerHub(App),

        ; enable logging
        App.AddCheckBox("verrorToLog @align[x]:persist-listeners-gb y+10", "拦截报错至日志")
           .onClick(handleErrorToLogToggle),

        ; clipboard history
        ClipboardHistory(App),

        onMount()
    )
}