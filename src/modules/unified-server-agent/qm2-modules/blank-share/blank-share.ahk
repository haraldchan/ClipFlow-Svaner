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
        form := comp.submit()
        BlankShare_Action.USE(form)
        App["share-room-nums"].Value := ""
        App["check-in"].Value := 1
        App["share-qty"].Value := 1
    }

    comp.render := (this) => this.Add(
        StackBox(App,
            {
                name: "blank-share-stack-box",
                groupbox: {
                    title: "生成空白(NRR) Share",
                    options: "Section r7 @use:box-xyw",
                }
            },
            () => [
                ; room number(s)
                App.AddText("xs10 w100 h20 0x200 yp+30", "房号 (空格分割)"),
                App.AddEdit("vshare-room-nums x+5 w200 h20 0x200", f.shareRoomNums),
                ; share qty
                App.AddText("xs10 w100 h20 0x200 yp+30", "空白 Share 数量"),
                App.AddEdit("vshare-qty x+5 w200 h20 0x200", f.shareQty),
                ; is checkin
                App.AddCheckBox("vcheck-in xs10 h20 yp+30 0x200 " . (f.checkIn ? "Checked" : ""), "是否 Check In"),
                ; comp.children.Call(),
                App.AddButton("vblankshare-action xs10 y+10 w100", "生成 Share").onClick(action)
            ]
        )
    )

    return comp
}