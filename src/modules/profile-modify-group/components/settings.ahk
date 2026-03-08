/**
 * @param {signal} fetchPeriod
 */
PMG_Settings(fetchPeriod) {
    if (WinExist("PMG Settings")) {
        return
    }

    Settings := Svaner({
        gui: { title: "PMG Settings" },
        font: { name: "微软雅黑" }
    })

    helpInfo := "
    (
        =========== 使用说明 ==========

        1. 从 “今日团队” 列表中选择需要 Modify
           的团队。

        2. 点击 “获取旅客” 从 Opera 中保存团队
           资料（XML 格式团单）。
           - 请关闭 Opera 窗口中的子窗口；
           - 如先前已保存过则会直接读取。

        3. 点击 “开始录入” 开始 Modify。
           - 可通过复选框选择需要录入的客人档案
            （默认为全选）

        =========== 设置选项 ==========
    )"

    return (
        Settings.AddText("x10 w250", helpInfo),

        ; fetchPeriod setting
        Settings.AddText("x10 w150 h25 0x200", "获取旅客时间范围（小时）："),
        Settings.AddEdit("vfp w80 h25 x+10", "{1}", fetchPeriod),
        
        ; btns
        Settings.AddButton("x10 y+15 w120 h35", "取 消(&C)").onClick((*) => Settings.Hide()),
        Settings.AddButton("x+5 w120 h35", "保 存(&S)").onClick((*) => (
            fetchPeriod.set(Settings.getCtrlByName("fp").Value),
            Sleep(200),
            Settings.Hide()
        )),

        Settings.Show()
    )
}
