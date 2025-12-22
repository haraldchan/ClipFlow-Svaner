/**
 * @param {Svaner} App 
 */
RHS_WorkflowOta(App) {
    wfConfig := CONFIG.read("workflow-ota")

    saveWorkflow(*) {
        form := JSON.parse(JSON.stringify(App.Submit(false)))
        CONFIG.write("workflow-ota", {
            profile: form["wf-profile"],
            routing: form["wf-routing"],
            resType: form["wf-resType"],
            market: form["wf-market"],
            source: form["wf-source"],
        })
    }

    onMount() {
        for ctrl in App.gui {
            if (ctrl.Name.includes("wf")) {
                ctrl.Value := wfConfig[ctrl.Name.replace("wf-", "")]
            }
        }
    }

    return (
        App.AddText("x400 y100 w200", "录入流程设置").SetFont("bold s10.5"),
        App.AddText("x400 y+10", "启用或关闭部分预订录入流程。"),

        ; controller check-boxes
        App.AddCheckbox("vwf-profile x400 y+20", "录入 Profile").onClick(saveWorkflow),
        App.AddCheckbox("vwf-routing x400 y+10", "录入 Routing").onClick(saveWorkflow),
        App.AddCheckbox("vwf-resType x400 y+10", "录入 Res. Type").onClick(saveWorkflow),
        App.AddCheckbox("vwf-market x400 y+10", "录入 Market Code").onClick(saveWorkflow),
        App.AddCheckbox("vwf-source x400 y+10", "录入 Source Code").onClick(saveWorkflow),

        onMount()
    )
}
