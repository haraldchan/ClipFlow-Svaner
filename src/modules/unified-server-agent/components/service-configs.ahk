/**
 * @param {Svaner} App 
 * @param {Integer} enabled 
 * @param {signal} isListening 
 */
ServiceConfigs(App, enabled, isListening) {
    comp := Component(App, A_ThisFunc)

    agentConfig := signal({
        interval: agent.interval,
        expiration: agent.expiration,
        collectRange: agent.collectRange,
        serverConfig: {
            host: CONFIG.read(["serverAgent", "serverConfig", "host"]),
            pmnPool: CONFIG.read("pmnPool"),
            qmPool: CONFIG.read("qmPool"),
            isAutoRestart: CONFIG.read("isAutoRestart")
        }
    }, { name: "agentConfig" })

    effect(agentConfig, updateServerAgentConfig)
    updateServerAgentConfig(curConfig, prevConfig) {
        agent.interval := curConfig.interval
        agent.expiration := curConfig.expiration
        agent.collectRange := curConfig.collectRange
        agent.pool := curConfig.serverConfig.host . curConfig.serverConfig.pmnPool
        agent.qmPool := curConfig.serverConfig.host . curConfig.serverConfig.qmPool
        agent.isAutoRestart := curConfig.serverConfig.isAutoRestart

        if (curConfig.serverConfig.host != prevConfig.serverConfig.host) {
            CONFIG.write(["serverAgent", "serverConfig", "host"], curConfig.serverConfig.host)
        }

        if (curConfig.serverConfig.isAutoRestart != prevConfig.serverConfig.isAutoRestart) {
            CONFIG.write("isAutoRestart", curConfig.serverConfig.isAutoRestart)
        }
    }

    effect(isListening, cur => (
        App["service-activator"].Value := cur == "在线",
        App["service-activator"].Enabled := cur == "离线",
        App["online-text"].SetFont(cur == "在线" ? "cgreen bold" : "cred bold")
    ))

    handleServiceStart(ctrl, _) {
        if (ctrl.Value == true && MsgBox("服务将启动，请确保 Opera 处于 InHouse 界面", "Server Agent", "4096 OKCancel") == "Cancel") {
            ctrl.Value := false
            return
        }

        ; reset previous collected posts(after unexpected reload)
        agent.resetPostsToPending()
        isListening.set("在线")
    }

    handleServerHostDirSelect(*) {
        dir := FileSelect("D", , "选择代行任务池文件夹")
        if (!dir) {
            return
        }

        agentConfig.update(["serverConfig", "host"], dir)
    }

    handleIsAutoRestartToggle(ctrl, _) {
        agentConfig.update("isAutoRestart", ctrl.Value)
    }

    App.defineDirectives(
        "@use:sc-text", "xs15 w100 h20 yp+25 0x200"
    )

    onMount() {
        App["auto-restart"].Value := CONFIG.read(["serverAgent", "serverConfig", "isAutoRestart"])
    }

    comp.render := this => this.Add(
        StackBox(
            App, {
                name: "services-config-stackbox",
                groupbox: {
                    options: "vservice-configs Section x30 y+5 w300 h400"
                },
                checkbox: {
                    title: "服务端（后台）选项",
                    options: (enabled ? "Checked" : "") . " xs10 yp",
                    events: {
                        click: (ctrl, _) => (CONFIG.write("serviceEnabled", ctrl.Value), !ctrl.Value && isListening.set("离线"))
                    }
                },
            },
            () => [
                ; service activation
                App.AddCheckBox("vservice-activator xs15 yp+30", "启动服务").onClick(handleServiceStart),
                App.AddText("x+10", "本机: " . A_ComputerName),
                ; service state
                App.AddText("xs15 h30 yp+20 0x200", "当前服务状态: "),
                App.AddText("vonline-text w150 h30 x+1 0x200", "{1}", isListening)
                   .SetFont("bold cred"),
                ; configs
                App.AddText("@use:sc-text h30 yp+40", "服务配置").setFont("bold s10"),
                ; collect interval
                App.AddText("@use:sc-text yp+30", "处理请求间隔"),
                App.AddEdit("vinterval w40 h20 x+1 0x200 Number", "{1}", agentConfig, ["interval"])
                   .onChange((ctrl, _) => agentConfig.update("interval", ctrl.Value)),
                App.AddText("x+5 h20 0x200", "毫秒"),
                ; expiration days
                App.AddText("@use:sc-text", "保留 Profile 时长"),
                App.AddEdit("vexpiration w40 h20 x+1 0x200", "{1}", agentConfig, ["expiration"])
                   .onChange((ctrl, _) => agentConfig.update("expiration", ctrl.Value)),
                App.AddText("x+5 h20 0x200", "天"),
                ; collection range minutes
                App.AddText("@use:sc-text", "收集代行范围"),
                App.AddEdit("vcollect-range w40 h20 x+1 0x200", "{1}", agentConfig, ["collectRange"])
                   .onChange((ctrl, _) => agentConfig.update("collectRange", ctrl.Value)),
                App.AddText("x+5 h20 0x200", "分钟"),
                ; server configs
                App.AddText("@use:sc-text", "代行请求池路径"),
                App.AddEdit("vserver-host w140 h20 x+1 0x200 ReadOnly", "{1}", agentConfig, [v => v.serverConfig.host])
                   .onChange((ctrl, _) => agentConfig.update("host", ctrl.Value)),
                App.AddButton("x+1 w20 h20", "🗀").onClick(handleServerHostDirSelect),
                ; service restart option
                App.AddText("@use:sc-text", "错误自动重启"),
                App.AddCheckBox("vauto-restart h20 x+1 @text:align-center", "启用")
                   .onClick(handleIsAutoRestartToggle)
            ]
        )
    )

    return (
        comp.render(),
        onMount()
    )
}
