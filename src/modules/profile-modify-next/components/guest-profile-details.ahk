/**
 * 
 * @param {Mao} selectedGuest 
 * @param {Func} fillIn 
 */
GuestProfileDetails(selectedGuest, fillIn) {
    Profile := Svaner({
        gui: {
            options: "+AlwaysOnTop",
            title: "Profile Details"
        },
        font: {
            name: "微软雅黑"
        }
    })

    timeoutCount := 0
    TIMEOUT_MAX_SECOND := 60

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
        LV := Profile["profile"]

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

    detectWindowIsActive(*) {
        timeoutCount := !WinActive(Profile.gui.Hwnd) ? timeoutCount + 1 : 0

        if (timeoutCount >= TIMEOUT_MAX_SECOND) {
            SetTimer(, 0)
            Profile.Destroy()
        }
    }

    handleClose(*) {
        SetTimer(detectWindowIsActive, 0)
        Profile.Destroy()
    }

    fillMode := signal("填入Profile")
    handleFillModeSwitch(*) {
        fillMode.set(cur => cur == "填入Profile" ? "填入旅安" : "填入Profile")
    }


    fillInfo(*) {
        SetTimer(detectWindowIsActive, 0)
        Profile.Hide()

        if (fillMode.value == "填入Profile") {
            fillIn()
        }
        else {
            PMN_FillPSB.fill(selectedGuest)
        }

        Profile.Destroy()
    }

    onMount() {
        listInitialize(selectedGuest, fieldIndex)
        Profile.Show()

        SetTimer(detectWindowIsActive, 1000)
    }

    render() {
        Profile.AddListView("vprofile Grid w230 r10", ["信息字段", "证件信息"]).onDoubleClick(copyListField)

        Profile.AddButton("h30 w110", "关 闭 (&C)").onClick(handleClose)
        Profile.AddButton("x+10 h30 w110 Default", "{1}", fillMode)
            .onClick(fillInfo)
            .onContextMenu(handleFillModeSwitch)

        onMount()
    }

    return render()
}