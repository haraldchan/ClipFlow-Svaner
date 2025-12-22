/**
 * @param {Object} props 
 */
QM2_Panel(props) {
    ; App := Gui("+AlwaysOnTop", "ServerAgents - QM2 Agent")
    ; App.SetFont(, "微软雅黑")
    App := Svaner({
        gui: {
            options: "+AlwaysOnTop",
            title: "ServerAgents - QM2 Agent"
        },
        font: {
            name: "微软雅黑"
        },
        events: {
            close: (gui) => gui.Destroy()
        }
    })

    p := useProps(props, {
        sendPm: true,
        selectedGuests: []
    })

    modules := OrderedMap(
        BlankShare, "生成空白(NRR) Share",
        PaymentRelation, "生成 PayBy PayFor 信息"
    )
    selectedModule := signal(BlankShare.name)
    moduleComponents := OrderedMap(
        "BlankShare",      (*) => BlankShare(App, { children: App => App.AddCheckBox((p.sendPm ? "Checked " : "") . "vsendPmPost h20 x+20 yp 0x200", "Share Check-in 后录入 Profile") }),
        "PaymentRelation", PaymentRelation
    )

    effect(selectedModule, handleModuleChange)
    handleModuleChange(moduleName) {
        for module in modules {
            App[module.name . "-action"].Opt(module.name = moduleName ? "+Default" : "-Default")
        }
    }

    form := {}
    delegateQmActions(module) {
        form := App.Submit()
        agent.delegate({
            module: module,
            form: form,
            profiles: p.selectedGuests
        })

        return 0
    }

    
    handleBlankShareDelegate(*) {
        if (!App["share-room-nums"].Value) {
            return 0
        }

        delegateQmActions("BlankShare")

        if (App["send-pm-post"].Value) {
            handleTriggerPmPost()
        }

        SetTimer((*) => (App.Destroy(), WinHide(POPUP_TITLE)), -100)

        return 0
    }

    ; db := useFileDB(CONFIG.read("dbSettings"))
    handleTriggerPmPost() {
        roomNums := form.shareRoomNums.trim()
        profiles := p.selectedGuests.Length == 0
            ; ? db.load(,, agent.collectRange).filter(guest => roomNums.includes(!guest["roomNum"] ? "null" : guest["roomNum"]))
            ; : p.selectedGuests

        SetTimer(() => (
            post := agent.delegate({
                rooms: roomNums.split(" "),
                profiles: profiles
            })
        ), -300)
    }
    
    handlePaymentRelationDelegate(*) {
        if (!App["pf-room"].Value || !App["pf-name"].Value) {
            return 0
        }

        return delegateQmActions("PaymentRelation")
    }

    onMount() {
        roomCountMap := Map()
        for roomProfiles in p.selectedGuests {
            for roomNum, profiles in roomProfiles {
                roomCountMap[roomNum] := profiles.Length - 1
            }
        }

        shareRoomNums := App["share-room-nums"]
        shareRoomNums.Enabled := false
        shareRoomNums.Value := roomCountMap.keys().join(" ")
        App["share-qty"].Value := roomCountMap.values().join(" ")

        ; re-label btns
        BlankShareAction := App["blankshare-action"]
        BlankShareAction.Text := "Share 代行"
        BlankShareAction.Opt("+Default")

        ; override events
        BlankShareAction.onClick(handleBlankShareDelegate, -1)
        App["paymentrelation-action"].onClick(handlePaymentRelationDelegate, -1)

        App.Show()
    }

    App.defineDirectives(
        "@use:box-x", "x20",
        "@use:box-y", "y110",
        "@use:box-w", "w350",
        "@use:box-xyw", "@use:box-x @use:box-y @use:box-w"
    )

    return (
        ; GroupBox frame
        App.AddGroupBox("Section w370 h300 x10 y10", "QM2 Agent").SetFont("s12 Bold"),

        ; QM modules
        modules.keys().map(module =>
            App.AddRadio(A_Index == 1 ? "Checked xs10 yp+30 h20" : "xs10 yp+30 h20", modules[module])
               .onClick((*) => selectedModule.set(module.name))
        ),
        Dynamic(App, selectedModule, moduleComponents),
        
        ; initializing
        onMount()
    )
}
