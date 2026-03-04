#Include deposit-entry-action.ahk

/**
 * @param {Svaner} App
 * @param {Object} [props] 
 * @returns {Component} 
 */
DepositEntry(App, props := {}) {
    depositInfo := props.depositInfo
    ( !props.hasOwnProp("style") && props.style := {} )
    s := useProps(props.style, {
        xyPos: ""
    })
    comp := Component(App, A_ThisFunc, props)

    destroy(*) {
        ; restore card info
        A_Clipboard := Format("{1}`t{2}", depositInfo.cardNum, depositInfo.exp)
        App.Destroy()
    }

    isDelegate := signal(false)
    delegateDepositEntry(ctrl, _) {
        isDelegate.set(ctrl.Value)
        App["room"].Focus()
    }

    sendQmPost(depositInfo) {
        ; agent := useServerAgent({ pool: "\\10.0.2.13\fd\19-个人文件夹\HC\Software - 软件及脚本\AHK_Scripts\ClipFlow\src\Servers\qm-pool" })
        agent := useServerAgent({ pool: A_ScriptDir . "\src\Servers\qm-pool" })
        agent.POST({
            module: "DepositEntry",
            form: depositInfo
        })
    }

    completeInfo(*) {
        depositInfo.cardType := App["typeAll:Radio"]
            .find(radio => radio.Value == true)
            .Text
            .replace("&", "")
        depositInfo.cardNum := App["card-num"].Value
        depositInfo.exp := App["exp"].Value
        depositInfo.amount := App["amount"].Value
        depositInfo.auth := App["auth"].Value
        depositInfo.room := App["room"].Value

        if (!depositInfo.room || depositInfo.room == "(房间号)" || !depositInfo.exp || !depositInfo.amount) {
            return
        }

        SetTimer(() => destroy(), -100)

        if (App["de-delegate"].Value == true) {
            sendQmPost(depositInfo)
        } else {
            DepositEntry_Action.entry(depositInfo)
        }
    }

    onMount() {
        App[depositInfo.cardType].Value := true
        App["amount"].Focus()
    }

    comp.render := this => this.Add(
        App.AddGroupBox("Section vdeposit-info-gb w350 h150", "押金信息").SetFont("bold"),
        ; card type
        App.AddText("xs10 yp+23 w80 h25 0x200", "支付类型"),
        ["&UP", "&VS", "&MC", "&AE", "&JC"].map(card => App.AddRadio("x+1 w50 h25", card)),
        ; card info
        App.AddText("xs10 yp+30 w80 h25 0x200", "卡号信息"),
        App.AddEdit("vcard-num x+1 w170 h25 0x200", depositInfo.cardNum),
        App.AddEdit("vexp x+5 w70 h25", depositInfo.exp),
        ; amount auth
        App.AddText("xs10 yp+30 w80 h25 0x200", "金额/授权号"),
        App.AddEdit("vamount x+1 w170 h25", depositInfo.amount),
        App.AddEdit("vauth x+5 w70 h25", depositInfo.auth),
        ; server delegate
        App.AddCheckbox("vde-delegate Checked xs10 yp+30 w80 h25", "后台代行").onClick(delegateDepositEntry),
        App.AddEdit("vroom x+1 w170 h25", (depositInfo.room || "(房间号)")),
        ; btns
        App.AddButton("@relative[x-165]:deposit-info-gb yp+45 w80 h25", "取消 (&C)").onClick(destroy),
        App.AddButton("x+5 w80 h25 Default", "确定 (&O)").onClick(completeInfo),
        onMount()
    )

    return comp
}