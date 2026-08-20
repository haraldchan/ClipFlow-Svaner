/**
 * @param {Svaner} App 
 * @param {signal} queryFilter
 */
OfflineControls(App, queryFilter) {
    dbMap := OrderedMap(
        "uncDB", "Share盘",
        "localDB", "本地硬盘"
    )

    handleDBSelect(ctrl, _) {
        if (!FileExist(ProfileModifyNext.uncDB.dbPath)) {
            MsgBox("无法连接到 Share 盘", POPUP_TITLE, "4096 T2 iconx")
            ctrl.Value := dbMap.values().findIndex(name => name == "本地硬盘")
            return
        }

        selectedDB := dbMap.getKey(ctrl.Text)
        App["send-to-unc"].Enabled := selectedDB == "localDB"

        ProfileModifyNext.usingDB.set(selectedDB)
    }

    handleSendToUNC(*) {
        if (!DirExist(ProfileModifyNext.uncDB.main)) {
            MsgBox("无法连接到 Share 盘", POPUP_TITLE, "4096 T2 iconx")
            return
        }

        sentCount := 0
        updatedCount := 0

        localDB := DateBase(ProfileModifyNext.localDB)
        uncDB := DateBase(ProfileModifyNext.uncDB)

        localProfiles := localDB.load(queryFilter.value.date, "roomNum", 1440)
        if (!localProfiles.Length) {
            return
        }

        for (profile in localProfiles) {
            res := uncDB.add(JSON.stringify(profile), queryFilter.value.date)
            if (res is Error) {
                MsgBox("发送失败。`n`n错误信息：`n" . res.Message, POPUP_TITLE, "4096 T1.5 icon!")
                return
            }

            res == "added" ? sentCount++ : updatedCount++
        }

        localDB.close()
        uncDB.close()

        MsgBox(
            Format("已将本地数据同步至 Share 盘数据库。`n`n本次共发送 {1} 条，更新 {2} 条", sentCount, updatedCount),
            POPUP_TITLE,
            "4096 T5 iconi"
        )
    }

    handleLaunchWSReader(*) {
        Run(A_ScriptDir . "\ws-reader\ws-reader.html")
    }

    render() {
        App.AddButton("@align[y]:select-all-btn xs410 w80 h25", "WS Reader").onClick(handleLaunchWSReader)
        App.AddText("@align[y]:select-all-btn x+15 w70 h25 0x200", "当前数据库")
        App.AddDropDownList(
            "x+1 w80 Choose" . dbMap.keys().findIndex(k => k == ProfileModifyNext.usingDB.value), 
            dbMap.values()
        ).onChange(handleDBSelect)
        App.AddButton("vsend-to-unc x+1 w25 h25 Disabled", "📤").onClick(handleSendToUNC)
    }

    return render()
}
