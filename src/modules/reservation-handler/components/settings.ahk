/**
 * @param {Svaner} App 
 */
ReservationHandlerSettings(App) {
    entryParams := CONFIG.read("entryParams")

    agentComponentSet := OrderedMap(
        "kingsley",          (*) => RHS_SettingsWholeSale(App, entryParams["kingsley"]),
        "jielv",             (*) => RHS_SettingsWholeSale(App, entryParams["jielv"]),
        "ctrip-ota",         (*) => RHS_SettingsCtrip(App, entryParams["ctrip-ota"]),
        "ctrip-ota-shanglv", (*) => RHS_SettingsCtrip(App, entryParams["ctrip-ota-shanglv"]),
        ; "ctrip-business",    (*) => RHS_SettingsCtrip(App, entryParams["ctrip-business"]),
        "meituan",           (*) => RHS_SettingsWholeSale(App, entryParams["meituan"]),
    )

    selectedAgent := signal(agentComponentSet.keys()[1])

    agentNames := agentComponentSet.keys().map(a => entryParams[a]["name"])

    return (
        App.AddText("x30 y+10 w65 h25 0x200", "当前 Agent").SetFont("Bold"),
        App.AddDDL("x+10 w250 Choose1", agentNames)
           .onChange((ctrl, _) => selectedAgent.set(agentComponentSet.keys()[ctrl.Value])),

        Dynamic(App, selectedAgent, agentComponentSet),
        RHS_WorkflowOta(App)
    )
}