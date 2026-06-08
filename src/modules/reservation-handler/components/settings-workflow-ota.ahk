/**
 * @param {Svaner} App 
 */
RHS_WorkflowOta(App) {
    wfConfig := CONFIG.read("workflow-ota")

    saveWorkflow(*) {
        CONFIG.write("workflow-ota", {
            profile: App["wf-profile"].Value,
            routing: App["wf-routing"].Value,
            resType: App["wf-resType"].Value,
            market: App["wf-market"].Value,
            source: App["wf-source"].Value,
        })
    }

    onMount() {
        App["#rhwf"].forEach(ctrl => (
            ctrl.Value := wfConfig[ctrl.Name.replace("wf-", "")],
            ctrl.onClick(saveWorkflow)
        ))
    }

    render() {
        App.AddText("x400 @relative[y+15]:cur-agent w200 h20", "录入流程设置").SetFont("bold s10.5")
        App.AddText("x400 y+10", "启用或关闭部分预订录入流程。")

        ; controller check-boxes
        App.AddCheckbox("#rhwf vwf-profile x400 y+20", "录入 Profile")
        App.AddCheckbox("#rhwf vwf-routing x400 y+10", "录入 Routing")
        App.AddCheckbox("#rhwf vwf-resType x400 y+10", "录入 Res. Type")
        App.AddCheckbox("#rhwf vwf-market x400 y+10", "录入 Market Code")
        App.AddCheckbox("#rhwf vwf-source x400 y+10", "录入 Source Code")

        onMount()
    }

    return render()
}
