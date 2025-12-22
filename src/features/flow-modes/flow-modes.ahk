/**
 * @param {Svaner} App 
 * @param {Array<Class>} modules 
 */
FlowModes(App, modules) {
	moduleNames := modules.map(module => module.name)

	moduleSelectedStored := CONFIG.read("moduleSelected")
	if (!moduleSelectedStored) {
		moduleSelectedStored := 1
		CONFIG.write("moduleSelected", 1)
	}

    moduleSelected := moduleSelectedStored > modules.Length ? 1 : moduleSelectedStored

	handleModuleChange(ctrl, _) {
		CONFIG.write("moduleSelected", ctrl.value)
		utils.cleanReload(WIN_GROUP)
	}

	return (
		App.AddDDL("y+10 w250 Choose" . moduleSelected, moduleNames).onChange(handleModuleChange),
		modules[moduleSelected].USE(App)
	)
}