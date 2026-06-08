#Include features\flow-modes\flow-modes.ahk
#Include features\control-center\control-center.ahk
#Include modules\index.ahk

/**
 * @param {Svaner} App
 */
App(App) {
    onTop := signal(false)

    keepOnTop(*) {
        onTop.set(onTop => !onTop)
        WinSetAlwaysOnTop onTop.value, POPUP_TITLE
    }

	modules := OrderedMap(
		ProfileModifyNext, { 
			name: ProfileModifyNext.name, 
			tabs: ["后台服务"], 
			components: [ServerAgentPanel] 
		},
		ProfileModify_Group, { 
			name: ProfileModify_Group.name, 
			tabs: ["后台服务"], 
			components: [ServerAgentPanel] 
		},
		ReservationHandler, { 
			name: ReservationHandler.name, 
			tabs: ["更多设置"], 
			components: [ReservationHandlerSettings] 
		},
	)

	curModule := CONFIG.read("moduleSelected") <= modules.entries().Length ? CONFIG.read("moduleSelected") : 1
	curModuleProps := modules.values()[curModule]

	global clbListeners := ListenerController()

	render() {
		App.AddTab3("vtabs x15" . " Choose" . CONFIG.read("tabPos"), ["插件模式", curModuleProps.tabs*].append("控制中心"))
		   .onChange((ctrl, _) => CONFIG.write("tabPos", ctrl.Value)),

		App["tabs"].UseTab("插件模式")
		FlowModes(App, modules.keys())	

		curModuleProps.components.map(component => (App["tabs"].UseTab(1 + A_Index), component(App)))

		App["tabs"].UseTab("控制中心")
		ControlCenter(App)

		App["tabs"].UseTab()
	}

    return render()
}
