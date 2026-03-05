#Include payment-relation-action.ahk

/** 
 * @param {Svaner} App
 * @param {Object} [props] 
 * @returns {Component} 
 */
PaymentRelation(App, props := {}) {
    ( !props.hasOwnProp("form") && props.form := {} )
    f := useProps(props.form, {
        pfRoom: "",
        pfName: "",
        party:  "",
        partyRoomQty: "",
        pbRoom: "",
        pbName: ""
    })

    ( !props.hasOwnProp("style") && props.style := {} )
    s := useProps(props.style, {
        xyPos: "@align[xy]:bs-stackbox"
    })

    comp := Component(App, A_ThisFunc, props)

    getPayFor(*) {
        form := comp.submit()

        nameConf := IsNumber(form.pbName) ? "#" . form.pbName : form.pbName
        A_Clipboard := (!form.party || !form.partyRoomQty)
            ? Format("P/F Rm{1} {2}  ", form.pbRoom, nameConf)
            : Format("P/F Party#{1}, total {2}-rooms  ", form.party, form.partyRoomQty)
        MsgBox(A_Clipboard, "已复制信息", "4096 T1")
    }

    getPayBy(*) {
        form := comp.submit()

        nameConf := IsNumber(form.pfName) ? "#" . form.pfName : form.pfName
        A_Clipboard := Format("P/B Rm{1} {2}  ", form.pfRoom, nameConf)
        MsgBox(A_Clipboard, "已复制信息", "4096 T1")
    }

    clear(*) {
        for ctrl in comp.ctrls {
            if (ctrl is Gui.Edit) {
                ctrl.Value := ""
            }
        }
    }

    action(*) {
        App.Hide()
        Sleep 100

        form := comp.submit()
        PaymentRelation_Action.USE(form)
        App.Show()
    }

    App.defineDirectives(
        "@use:pr-text", "xs10 yp+25 w70 h20 0x200",
        "@use:pr-edit", "x+1 w80 h20"
    )

    comp.render := (this) => this.Add(
        StackBox(App, 
            {
                name: "pay-for-stack-box",
                font: { options: "bold" },
                groupbox: {
                    title: "P/F房(支付人)",
                    options: "vpayfor-panel Section w170 h130 " . s.xyPos
                } 
            },
            () => [
                ; pay for
                App.AddText("@use:pr-text yp+25", "房号"),
                App.AddEdit("vpf-room Number @use:pr-edit", f.pfRoom),

                App.AddText("@use:pr-text", "姓名/确认号 "),
                App.AddEdit("vpf-name @use:pr-edit", f.pfName),
                
                App.AddText("@use:pr-text", "Party号"),
                App.AddEdit("vparty Number @use:pr-edit", f.party),
                
                App.AddText("@use:pr-text", "Total房数"),
                App.AddEdit("vparty-room-qty Number @use:pr-edit", f.partyRoomQty),
            ]
        ),

        StackBox(App,
            {
                name: "pay-by-stack-box",
                font: { options: "bold" },
                groupbox: {
                    title: "P/B房(被支付人)",
                    options: "vpayby-panel Section x+3 @align[ywh]:payfor-panel"
                }
            },
            () => [
                ; pay by
                App.AddText("@use:pr-text yp+25", "房号"),
                App.AddEdit("vpb-room Number @use:pr-edit", f.pbRoom),
                App.AddText("@use:pr-text", "姓名/确认号 "),
                App.AddEdit("vpb-name @use:pr-edit", f.pbName)
            ]
        ),

        ; btns  
        App.AddButton("vpayment-relation-action w300 h40 @align[x]:payfor-panel y+10", "录 入 全 部").onClick(action),
        App.AddButton("w40 h40 x+10", "清空").onClick(clear)
    )

    return comp
}
