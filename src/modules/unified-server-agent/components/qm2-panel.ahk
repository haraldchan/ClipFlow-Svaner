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
            close: (gui) => (SetTimer(detectWindowIsActive, 0), gui.Destroy())
        }
    })

    p := useProps(props, {
        overwriteProfiles: false,
        selectedGuests: Map()
    })

    modules := OrderedMap(
        "生成空白(NRR) Share", BlankShare,
        "生成 PayBy PayFor 信息", PaymentRelation
    )

    selectedModule := signal(modules.keys()[1])

    handleModuleChange(ctrl, _) {
        selectedModule.set(ctrl.Text)

        for desc, module in modules {
            App[module.name.toCase("kebab") . "-action"].Opt(desc == ctrl.Text ? "+Default" : "-Default")
        }
    }

    delegateQmActions(module) {
        profiles := (App["send-pm-post"].Value == false || module != "BlankShare") ? Map() : p.selectedGuests

        form := App.Submit()
        agent.delegate({
            module: module,
            form: form,
            profiles: profiles,
            additionals: { overwrite: p.overwriteProfiles }
        })
    }

    handleBlankShareDelegate(*) {
        if (!App["share-room-nums"].Value) {
            return 0
        }

        delegateQmActions("BlankShare")

        WinHide(POPUP_TITLE)
        App.Destroy()
        
        return 0
    }

    handlePaymentRelationDelegate(*) {
        if (!App["pf-room"].Value || !App["pf-name"].Value) {
            return 0
        }

        return delegateQmActions("PaymentRelation")
    }

    timeoutCount := 0
    TIMEOUT_MAX_SECOND := 60
    detectWindowIsActive(*) {
        if (!WinExist("ServerAgents - QM2 Agent")) {
            SetTimer(, 0)
            return
        }

        timeoutCount := !WinActive(App.gui.Hwnd) ? timeoutCount + 1 : 0

        if (timeoutCount >= TIMEOUT_MAX_SECOND) {
            SetTimer(, 0)
            try {
                App.Destroy()
            }
        }
    }

    onMount() {
        shareRoomNums := App["share-room-nums"]
        shareRoomNums.Enabled := false
        shareRoomNums.Value := p.selectedGuests.keys().join(" ")
        App["share-qty"].Value := p.selectedGuests.values().map(g => g.Length <= 1 ? 0 : g.Length - 1).join(" ")

        ; re-label btns
        BlankShareAction := App["blank-share-action"]
        BlankShareAction.Text := "Share 代行"
        BlankShareAction.Opt("+Default")

        ; override events
        BlankShareAction.onClick(handleBlankShareDelegate, -1)
        App["payment-relation-action"].onClick(handlePaymentRelationDelegate, -1)

        SetTimer(detectWindowIsActive, 1000)

        App.Show()
    }

    App.defineDirectives(
        "@use:form-text", "xs10 yp+30 w100 h25 0x200",
        "@use:form-edit", "x+10 w200 h25 0x200"
    )

    render() {
        StackBox(App, 
        {
            name: "op-radio-group",
            groupbox: { options: "vop-radio-group Section x10 y+10 w350 Hidden " . Format("h{1}", 30 * modules.keys().Length) }
        },
            () => modules.entries().map(
                (entry, index) => App.AddRadio(index == 1 ? "xs1 h20 yp+1 Checked" : "xs1 h20 yp+30", entry[1]).onClick(handleModuleChange)
            )
        )
        
        Dynamic(App, selectedModule, modules)
        
        ; initializing
        onMount()
    }
    
    return render()
}