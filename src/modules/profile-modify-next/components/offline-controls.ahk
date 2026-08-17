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

        localDB := useFileDB(ProfileModifyNext.localDB)
        uncDB := useFileDB(ProfileModifyNext.uncDB)

        uncData := uncDB.load(, queryFilter.value["date"], queryFilter.value["range"])
        uncValidateMap := Map()
        uncValidateMap.Default := ""
        for uncProfile in uncData {
            uncValidateMap[uncProfile["idNum"]] := uncProfile
        }

        localData := localDB.load(, queryFilter.value["date"], queryFilter.value["range"])
        if (!localData.Length) {
            return
        }
        
        for localProfile in localData {
            if (uncValidateMap[localProfile["idNum"]]) {
                ; if matching idNum profile found, check each value
                for key, val in localProfile {
                    if (!uncValidateMap[localProfile["idNum"]].has(key)) {
                        continue
                    }

                    if (uncValidateMap[localProfile["idNum"]][key] != val) {
                        newProfile := JSON.stringify(localProfile)
                        date := FormatTime(uncValidateMap[localProfile["idNum"]]["regTime"], "yyyyMMdd")
                        fileName := uncValidateMap[localProfile["idNum"]]["fileName"]

                        uncDB.updateOne(newProfile, date, fileName)
                        updatedCount++
                        break
                    }
                }
            }
            else {
                uncDB.add(JSON.stringify(localProfile))
                sentCount++
            }
        }

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
