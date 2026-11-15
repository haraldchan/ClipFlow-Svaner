#Include transaction-entry-action.ahk

/**
 * @param {Svaner} App
 * @param {Object} [props] 
 * @returns {Component} 
 */
TransactionEntry(App, props := {}) {
    transactionInfo := props.transactionInfo
    index := props.index
    (!props.hasOwnProp("style") && props.style := {})
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
        App["room-" index].Focus()
    }

    sendQmPost(transactionInfo) {
        delegateContent := {
            postType: "qm",
            module: "TransactionEntry",
            form: transactionInfo,
            additionals: { limitDate: "" }
        }

        agent.delegate(delegateContent)
    }

    completeInfo(*) {
        selectedTransaction := {}
        selectedTransaction.cardType := App["typeAll:Radio"].filter(r => r.name.includes("-" index)).find(r => r.Value == true).Text
        selectedTransaction.cardNum := App["card-num-" index].Value
        selectedTransaction.exp := App["exp-" index].Value
        selectedTransaction.amount := App["amount-" index].Value
        selectedTransaction.auth := App["auth-" index].Value
        selectedTransaction.room := App["room-" index].Value

        if (!selectedTransaction.room || selectedTransaction.room == "(房间号)" || !selectedTransaction.exp || !selectedTransaction.amount) {
            return
        }

        App.Hide()

        if (App["de-delegate-" index].Value == true) {
            sendQmPost(selectedTransaction)
        } else {
            TransactionEntry_Action.entry(transactionInfo)
        }

        destroy()
    }

    onMount() {
        if (transactionInfo.transType != "预授权") {
            App["de-delegate-" index].Value := false
            App["de-delegate-" index].Enabled := false
            App["room-" index].Enabled := false
        }

        App["card-type-" transactionInfo.cardType "-" index].Value := true
        App["amount-" index].Focus()
    }

    comp.render := this => this.Add(
        StackBox(
            App,
            {
                name: "pay-by-stack-box",
                font: { options: "bold" },
                groupbox: {
                    title: Format("{1}信息", transactionInfo.transType),
                    options: "Section vdeposit-info-gb-" index " x20 w350 h150" 
                }
            },
            () => [
                ; card type
                App.AddText("xs10 yp+23 w80 h25 0x200", "支付类型"),
                ["UP", "VS", "MC", "AE", "JC"].map(card => App.AddRadio(Format("vcard-type-{}-{}", card, index) " x+1 w50 h25", card)),
                ; card info
                App.AddText("xs10 yp+30 w80 h25 0x200", "卡号信息"),
                App.AddEdit("vcard-num-" index " x+1 w170 h25 0x200", transactionInfo.cardNum),
                App.AddEdit("vexp-" index " x+5 w70 h25", transactionInfo.exp),
                ; amount auth
                App.AddText("xs10 yp+30 w80 h25 0x200", "金额/授权号"),
                App.AddEdit("vamount-" index " x+1 w170 h25", transactionInfo.amount),
                App.AddEdit("vauth-" index " x+5 w70 h25", transactionInfo.auth),
                ; server delegate
                App.AddCheckbox("vde-delegate-" index " Checked xs10 yp+30 w80 h25", "后台代行").onClick(delegateTransactionEntry),
                App.AddEdit("vroom-" index " x+1 w170 h25", (transactionInfo.room || "(房间号)")),
                ; btns
                App.AddButton("x+5 w70 h25 " (index == 1 ? "Default" : ""), "确定").onClick(completeInfo),         
            ]
        ),
        onMount()
    )

    return comp
}
