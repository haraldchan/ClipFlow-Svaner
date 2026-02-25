/**
 * @param {Svaner} App 
 * @param {Integer} enabled 
 * @param {signal} isListening 
 */
ServiceConfigs(App, enabled, isListening) {
    comp := Component(App, A_ThisFunc)

    onlineTextStyles := Map(
        "离线", "cRed Bold",
        "处理中...", "cBlack Norm",
        "在线", "cGreen Bold",
        "default", "cBlack Norm"
    )

    agentConfig := signal({
        interval: agent.interval,
        expiration: agent.expiration,
        collectRange: agent.collectRange
    })

    effect(agentConfig, cur => (
        agent.interval := cur.interval,
        agent.expiration := cur.expiration,
        agent.collectRange := cur.collectRange
    ))

    effect(isListening, cur => App["service-activator"].Value := cur != "离线")

    handleServiceStart(ctrl, _) {
        if (MsgBox("服务将启动，请确保 Opera 处于 InHouse 界面", "Server Agent", "4096 OKCancel") == "Cancel") {
            ctrl.Value := false
            return
        }

        isListening.set(ctrl.Value ? "在线" : "离线")
        App["interval"].Enabled := !ctrl.Value
        App["expiration"].Enabled := !ctrl.Value
        App["collect-range"].Enabled := !ctrl.Value

        SetTimer(handleInHouseWindowReset)
    }

    handleInHouseWindowReset(*) {
        if (!ImageSearch(&_, &_, 0, 0, A_ScreenWidth, A_ScreenHeight, IMAGES["error.PNG"])) {
            return
        }

        SetTimer(, 0)
        PMN_FillIn.end()
        ; close all windows
        loop {
            Send "!w"
            Sleep 100
            Send "{Up}"
            Sleep 100
            Send "{Enter}"
            Sleep 100
            Send "!c"
            utils.waitLoading()
            Send "{Esc}"
            utils.waitLoading()

            if (ImageSearch(&_, &_, 0, 0, A_ScreenWidth, A_ScreenWidth, IMAGES["opera-logo.PNG"])) {
                break
            }
        }

        ; restore In-house window
        Send "!f"
        utils.waitLoading()
        Send "{Down}"
        Sleep 100
        Send "{Enter}"
        utils.waitLoading()
    }

    comp.render := this => this.Add(
        StackBox(
            App,
            {
                name: "services-config-stackbox",
                groupbox: {
                    options: "vservice-configs Section x30 y+5 w300 r7"
                },
                checkbox: {
                    title: "服务端（后台）选项",
                    options: (enabled ? "Checked" : "") . " xs10 yp",
                    events: {
                        click: (ctrl, _) => (CONFIG.write("agentEnabled", ctrl.Value), !ctrl.Value && isListening.set("离线"))
                    }
                }, 
            },
            () => [
                ; service activation
                App.AddCheckBox("vservice-activator xs20 yp+30","启动服务").onClick(handleServiceStart),
                App.AddText("x+10", "本机: " . A_ComputerName),

                ; service state
                App.AddText("xs20 h30 yp+20 0x200", "当前服务状态: "),
                App.AddText("vonline-text w150 h30 x+1 0x200", "{1}", isListening)
                   .SetFont("cRed Bold")
                   .SetFontStyles(onlineTextStyles),

                ; collect interval
                App.AddText("xs20 w100 h20 yp+35 0x200", "处理请求间隔: "),
                App.AddEdit("vinterval w40 h20 x+1 0x200 Number", "{1}", agentConfig, ["interval"])
                   .onChange((ctrl, _) => agentConfig.update("interval", ctrl.Value)),
                App.AddText("x+5 h20 0x200", "毫秒"),

                ; expiration days
                App.AddText("xs20 w100 h20 yp+25 0x200", "保留 Profile 时长: "),
                App.AddEdit("vexpiration w40 h20 x+1 0x200", "{1}", agentConfig, ["expiration"])
                   .onChange((ctrl, _) => agentConfig.update("expiration", ctrl.Value)),
                App.AddText("x+5 h20 0x200", "天"),  

                ; collection range minutes
                App.AddText("xs20 w100 h20 yp+25 0x200", "收集代行范围: "),
                App.AddEdit("vcollect-range w40 h20 x+1 0x200", "{1}", agentConfig, ["collectRange"])
                   .onChange((ctrl, _) => agentConfig.update("collectRange", ctrl.Value)),
                App.AddText("x+5 h20 0x200", "分钟"),  
            ]
        )
    )

    return comp.render()
}