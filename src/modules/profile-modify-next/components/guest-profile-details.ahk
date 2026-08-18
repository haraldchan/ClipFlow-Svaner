/**
 * 
 * @param {Map} selectedGuest 
 * @param {()=>Datebase} db
 * @param {Func} handleFillin 
 * @param {Func} handleListUpdate 
 */
GuestProfileDetails(selectedGuest, db, handleFillin, handleListUpdate) {
    if (selectedGuest["idNum"] == "No Data") {
        return
    }

    Win := Svaner({
        gui: {
            options: "+AlwaysOnTop",
            title: "Profile Details"
        },
        font: {
            name: "微软雅黑"
        },
    })
    Win.gui.BackColor := "0xF9F9F9"

    timeoutCount := 0
    TIMEOUT_MAX_SECOND := 60

    detectWindowIsActive(*) {
        timeoutCount := !WinActive(Win.gui.Hwnd) ? timeoutCount + 1 : 0

        if (timeoutCount >= TIMEOUT_MAX_SECOND) {
            SetTimer(, 0)
            Win.Destroy()
        }
    }

    handleClose(*) {
        if (isUpdated) {
            handleListUpdate()
        }

        SetTimer(detectWindowIsActive, 0)
        Win.Destroy()
    }

    fillMode := signal("填入Profile")
    handleFillModeSwitch(*) {
        fillMode.set(cur => cur == "填入Profile" ? "填入旅安" : "填入Profile")
    }

    fillInfo(*) {
        SetTimer(detectWindowIsActive, 0)
        Win.Hide()

        if (fillMode.value == "填入Profile") {
            handleFillin()
        }
        else {
            PMN_FillPSB.fill(selectedGuest)
        }

        Win.Destroy()
    }

    isUpdated := false
    handleUnlock(ctrl, _) {
        ctrl.Text := "🔓"

        for (control in Win.gui) {
            if (control.Name == "reg-time") {
                continue
            }

            if (control is Gui.Edit) {
                control.Opt("-ReadOnly")
            }
            else {
                control.Enabled := true
            }
        }
    }

    handleProfileUpdate(ctrl, _) {
        isUpdated := true

        newValue := ctrl is Gui.DateTime ? ctrl.Value : ctrl.Text
        if (ctrl.Name == "birthday") {
            newValue := FormatTime(newValue, "yyyy-MM-dd")
        }

        if (selectedGuest["guestType"] == "港澳台旅客" && ctrl.name == "addr") {
            selectedGuest["region"] := ctrl.Text
        }
        else if (selectedGuest["guestType"] == "国外旅客" && ctrl.name == "addr") {
            selectedGuest["country"] := ctrl.Text
        }
        else {
            selectedGuest[ctrl.Name.toCase("camel")] := newValue
        }

        db().put(FormatTime(selectedGuest["regTime"], "yyyyMMdd"), selectedGuest)
    }

    onMount() {
        Win.Show()
        SetTimer(detectWindowIsActive, 1000)
    }

    Win.defineDirectives(
        "@use:bold", ctrl => ctrl.SetFont("bold"),
        "@use:pd-label", "xs10 yp+30 w55 h22 0x200 @use:bold",
        "@use:pd-edit", "x+5 w150 h22 ReadOnly",
    )

    idTypes := [
        "身份证",
        "国内护照",
        "港澳通行证",
        "港澳居民来往内地通行证",
        "台湾居民来往大陆通行证",
        "港澳台居民居住证",
        "普通护照",
        "外国人永久居留证",
    ]

    defineStackboxHeight() {
        base := 320

        if (selectedGuest["guestType"] != "内地旅客") {
            base += 70
        }

        if (selectedGuest["guardianInfo"].Capacity > 0) {
            base += 110
        }

        return "h" . String(base)
    }

    render() {
        StackBox(Win, {
            font: {
                name: "Tahoma",
                options: "s12 bold"
            },
            groupbox: {
                title: "Profile 详情",
                options: "Section x20 w230 " . defineStackboxHeight(),
            }
        },
            () => [
                ; edit btn
                Win.AddText("vlock xs205 yp+0 w20 h25", "🔒").onClick(handleUnlock).SetFont("s12"),
                ; room no.
                Win.AddText("@use:pd-label yp+24", "房号"),
                Win.AddEdit("vroomNum @use:pd-edit", selectedGuest["roomNum"]).onChange(handleProfileUpdate),
                ; name
                Win.AddText("@use:pd-label", "全名"),
                Win.AddEdit("vname @use:pd-edit", selectedGuest["name"]).onChange(handleProfileUpdate),
                selectedGuest["guestType"] != "内地旅客" && [
                    Win.AddText("@use:pd-label", "英文姓"),
                    Win.AddEdit("vname-last @use:pd-edit", selectedGuest["nameLast"]).onChange(handleProfileUpdate),
                    Win.AddText("@use:pd-label", "英文名"),
                    Win.AddEdit("vname-first @use:pd-edit", selectedGuest["nameFirst"]).onChange(handleProfileUpdate),
                ],
                ; gender
                Win.AddText("@use:pd-label", "性别"),
                Win.AddDDL("vgender x+5 w150 Disabled Choose" . (selectedGuest["gender"] == "男" ? 1 : 2), ["男", "女"]).onChange(handleProfileUpdate),
                ; id type/num
                Win.AddText("@use:pd-label", "证件信息"),
                Win.AddDDL("vid-type x+5 w150 0x3 Disabled Choose" . (idTypes.findIndex(t => t == selectedGuest["idType"])), idTypes).onChange(handleProfileUpdate),
                Win.AddEdit("vid-num @use:pd-edit xs10 yp+25 w210", selectedGuest["idNum"]).onChange(handleProfileUpdate),
                ; birthday
                Win.AddText("@use:pd-label", "生日"),
                Win.AddDateTime("vbirthday x+5 w150 h25 Disabled Choose" . selectedGuest["birthday"].replace("-", "")).onChange(handleProfileUpdate),
                ; addr
                Win.AddText("@use:pd-label", "地址/地区"),
                Win.AddEdit("vaddr @use:pd-edit", selectedGuest["addr"]).onChange(handleProfileUpdate),
                ; tel
                Win.AddText("@use:pd-label", "联系电话"),
                Win.AddEdit("vtel @use:pd-edit", selectedGuest["tel"]).onChange(handleProfileUpdate),
                ; guardian informations
                selectedGuest["guardianInfo"].Capacity > 0 && [
                    Win.AddText("xs10 yp+40 w205 0x10 0x200", "divider"),
                    Win.AddText("@use:pd-label yp+10", "监护人姓名"),
                    Win.AddEdit("vguardian-name @use:pd-edit", selectedGuest["guardianInfo"]["guardianName"]).onChange(handleProfileUpdate),
                    Win.AddText("@use:pd-label", "监护人电话"),
                    Win.AddEdit("vguardian-tel @use:pd-edit", selectedGuest["guardianInfo"]["guardianTel"]).onChange(handleProfileUpdate),
                    Win.AddText("@use:pd-label", "监护人关系"),
                    Win.AddEdit("vguardian-relation @use:pd-edit", selectedGuest["guardianInfo"]["guardianRelation"]).onChange(handleProfileUpdate),
                ],
                ; registered time
                Win.AddText("xs10 yp+40 w205 0x10 0x200", "divider"),
                Win.AddText("@use:pd-label yp+10", "登记时间"),
                Win.AddDateTime("vreg-time x+5 w150 h25 Disabled Choose" . selectedGuest["regTime"]).onChange(handleProfileUpdate),
            ]
        )
        Win.AddButton("x20 h30 w110", "关 闭 (&C)").onClick(handleClose)
        Win.AddButton("x+10 h30 w110 Default", "{1}", fillMode)
            .onClick(fillInfo)
            .onContextMenu(handleFillModeSwitch)

        onMount()
    }

    return render()
}