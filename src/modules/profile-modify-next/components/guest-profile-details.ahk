/**
 * 
 * @param {Mao} selectedGuest 
 * @param {Func} fillIn 
 */
GuestProfileDetails(selectedGuest, fillIn) {
    Profile := Gui("+AlwaysOnTop", "Profile Details")
    Profile.SetFont(, "微软雅黑")

    fieldIndex := OrderedMap(
        "roomNum", "房号",
        "name", "全名",
        "gender", "性别",
        "birthday", "生日",
        "guestType", "旅客类型",
        "idType", "证件类型",
        "idNum", "证件号码",
        "addr", "地址",
        "tel", "联系电话",
        "regTime", "登记时间"
    )

    listInitialize(selectedGuest, fieldIndex) {
        LV := Profile.getCtrlByType("ListView")

        for key, field in fieldIndex {
            val := selectedGuest.has(key) ? selectedGuest[key] : ""
            if (key == "regTime") {
                val := FormatTime(val, "yyyy/MM/dd HH:mm")
            }

            LV.Add(, field, val)
        }
    }

    copyListField(LV, row) {
        A_Clipboard := LV.GetText(row, 2)
        key := LV.GetText(row, 1)
        MsgBox(Format("已复制信息: `n`n{1} : {2}", key, A_Clipboard), POPUP_TITLE, "4096 T1")
    }

    fillInPms(*){
        profile.Destroy()
        fillIn()
    }

    return (
        Profile.AddListView("vguestProfile Grid w230 r10", ["信息字段", "证件信息"]).onDoubleClick(copyListField),
        listInitialize(selectedGuest, fieldIndex),
        
        Profile.AddButton("h30 w110", "关 闭 (&C)").onClick((*) => profile.Destroy()),
        Profile.AddButton("x+10 h30 w110 Default", "填   入").onClick(fillInPms),
        Profile.Show()
    )
}