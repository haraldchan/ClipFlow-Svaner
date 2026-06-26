PMN_Settings(settingSignal) {
    if (WinExist("PMN Settings")) {
        return
    }

    Win := Gui(, "PMN Settings")
    Win.SetFont(, "微软雅黑")

    helpInfo := "
    (
        =========== 使用说明 ===========
        
        点击房号`t- 修改房号
        鼠标右键`t- 显示详细信息
        双击信息`t- (主界面中) 复制身份证号
        `t`t- (详情信息) 复制单条信息
        
        ============ 快捷键 ============
        
        Alt+左/右`t- 日期搜索翻页
        Alt+上/下`t- 增减搜索时间  
        Alt+F`t`t- 搜索框
        Alt+R`t`t- 根据条件搜索
        Alt+A`t`t- (瀑流模式下)全选搜索结果
        Enter`t`t- 填入信息到Profile
        
        =========== 设置选项 ===========
    )"

    handleLaunchWSReader(*) {
        Run(A_ScriptDir . "\ws-reader\ws-reader.html")
        Win.Destroy()
    }

    onMount() {
        Win["ow"].Value := settingSignal.value["fillOverwrite"]
    }

    render() {
        Win.AddText("x10 w260", helpInfo)

        ; overwrite fill-in
        Win.AddCheckbox("vow x10 w260", "默认覆盖填入（直接在原 Profile 修改）")
           .onClick((ctrl, _) => settingSignal.update("fillOverwrite", ctrl.value))
        
        ; launch ws reader
        Win.AddText("x10 y+10 w90 h20 0x200", "WS Reader")
        Win.AddButton("x+1 w80 h20", "启 动").onClick(handleLaunchWSReader)
    }

    return (
        render(),
        onMount(),
        Win.Show()
    )
}