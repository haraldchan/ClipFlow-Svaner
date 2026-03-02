PostDetails_QM2(post, moduleName, props) {
    App := Svaner({
        gui: { title: "Post Details - " . post["id"] },
        font: { name: "微软雅黑" },
        events: {
            close: (thisGui) => thisGui.Destroy()
        }
    })

    qmModules := Map(
        "BlankShare",      { desc: "Share 详情", module: BlankShare },
        "PaymentRelation", { desc: "Payment 关系", module: PaymentRelation },
    )

    handleRepost(*) {
        form := App.Submit()
        agent.delegate({
            module: moduleName,
            form: form,
            profiles: post["content"]["profiles"]
        }),
        renameResendPost(post["id"])

        return form
    }

    renameResendPost(id) {
        loop files (agent.qmPool . "\*.json") {
            if (InStr(A_LoopFileFullPath, id)) {
                status := StrSplit(A_LoopFileName, "==")[1]
                FileMove(A_LoopFileFullPath, StrReplace(A_LoopFileFullPath, status, "RESENT"))
                break
            }
        }
    }

    handleModuleEventDelegate(*) {
        if (moduleName == "BlankShare" && !App["share-room-nums"].Value) {
            return 0
        }

        form := handleRepost()

        if (moduleName == "BlankShare" && App["send-pm-post"].Value) {
            handleTriggerPmPost(form)
        }

        App.Destroy()
        return 0 
    }

    dbConfig := CONFIG.read("dbConfig")
    db := useFileDB({
            main: dbConfig["host"] . "\" . dbConfig["main"],
            archive: dbConfig["host"] . "\" . dbConfig["archive"],
            backup: dbConfig["host"] . "\" . dbConfig["backup"],
            ; main: "",
            ; archive: "",
            ; backup: "",
    })
    handleTriggerPmPost(form) {
        roomNums := form.shareRoomNums.trim()
        ; selectedGuests can only pass by GuestProfileList
        ; if no selectedGuest, then filter results in db by room number(request from ServerAgent_Panel)
        profiles := post["content"]["profiles"].Length == 0
            ? db.load(, , agent.collectRange).filter(guest => roomNums.includes(!guest["roomNum"] ? "null" : guest["roomNum"]))
            : post["content"]["profiles"]

        post := agent.delegate({
            rooms: roomNums.split(" "),
            profiles: profiles
        })
    }

    App.defineDirectives(
        "@use:form-text", "xs10 yp+30 w100 h25 0x200",
        "@use:form-edit", "x+10 w200 h25 0x200"
    )

    onMount() {
        App[moduleName.toCase("kebab") . "-action"].OnEvent("Click", handleModuleEventDelegate, -1)
        App[moduleName.toCase("kebab") . "-action"].Opt("+Default")
    }

    return (
        App.AddGroupBox("Section w370 h300", "代行详情").SetFont("Bold"),
        App.AddText("xs10 yp+20", "发送状态: " . post["status"]),
        App.AddText("xs10 yp+20", "发送时间: " . post["time"]),
        App.AddText("xs10 w200 h35 yp+30", qmModules[moduleName].desc).SetFont("bold s10"),
        qmModules[moduleName].module.Call(App, props).render(),
        onMount(),
        App.Show()
    )
}