#Include features\flow-modes\flow-modes.ahk
#Include features\clipboard-history\clipboard-history.ahk
#Include modules\index.ahk

/**
 * @param {Svaner} App
 */
App(App) {
    onTop := signal(false)
    generalTabs := ["插件模式", "剪贴板历史"]

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
		; ProfileModifyNext_Group, { 
		; 	name: ProfileModifyNext_Group.name, 
		; 	tabs: ["后台服务"], 
		; 	components: [ServerAgentPanel] 
		; },
		ReservationHandler, { 
			name: ReservationHandler.name, 
			tabs: ["更多设置"], 
			components: [ReservationHandlerSettings] 
		},
	)

	curModule := CONFIG.read("moduleSelected") <= modules.entries().Length ? CONFIG.read("moduleSelected") : 1
	curModuleProps := modules.values()[curModule]

    return (
		App.AddTab3("vtabs x15" . " Choose" . CONFIG.read("tabPos"), generalTabs.append(curModuleProps.tabs))
		   .onChange((ctrl, _) => CONFIG.write("tabPos", ctrl.Value)),

		App["tabs"].UseTab("插件模式"), 
		FlowModes(App, modules.keys()),	

		App["tabs"].UseTab("剪贴板历史"),
		ClipboardHistory(App),

		curModuleProps.components.map(component => (
			App["tabs"].UseTab(generalTabs.Length + A_Index), 
			component(App)
		)),

		App["tabs"].UseTab()
    )
}