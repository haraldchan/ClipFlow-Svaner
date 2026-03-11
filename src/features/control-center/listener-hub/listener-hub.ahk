#Include listener-controller.ahk

/**
 * @param {Svaner} App
 */
ListenerHub(App) {
    persistListeners := computed(clbListeners.listeners, ls => ls.filter(l => l.type == "persist"))
    moduleListeners := computed(clbListeners.listeners, ls => ls.filter(l => l.type == "module"))
    
    effect(persistListeners, (cur) => handleIsOnUpdate("persist", cur))
    effect(moduleListeners, (cur) => handleIsOnUpdate("module", cur))
    handleIsOnUpdate(listenerType, curModuleListeners) {
        for listener in curModuleListeners {
            App[listenerType . "-listeners"].modify(A_Index, listener.isOn ? "+Check" : "-Check")
        }
    }

    handleIsOnToggle(lv, row, checked) {
        switch lv.name {
            case "persist-listeners":
                desc := persistListeners.value[row].description
            case "module-listeners":
                desc := moduleListeners.value[row].description
        }

        curListeners := clbListeners.listeners.value
        for listener in curListeners {
            if (listener.description == desc) {
                listener.isOn := checked
            }
        }
    }

    onMount() {
        clbListeners.addListener({
            description: "hello world(测试用)",
            type: "persist",
            isOn: false,
            callback: (*) => MsgBox("Hello World!`n`nClipped:`n" . A_Clipboard)
        })

        clbListeners.addListener({
            description: "SPayPos 复制卡号",
            type: "persist",
            isOn: true,
            callback: (*) => DepositEntry_Action.copyFromSPayPos()
        })
    }

    return (
        StackBox(
            App, {
                font: { options: "bold" },
                groupbox: {
                    title: "常驻监听器",
                    options: "vpersist-listeners-gb Section y+15 w200 h160"
                }
            },
            () => [
                App.AddListView({
                    lvOptions: "vpersist-listeners xs10 yp+20 w180 h130 NoSortHdr Grid ReadOnly Checked",
                }, {
                    keys: ["description"],
                    titles: ["监听描述"],
                    widths: [170]
                },
                    persistListeners
                ).onItemCheck(handleIsOnToggle),
            ]
        ),
        StackBox(
            App, {
                font: { options: "bold" },
                groupbox: {
                    title: "插件监听器",
                    options: "Section @align[x]:persist-listeners-gb y+5 w200 h160"
                }
            },
            () => [
                App.AddListView({
                    lvOptions: "vmodule-listeners xs10 yp+20 w180 h130 NoSortHdr Grid ReadOnly Checked",
                }, {
                    keys: ["description"],
                    titles: ["监听描述"],
                    widths: [170]
                },
                    moduleListeners
                ).onItemCheck(handleIsOnToggle),
            ]
        ),
        onMount()
    )
}
