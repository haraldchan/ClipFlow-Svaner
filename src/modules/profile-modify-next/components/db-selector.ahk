/**
 * @param {Svaner} App 
 */
DBSelector(App) {
    dbMap := OrderedMap(
        "uncDB", "Share盘",
        "localDB", "本地硬盘"
    )

    handleDBSelect(ctrl, _) {
        selectedDB := dbMap.getKey(ctrl.Text)
        App["send-to-unc"].Enabled := selectedDB == "localDB"

        ProfileModifyNext.usingDB.set(selectedDB)
    }

    handleSendToUNC(*) {
        if (!DirExist(UNC_PATH)) {
            MsgBox("无法连接到 Share 盘", POPUP_TITLE, "4096 T2 iconx")
            return
        }

        sentCount := 0

        localDB := useFileDB(ProfileModifyNext.localDB)
        uncDB := useFileDB(ProfileModifyNext.uncDB)

        uncData := uncDB.load(, , 60 * 24)
        uncValidateMap := Map()
        uncValidateMap.Default := ""
        for item in uncData {
            uncValidateMap[item["idNum"]] := item
        }

        localData := localDB.load(, , 60 * 24)
        for item in localData {
            if (uncValidateMap[item["idNum"]]) {
                continue
            }

            uncDB.add(JSON.stringify(item))
            sentCount++
        }

        MsgBox("已将本地数据发送至 Share 盘数据库。`n`n本次共发送 " . sentCount . " 条", POPUP_TITLE, "4096 T5 iconi")
    }

    render() {
        App.AddText("@align[y]:select-all-btn xs498 w70 h25 0x200", "当前数据库")
        App.AddDDL(
            "x+1 w80 Choose" . dbMap.keys().findIndex(k => k == ProfileModifyNext.usingDB.value), 
            dbMap.values()
        ).onChange(handleDBSelect)
        App.AddButton("vsend-to-unc x+1 w25 h25 Disabled", "📤").onClick(handleSendToUNC)
    }

    return render()
}
