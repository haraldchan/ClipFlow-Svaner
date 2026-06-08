/**
 * 
 * @param {Svaner} App 
 * @param {signal} selectedGroup 
 */
OnDayGroups(App, selectedGroup) {
    monthFolder := Format("{1}\{2}\{2}{3}", CONFIG.read("onDayGroupFolder"), A_Year, A_MM)
    XL_FILE_PATH := ""
    arrvingGroups := signal([])

    loop files monthFolder . "\*.xlsx" {
        if (InStr(A_LoopFileName, FormatTime(A_Now, "yyyyMMdd"))) {
            XL_FILE_PATH := A_LoopFileFullPath
            break
        }
    }

    if (!XL_FILE_PATH) {
        MsgBox("未找到 OnDayGroup Excel 文件，请手动添加", POPUP_TITLE, "4096 T1")
        App.Opt("+OwnDialogs") 
        XL_FILE_PATH := FileSelect(3, , "请选择 OnDayGroup Excel 文件")
        if (!XL_FILE_PATH) {
            CONFIG.write("moduleSelected", 1)
            utils.cleanReload(WIN_GROUP)
        }
    }

    arrvingGroups.set(getBlockInfo(XL_FILE_PATH))
    getBlockInfo(fileName) {
        blockInfo := []

        Xl := ""
        try {
            Xl := ComObject("Ket.Application")
        }
        catch {
            Xl := ComObject("Excel.Application")
        }        OnDayGroupDetails := Xl.Workbooks.Open(fileName).Worksheets("Sheet1")
        loop {
            blockCodeReceived := OnDayGroupDetails.Cells(A_Index + 3, 1).Text
            blockNameReceived := OnDayGroupDetails.Cells(A_Index + 3, 2).Text
            if (!blockCodeReceived || blockCodeReceived = "Group StayOver") {
                break
            }

            blockInfo.Push(
                Map(
                    "blockName", blockNameReceived,
                    "blockCode", blockCodeReceived
                )
            )
        }
        Xl.Workbooks.Close()
        Xl.Quit()

        selectedGroup.set(blockInfo[1])
        return blockInfo
    }

    handleGroupSelect(lv, row) {
        if (!row) {
            return
        }

        selectedGroup.set(arrvingGroups.value[row])
    }

    render() {
        App.AddLink("xs20 yp+30 w100 h20 0x200", "{1}", { text: "今日团队", href: XL_FILE_PATH}).SetFont("bold s11 q4")
        App.AddListView(
            {
                lvOptions: "vblock-list xs20 y+10 w300 h300 Grid NoSortHdr @lv:label-tip"
            },
            {
                keys: ["blockCode", "blockName"],
                titles: ["BlockCode", "Block 名称"],
                widths: [100, 200]
            },
            arrvingGroups
        ).onClick(handleGroupSelect)
    }
    
    return render()
}
