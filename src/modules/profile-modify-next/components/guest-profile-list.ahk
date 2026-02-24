#Include "./guest-profile-details.ahk"

/**
 * @param {Svaner} App 
 * @param {useFileDB} db 
 * @param {signal} listContent 
 * @param {signal} queryFilter 
 * @param {signal} searchBy 
 * @param {Func} fillPmsProfile 
 */
GuestProfileList(App, db, listContent, queryFilter, searchBy, fillPmsProfile) {
    columnDetails := {
        keys: ["roomNum","name", "gender", "idType", "idNum", "addr"],
        titles: ["房号", "姓名", "性别", "类型", "证件号码", "地址"],
        widths: [70, 120, 45, 80, 180, 150]
    }

    options := {
        lvOptions: "vguest-profile-list Grid -ReadOnly -Multi @lv:label-tip @align[x]:date y+10 w658 h320",
        itemOptions: ""
    }

    getSelectedCell(LV, row, key) {
        return LV.GetText(row, columnDetails.keys.findIndex(item => item == key))
    }

    copyIdNumber(LV, row) {
        A_Clipboard := getSelectedCell(LV, row, "idNum")
        MsgBox(Format("已复制证件号码: `n`n{1} : {2}", getSelectedCell(LV, row, "name"), A_Clipboard), POPUP_TITLE, "4096 T1")
    }
 
    handleUpdateItem(LV, row) {
        selectedItem := listContent.value.find(item => item["idNum"] == getSelectedCell(LV, row, "idNum"))
        selectedItem["roomNum"] := getSelectedCell(LV, row, "roomNum")
    
        SetTimer(() => db.updateOne(JSON.stringify(selectedItem), queryFilter.value["date"], selectedItem["fileName"]), -1)
    }

    showProfileDetails(LV, row, *) {
        if (row == 0 || row > 10000) {
            return
        }

        selectedItem := listContent.value.find(item => item["idNum"] == getSelectedCell(LV, row, "idNum"))
        GuestProfileDetails(selectedItem, fillPmsProfile)
    }

    markAsPrimary(LV, row) {
        if (searchBy.value != "waterfall") {
            return
        }

        selectedItem := listContent.value.find(item => item["idNum"] == getSelectedCell(LV, row, "idNum"))
        if (!selectedItem["name"].includes("👤")) {
            selectedItem["name"] := "👤" . selectedItem["name"]
        } else {
            selectedItem["name"] := selectedItem["name"].replace("👤", "")
        }

        LV.Modify(row,,, selectedItem["name"])

        SetTimer(() => db.updateOne(JSON.stringify(selectedItem), queryFilter.value["date"], selectedItem["fileName"]), -1)
    }

    return (    
        App.AddListView(options, columnDetails, listContent)
           .onContextMenu(showProfileDetails)
           .onDoubleClick(markAsPrimary)
           .onItemEdit(handleUpdateItem)
    )
}