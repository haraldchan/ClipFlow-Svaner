#Include guest-profile-details.ahk

/**
 * @param {Svaner} App 
 * @param {()=>Datebase} db 
 * @param {signal} listContent 
 * @param {signal} queryFilter 
 * @param {signal} searchBy 
 * @param {Func} handleFillin 
 * @param {Func} handleListUpdate 
 * @param {SvanerListView}
 */
GuestProfileList(App, db, listContent, queryFilter, searchBy, handleFillin, handleListUpdate) {
    getSelectedCell(LV, row, key) {
        return LV.GetText(row, App["guest-profile-list"].svanerWrapper.titleKeys.findIndex(item => item == key))
    }
 
    handleUpdateItem(LV, row) {
        selectedItem := listContent.value.find(item => item["idNum"] == getSelectedCell(LV, row, "idNum"))
        selectedItem["roomNum"] := getSelectedCell(LV, row, "roomNum")
    
        db().put(queryFilter.value.date, selectedItem)
    }

    showProfileDetails(LV, row, *) {
        if (row == 0 || row > 10000) {
            return
        }

        selectedItem := listContent.value.find(item => item["idNum"] == getSelectedCell(LV, row, "idNum"))
        GuestProfileDetails(selectedItem, db, handleFillin, handleListUpdate)
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

        db().put(queryFilter.value.date, selectedItem)
    }

    copyIdNumber(LV, row) {
        if (row == 0 || row > 10000) {
            return
        }
        
        selectedItem := listContent.value.find(item => item["idNum"] == getSelectedCell(LV, row, "idNum"))
        A_Clipboard := selectedItem["idNum"]
        
        MsgBox(Format("已复制客人 {} 证件号码：{}", selectedItem["name"], selectedItem["idNum"]),, "4096 T2 iconi")
    }

    handleDoubleClick(LV, row) {
        if (searchBy.value == "waterfall") {
            markAsPrimary(LV, row)
        }
        else {
            copyIdNumber(LV, row)
        }
    }

    return App.AddListView(
            {
                lvOptions: "vguest-profile-list Grid -ReadOnly -Multi @lv:label-tip @align[x]:date y+10 w658 h320",
                itemOptions: ""
            },
            {
                keys: ["roomNum","name", "gender", "idType", "idNum", "addr"],
                titles: ["房号", "姓名", "性别", "类型", "证件号码", "地址"],
                widths: [70, 120, 45, 80, 180, 150]
            }, 
            listContent
        ).SetFont("s10")
         .onContextMenu(showProfileDetails)
         .onDoubleClick(handleDoubleClick)
         .onItemEdit(handleUpdateItem)
         .focusOnUpdate()
}
