/**
 * @param {signal} settingSignal 
 * @param {signal} profiles 
 */
PMN_Settings(settingSignal, profiles) {
    if (WinExist("PMN Settings")) {
        WinActivate("PMN Settings")
        return
    }

    Win := Svaner({
        gui: {
            title: "PMN Settings"
        },
        font: {
            name: "微软雅黑"
        },
        events: {
            close: handleWinClose,
        }
    })

    handleWinClose(*) {
        if (!Win["export-btn"].Enabled) {
            Msgbox("旅客信息导出中, 请勿关闭此窗口", POPUP_TITLE, "4096 T1 iconi")
            return true
        }

        Win.Destroy()
    }

    handleExportDirSelect(*) {
        Win.Opt("+OwnDialogs")
        selected := FileSelect("D",, "请选择导出文件夹")
        if (!selected) {
            return
        }

        Win["export-dest"].Value := selected
    }

    handleExportProfiles(*) {
        Win["export-btn"].Enabled := false

        exportDest := Win["export-dest"].Value
        PsbSheetExporter.export(profiles.value, exportDest, Win["progress"])
        
        Win["export-btn"].Enabled := true
        Win["progress"].Value := 1
    }

    onMount() {
        Win["ow"].Value := settingSignal.value["fillOverwrite"]
    }

    render() {
        StackBox(Win,
            {
                name: "description-stackbox",
                font: { options: "bold" },
                groupbox: {
                    title: "使用说明",
                    options: "Section x10 w280 h110"
                }
            },
            () => [
                Win.AddText("xs10 yp+25 w260 h20", "点击房号 | F2`t- 修改房号"),
                Win.AddText("xs10 yp+20 w260 h20", "鼠标右键`t- 显示详细信息"),
                Win.AddText("xs10 yp+20 w260 h20", "双击信息`t- (主界面中) 复制身份证号"),
                Win.AddText("xs10 yp+20 w260 h20", "`t`t- (详情信息) 复制单条信息"),
            ]
        )
        StackBox(Win, 
            {
                name: "hotkeys-stackbox",
                font: { options: "bold" },
                groupbox: {
                    title: "快捷键",
                    options: "Section x10 w280 h150"
                }
            },
            () => [
                Win.AddText("xs10 yp+25 w260 h20", "Alt+左/右`t- 日期搜索翻页"),
                Win.AddText("xs10 yp+20 w260 h20", "Alt+上/下`t- 增减搜索时间"),
                Win.AddText("xs10 yp+20 w260 h20", "Alt+F`t`t- 搜索框"),
                Win.AddText("xs10 yp+20 w260 h20", "Alt+R`t`t- 根据条件搜索"),
                Win.AddText("xs10 yp+20 w260 h20", "Alt+A`t`t- (瀑流模式下)全选搜索结果"),
                Win.AddText("xs10 yp+20 w260 h20", "Enter`t`t- 填入信息到Profile"),
            ]
        )
        StackBox(Win, 
            {
                name: "setting-options-stackbox",
                font: { options: "bold" },
                groupbox: {
                    title: "设置选项",
                    options: "Section x10 w280 h55"
                }
            },
            () => [
                Win.AddCheckbox("vow xs10 yp+25 w260 h20", "默认覆盖填入（直接在原 Profile 修改）")
                   .onClick((ctrl, _) => settingSignal.update("fillOverwrite", ctrl.value))
            ]
        )
        StackBox(Win, 
            {
                name: "export-stackbox",
                font: { options: "bold" },
                groupbox: {
                    title: Format("旅客信息导出 (已读入: {})", profiles.value.Length),
                    options: "Section x10 w280 h75"
                }
            },
            () => [
                Win.AddEdit("vexport-dest xs10 yp+25 w100 h20 ReadOnly", A_Desktop),
                Win.AddButton("x+10 w70 h20", "导出至...").onClick(handleExportDirSelect),
                Win.AddButton("vexport-btn x+10 w70 h20", "开始导出").onClick(handleExportProfiles),
                Win.gui.AddProgress("vprogress xs10 yp+30 w260 h10 c4592D8 BackgroundD6DEE8 " . Format("range1-{}", profiles.value.Length || 1))
            ]
        )
    }

    return (
        render(),
        onMount(),
        Win.Show()
    )
}