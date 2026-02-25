/**
 * @param {Object} props 
 */
QM2_Panel(props) {
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
        "生成空白(NRR) Share", BlankShare,
        "生成 PayBy PayFor 信息", PaymentRelation
    )

    selectedModule := signal(modules.keys()[1])

    handleModuleChange(ctrl, _) {
        moduleName := modules[ctrl.Text].name
        selectedModule.set(ctrl.Text)

        for desc, module in modules {
            App[module.name.toCase("kebab") . "-action"].Opt(desc == ctrl.Text ? "+Default" : "-Default")
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

    db := useFileDB({
            ; main: dbConfig["host"] . "\" . dbConfig["main"],
            ; archive: dbConfig["host"] . "\" . dbConfig["archive"],
            ; backup: dbConfig["host"] . "\" . dbConfig["backup"],
            main: "",
            archive: "",
            backup: "",
    })
    handleTriggerPmPost() {
        roomNums := form.shareRoomNums.trim()
        profiles := p.selectedGuests.Length == 0
            ? db.load(,, agent.collectRange).filter(guest => roomNums.includes(!guest["roomNum"] ? "null" : guest["roomNum"]))
            : p.selectedGuests

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
                roomCountMap[roomNum] := profiles.Length <= 1 ? 0 : profiles.Length - 1
            }
        }

        shareRoomNums := App["share-room-nums"]
        shareRoomNums.Enabled := false
        shareRoomNums.Value := roomCountMap.keys().join(" ")
        App["share-qty"].Value := roomCountMap.values().join(" ")

        ; re-label btns
        BlankShareAction := App["blank-share-action"]
        BlankShareAction.Text := "Share 代行"
        BlankShareAction.Opt("+Default")

        ; override events
        BlankShareAction.onClick(handleBlankShareDelegate, -1)
        App["payment-relation-action"].onClick(handlePaymentRelationDelegate, -1)

        App.Show()
    }

    App.defineDirectives(
        "@use:box-x", "x10",
        "@use:box-w", "w350",
        "@use:box", "@use:box-x @relative[y+10]:op-radio-group @use:box-w",
        "@use:form-text", "xs10 yp+30 w100 h25 0x200",
        "@use:form-edit", "x+10 w200 h25 0x200"
    )

    return (
        StackBox(App, 
            {
                name: "op-radio-group",
                groupbox: { options: "vop-radio-group Section x10 y+10 w350 Hidden " . Format("h{1}", 30 * modules.keys().Length) } 
            },
            () => modules.entries().map(
                (entry, index) => App.AddRadio(index == 1 ? "xs1 h20 yp+1 Checked" : "xs1 h20 yp+30" , entry[1]).onClick(handleModuleChange)
            )
        ),
        Dynamic(App, selectedModule, modules),
        
        ; initializing
        onMount()
    )
}