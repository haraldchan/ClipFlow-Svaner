#Include features\flow-modes\flow-modes.ahk
#Include features\control-center\control-center.ahk
#Include modules\index.ahk

/**
 * @param {Svaner} App
 */
App(App) {
	modules := OrderedMap(
		ProfileModifyNext, {
			name: ProfileModifyNext.name,
			tabComponents: Map("后台服务", ServerAgentPanel)
		},
		ProfileModify_Group, {
			name: ProfileModify_Group.name,
			tabComponents: Map("后台服务", ServerAgentPanel)
		},
		ReservationHandler, {
			name: ReservationHandler.name,
			tabComponents: Map("更多设置", ReservationHandlerSettings)
		},
	)

	curModule := CONFIG.read("moduleSelected") <= modules.entries().Length ? CONFIG.read("moduleSelected") : 1
	curModuleProps := modules.values()[curModule]

	global clbListeners := ListenerController()

	render() {
		App.AddTab3("vtabs x15" . " Choose" . CONFIG.read("tabPos"), OrderedMap([
			; main tab
			"插件模式", () => FlowModes(App, modules.keys()),
			
			; additional tab components
			curModuleProps.tabComponents.entries().map((entry) => [entry[1], () => entry[2](App)]),
			
			; control center
			"控制中心", () => ControlCenter(App)
		].flat()*))
	}

	return render()
}