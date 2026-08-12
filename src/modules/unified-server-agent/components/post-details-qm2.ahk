PostDetails_QM2(post, moduleName, props) {
    title := "Post Details - " . post["id"]
    if (WinExist(title)) {
        WinActivate(title)
        return
    }

    App := Svaner({
        gui: { title: title },
        font: { name: "微软雅黑" },
        events: {
            close: (thisGui) => thisGui.Destroy()
        }
    })

    qmModules := Map(
        "BlankShare", { desc: "Share 详情", module: BlankShare },
        "PaymentRelation", { desc: "Payment 关系", module: PaymentRelation },
        "TransactionEntry", { desc: "授权押金", module: TransactionEntry }
    )

    handleRepost(*) {
        profiles := (App["send-pm-post"].Value == false || moduleName != "BlankShare") ? Map() : post["content"]["profiles"]

        form := App.Submit()
        agent.delegate({
            module: moduleName,
            form: form,
            profiles: profiles,
            additionals: post["content"]["additionals"]
        })
        renameResendPost(post["id"])

        return form
    }

    renameResendPost(id) {
        loop files (agent.qmPool . "\*.json") {
            if (InStr(A_LoopFileFullPath, id)) {
                agent.updatePostStatus(A_LoopFileFullPath, "RESENT")
                break
            }
        }
    }

    handleModuleEventDelegate(*) {
        if (moduleName == "BlankShare" && !App["share-room-nums"].Value) {
            return 0
        }

        handleRepost()
        App.Destroy()

        return 0
    }

    App.defineDirectives(
        "@use:form-text", "xs10 yp+30 w100 h25 0x200",
        "@use:form-edit", "x+10 w200 h25 0x200"
    )

    onMount() {
        if (moduleName != "TransactionEntry") {
            App[moduleName.toCase("kebab") . "-action"].OnEvent("Click", handleModuleEventDelegate, -1)
            App[moduleName.toCase("kebab") . "-action"].Opt("+Default")
        }
    }

    render() {
        App.AddGroupBox("Section w370 h300", "代行详情").SetFont("Bold")
        App.AddText("xs10 yp+20", "发送状态: " . post["status"])
        App.AddText("xs10 yp+20", "发送时间: " . post["time"])
        App.AddText("xs10 yp+20", "限定日期: " . (post["content"]["additionals"]["limitDate"] ? FormatTime(post["content"]["additionals"]["limitDate"], "yyyy/MM/dd") : "无"))
        App.AddText("xs10 w200 h20 yp+30", qmModules[moduleName].desc).SetFont("bold s10")
        qmModules[moduleName].module.Call(App, props).render()
        onMount()
        App.Show()
    }

    return render()
}
