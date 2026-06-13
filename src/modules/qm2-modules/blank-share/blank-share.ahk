#Include blank-share-action.ahk

/**
 * @param {Svaner} App
 * @param {Object} [props] 
 * @returns {Component} 
 */
BlankShare(App, props := {}) {
    comp := Component(App, A_ThisFunc, props)

    (!props.HasOwnProp("form") && props.form := {})
    f := useProps(props.form, {
        shareRoomNums: "",
        shareQty: "1",
        checkIn: true
    })

    action(*) {
        if (!App["share-room-nums"].Value) {
            return 0
        }

        clickEvent := props.clickEvent
        clickEvent("BlankShare")

        WinHide(POPUP_TITLE)
        App.Destroy()
    }

    comp.render := (this) => this.Add(
        StackBox(
            App,
            {
                name: "blank-share-stack-box",
                font: { options: "bold" },
                groupbox: {
                    title: "生成空白(NRR) Share",
                    options: "vbs-stackbox Section h165 xs10 y+5 w350",
                }
            },
            () => [
                ; room number(s)
                App.AddText("@use:form-text yp+25", "房号 (空格分割)"),
                App.AddEdit("vshare-room-nums @use:form-edit Disabled", f.shareRoomNums),
                ; share qty
                App.AddText("@use:form-text", "空白 Share 数量"),
                App.AddEdit("vshare-qty @use:form-edit", f.shareQty),
                ; is checkin
                App.AddCheckBox("vcheck-in xs10 h20 yp+30 0x200 " . (f.checkIn ? "Checked" : ""), "是否 Check In"),
                App.AddCheckBox("vsend-pm-post h20 x+20 yp 0x200 Checked", "Share Check-in 后录入 Profile"),
                App.AddButton("vblank-share-action xs10 y+20 w100", "Share 代行").onClick(action)
            ]
        )
    )

    return comp
}
