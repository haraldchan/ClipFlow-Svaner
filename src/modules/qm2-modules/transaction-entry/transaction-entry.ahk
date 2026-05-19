#Include transaction-entry-action.ahk

/**
 * @param {Svaner} App
 * @param {Object} [props] 
 * @returns {Component} 
 */
TransactionEntry(App, props := {}) {
    transactionInfo := props.transactionInfo
    ( !props.hasOwnProp("style") && props.style := {} )
    s := useProps(props.style, {
        xyPos: ""
    })
    comp := Component(App, A_ThisFunc, props)

    destroy(*) {
        ; restore card info
        A_Clipboard := transactionInfo.cardNum
        App.Destroy()
    }

    isDelegate := signal(false)
    delegateTransactionEntry(ctrl, _) {
        isDelegate.set(ctrl.Value)
        App["room"].Focus()
    }

    sendQmPost(transactionInfo) {
        agent.delegate({
            module: "TransactionEntry",
            form: transactionInfo
        })
    }

    completeInfo(*) {
        transactionInfo.cardType := App["typeAll:Radio"]
            .find(radio => radio.Value == true)
            .Text
            .replace("&", "")
        transactionInfo.cardNum := App["card-num"].Value
        transactionInfo.exp := App["exp"].Value
        transactionInfo.amount := App["amount"].Value
        transactionInfo.auth := App["auth"].Value
        transactionInfo.room := App["room"].Value

        if (!transactionInfo.room || transactionInfo.room == "(房间号)" || !transactionInfo.exp || !transactionInfo.amount) {
            return
        }

        WinHide(App)

        if (App["de-delegate"].Value == true) {
            sendQmPost(transactionInfo)
        } else {
            TransactionEntry_Action.entry(transactionInfo)
        }

        destroy()
    }

    onMount() {
        if (transactionInfo.transType != "预授权") {
            App["de-delegate"].Value := false
            App["de-delegate"].Enabled := false
            App["room"].Enabled := false
        }

        App[transactionInfo.cardType].Value := true
        App["amount"].Focus()
    }

    comp.render := this => this.Add(
        App.AddGroupBox("Section vdeposit-info-gb w350 h150", Format("{1}信息", transactionInfo.transType)).SetFont("bold"),
        ; card type
        App.AddText("xs10 yp+23 w80 h25 0x200", "支付类型"),
        ["&UP", "&VS", "&MC", "&AE", "&JC"].map(card => App.AddRadio("x+1 w50 h25", card)),
        ; card info
        App.AddText("xs10 yp+30 w80 h25 0x200", "卡号信息"),
        App.AddEdit("vcard-num x+1 w170 h25 0x200", transactionInfo.cardNum),
        App.AddEdit("vexp x+5 w70 h25", transactionInfo.exp),
        ; amount auth
        App.AddText("xs10 yp+30 w80 h25 0x200", "金额/授权号"),
        App.AddEdit("vamount x+1 w170 h25", transactionInfo.amount),
        App.AddEdit("vauth x+5 w70 h25", transactionInfo.auth),
        ; server delegate
        App.AddCheckbox("vde-delegate Checked xs10 yp+30 w80 h25", "后台代行").onClick(delegateTransactionEntry),
        App.AddEdit("vroom x+1 w170 h25", (transactionInfo.room || "(房间号)")),
        ; btns
        App.AddButton("@relative[x-165]:deposit-info-gb yp+45 w80 h25", "取消 (&C)").onClick(destroy),
        App.AddButton("x+5 w80 h25 Default", "确定 (&O)").onClick(completeInfo),
        onMount()
    )

    return comp
}
