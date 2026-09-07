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
        checkIn: true,
    })

    selectedGuests := [props.selectedGuests.values().flat()*]
    handler := props.guestWithNeedsHandler

    LANDOW_ORDER_NOTIFY_ONLY := true
    if (LANDOW_ORDER_NOTIFY_ONLY) {
        handler(selectedGuests, false, true)
    }

    action(*) {
        if (!App["share-room-nums"].Value) {
            return
        }

        if (!LANDOW_ORDER_NOTIFY_ONLY) {
            sendElderlyOrder := App["delegate-landow-elderly"].Value,
            sendChildrenOrder := App["delegate-landow-children"].Value
            if (sendElderlyOrder || sendChildrenOrder) {
                handler(
                    selectedGuests, 
                    resultOnly := false, 
                    notifyOnly := false, ; TODO: switch to true only after landow macro passes test.
                    sendElderlyOrder,
                    sendChildrenOrder
                )
            } 
        }

        clickEvent := props.clickEvent
        clickEvent("BlankShare")

        WinHide(POPUP_TITLE)
        App.Destroy()
    }

    hasElderly := false
    hasChildren := false

    handleShowLandowOrderCheckBox() {
        if (!props.guestWithNeedsHandler) {
            return
        }
        
        handler := props.guestWithNeedsHandler
        guestWithNeeds := handler(selectedGuests, true)
        if (!guestWithNeeds) {
            return
        }

        if (LANDOW_ORDER_NOTIFY_ONLY) {
            return
        }

        hasElderly := guestWithNeeds.elderly.Length
        hasChildren := guestWithNeeds.children.Length
    }
    handleShowLandowOrderCheckBox()

    defineStackboxHeight() {
        stackboxHeight := 165

        if (hasElderly) {
            stackboxHeight += 35
        }
        if (hasChildren) {
            stackboxHeight += 35
        }
        
        return "h" . stackboxHeight
    }

    comp.render := (this) => this.Add(
        StackBox(
            App,
            {
                name: "blank-share-stack-box",
                font: { options: "bold" },
                groupbox: {
                    title: "生成空白(NRR) Share",
                    options: "vbs-stackbox Section xs10 y+5 w350 " . defineStackboxHeight(),
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
                ; handle landow order checkboxes
                hasElderly && App.AddCheckBox("vdelegate-landow-elderly xs10 yp+30 w300 h25", "发送 防滑处理 工单"),
                hasChildren && App.AddCheckBox("vdelegate-landow-children xs10 yp+30 w300 h25", "发送 儿童用品套装 工单"),
                ; action
                App.AddButton("vblank-share-action xs10 yp+40 w100", "Share 代行").onClick(action),
            ]
        )
    )

    return comp
}
