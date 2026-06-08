/**
 * @param {Svaner} App 
 * @param {Map} params
 */
RHS_SettingsWholeSale(App, params) {
    agent := params["agent"]
    saveParams(ctrl, _) {
        if (ctrl.Text == "已保存") {
            return
        }

        CONFIG.write(agent, {
            agent: agent,
            profileName: App[agent . "-profileName"].Value,
            profileType: App[agent . "-isTA"].Value == true ? "Travel Agent" : "Company",
            ratecode: [App[agent . "-bbf0"].Value, App[agent . "-bbf1"].Value, App[agent . "-bbf2"].Value],
            resType: App[agent . "-resType"].Value,
            market: App[agent . "-market"].Value,
            source: App[agent . "-source"].Value
        })

        ctrl.Text := "已保存"
        SetTimer(() => ctrl.Text := "保 存", -1000)
    }

    comp := Component(App, agent)
    comp.render := this => this.Add(
        ; profile
        App.AddGroupBox("Section x25 y70 w330 h100", "基本信息").SetFont("bold"),
        ; profile name
        App.AddText("xs10 yp+25 w65 h25 0x200", "Profile 名称"),
        App.AddEdit("v" . agent . "-profileName" . " x+10 h25 w230", params["profileName"]),
        ; profile type
        App.AddText("xs10 y+10 w65 h25 0x200", "Profile 类型"),
        App.AddRadio("v" . agent . "-isTA" . " x+20 h25 " . (params["profileType"] == "Travel Agent" ? "Checked" : ""), "Travel Agent"),
        App.AddRadio("x+10 h25 " . (params["profileType"] == "Company" ? "Checked" : ""), "Company"),

        ; related fields
        App.AddGroupBox("Section x25 y+30 w330 h135", "预订填入内容").SetFont("bold"),
        ; rate code
        App.AddText("xs10 yp+25 w65 h25 0x200", "Rate Code"),
        App.AddEdit("v" . agent . "-bbf0" . " x+10 h25 w70", params["ratecode"][1]),
        App.AddEdit("v" . agent . "-bbf1" . " x+10 h25 w70", params["ratecode"][2]),
        App.AddEdit("v" . agent . "-bbf2" . " x+10 h25 w70", params["ratecode"][3]),
        ; res. type
        App.AddText("xs10 y+10 w65 h25 0x200", "Res. Type"),
        App.AddEdit("v" . agent . "-resType" . " x+10 h25 w230", params["resType"]),    
        ; market code
        App.AddText("xs10 y+10 w65 h25 0x200", "预订来源"),
        App.AddText("x+10 h25 0x200", "Mkt."),
        App.AddEdit("v" . agent . "-market" . " x+10 h25 w75", params["market"]), 
        ; source code
        App.AddText("x+13 h25 0x200", "Src."),
        App.AddEdit("v" . agent . "-source" . " x+10 h25 w75", params["source"]),

        ; save
        App.AddButton("v" . agent . "-save" . " x280 y+30 h30 w80", "保 存").onClick(saveParams)
    )

    return comp
}