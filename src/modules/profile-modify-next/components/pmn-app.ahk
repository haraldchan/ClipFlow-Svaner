/**
 * @param {Svaner} App 
 * @param {String} moduleTitle 
 * @param {()=>Datebase} db 
 * @param {String} identifier 
 */
PMN_App(App, moduleTitle, db, identifier) {
    ; server agent delegate/ enable QM2 panel
    isDelegate := signal(false)
    effect(isDelegate, curIsDelegate => App["guest-profile-list"].Move(, , curIsDelegate ? 470 : 658))

    serverConnection := signal("")
    effect(serverConnection, handleConnStatus)
    handleConnStatus(curServerConnection) {
        connStatusText := App["connection-status"]
        connStatusText.Visible := true

        switch curServerConnection {
            case "尝试连接中...":
                connStatusText.SetFont("norm cBlack")
            case "后台服务在线":
                connStatusText.SetFont("bold cGreen")
                SetTimer(() => connStatusText.Visible := false, -2000)
            default:
                connStatusText.SetFont("bold cRed")
        }
    }

    handleDelegateActivate(ctrl, _) {
        if (ctrl.Value == false) {
            return
        }

        App["qm2-agent"].Enabled := ctrl.Value
        ctrl.Enabled := false
        serverConnection.set("尝试连接中...")

        SetTimer(() => ((
            agent.PING()
                ? serverConnection.set("后台服务在线")
                : (
                    isDelegate.set(false),
                    ctrl.Value := false,
                    serverConnection.set("超时无响应")
                )
        ), ctrl.Enabled := true), -100)
    }


    ; settings
    settings := signal({ fillOverwrite: false }, { asMap: true })
    fillBtnText := computed([isDelegate, settings], handleFillInBtnTextUpdate)
    handleFillInBtnTextUpdate(curDelegate, curSettings) {
        curOverwrite := curSettings["fillOverwrite"]
        return (curDelegate ? (curOverwrite ? "覆盖代行" : "代 行") : (curOverwrite ? "覆盖填入" : "填 入"))
    }


    ; data states
    listContent := signal(db().load())
    queryFilter := signal({ date: FormatTime(A_Now, "yyyyMMdd"), search: "", range: 60 })

    ; list UI states/effect
    searchBy := signal("roomNum")
    searchByMap := OrderedMap(
        "瀑流模式", "waterfall",
        "房号", "roomNum",
        "姓名", "name",
        "证件号码", "idNum",
        "地址", "addr",
        "电话", "tel",
        "生日", "birthday",
    )

    effect(searchBy, handleSearchByChange)
    handleSearchByChange(cur) {
        App["guest-profile-list"].Opt(cur == "waterfall" ? "+Checked +Multi" : "-Checked -Multi")
        App["delegate-check-box"].Enabled := cur == "waterfall"
        if (cur != "waterfall") {
            App["delegate-check-box"].Value := false
            App["qm2-agent"].Enabled := false
            isDelegate.set(false)
        }
    }


    ; incoming data handling
    currentGuest := signal(Map("tsId", 0))
    clbListeners.addListener({
        description: "旅业证件信息捕获",
        isOn: true,
        type: "module",
        callback: (*) => handleCaptured(identifier)
    })
    handleCaptured(identifier) {
        if (!InStr(A_Clipboard, identifier)) {
            return
        }
        ; save a copy in mem for comparison
        incomingGuest := JSON.parse(A_Clipboard)

        ; updating from add guest modal
        if (currentGuest.value["tsId"] == incomingGuest["tsId"] && !incomingGuest["isMod"]) {
            db().put(FormatTime(A_Now, "yyyyMMdd"), incomingGuest)
            MsgBox(Format("已更新信息：{1}", incomingGuest["name"]), POPUP_TITLE, "T1.5 iconi")
        }
        ; updating from saved guest modal
        else if (incomingGuest["isMod"]) {
            updatedGuest := handleGuestInfoUpdateFromMod(incomingGuest)
            if (!updatedGuest) {
                return
            }

            MsgBox(Format("已保存修改：{1}", updatedGuest["name"]), POPUP_TITLE, "T1.5 iconi")
        }
        ; adding guest
        else {
            incomingGuest["regTime"] := A_Now

            db().add(JSON.stringify(incomingGuest))

            isBirthday := incomingGuest["birthday"] == FormatTime(A_Now, "yyyy-MM-dd")
            MsgBox(
                Format("已保存信息：{1}{2}", incomingGuest["name"], isBirthday ? "`n`n此客人今天生日！" : ""),
                POPUP_TITLE,
                isBirthday ? "T3 iconi" : "T1.5 iconi"
            )
        }

        currentGuest.set(JSON.parse(A_Clipboard))

        ; uodate date if not today
        if (queryFilter.value.date != FormatTime(A_Now, "yyyyMMdd")) {
            queryFilter.update("date", FormatTime(A_Now, "yyyyMMdd"))
            App["date"].Value := FormatTime(A_Now, "yyyyMMdd")
        }

        handleListContentUpdate()

        ; clear clipboard
        A_Clipboard := ""
    }

    handleGuestInfoUpdateFromMod(updater) {
        targetGuest := db().load(, "tsId", updater["tsId"], 1440)[1]
        if (!targetGuest) {
            MsgBox("无匹配目标。", POPUP_TITLE, "4096 T1.5 icon!")
            return
        }

        for (key, val in updater) {
            if (val.includes("*")) {
                updater.Delete(key)
            }
        }

        try {
            db().put(, updater)
            return db().load(, "tsId", updater["tsId"], 1440)[1]
        }
        catch {
            MsgBox("更新失败。", POPUP_TITLE, "4096 T1.5 iconx")
        }
    }


    /**
     * Splits room number string with space and comma
     * @param roomNums 
     * @returns {Array<String>} 
     */
    roomNumSplitPipe(roomNums) {
        return pipe(
            i => StrSplit(i, ","),
            i => i.map(item => Trim(item)),
            i => i.map(item => StrSplit(item, " ")),
            i => i.flat()
        )(roomNums)
    }

    handleRefresh(*) {
        if (queryFilter.value.date != FormatTime(A_Now, "yyyyMMdd")) {
            res := MsgBox(
                Format("搜索日期非今天，请确认是否准确`n`n是 - 继续搜索 {1}`n否 - 返回今天", FormatTime(queryFilter.value.date, "yyyy年MM月dd日")),
                POPUP_TITLE,
                "4096 YesNo icon!"
            )
            if (res == "No") {
                queryFilter.update("date", FormatTime(A_Now, "yyyyMMdd"))
                App["date"].Value := FormatTime(A_Now, "yyyyMMdd")
            }
        }

        handleListContentUpdate()
    }

    effect(ProfileModifynext.usingDB, handleListContentUpdate)
    handleListContentUpdate(*) {
        colTitles := App["guest-profile-list"].svanerWrapper.titleKeys
        useListPlaceholder(listContent, colTitles, "Loading...")

        App["range"].Enabled := (queryFilter.value.date == FormatTime(A_Now, "yyyyMMdd"))

        loadedItems := []
        switch searchBy.value {
            case "waterfall":
                if (!queryFilter.value.search) {
                    loadedItems.Push(db().load(queryFilter.value.date, "roomNum", queryFilter.value.search, queryFilter.value.range)*)
                }

                roomNums := roomNumSplitPipe(queryFilter.value.search.trim())
                ; filtering all entered room numbers
                for roomNum in roomNums {
                    loadedItems.Push(db().load(queryFilter.value.date, "roomNum", roomNum, queryFilter.value.range)*)
                }
            case "birthday":
                bd := StrLen(queryFilter.value.search) == 8
                    ? SubStr(queryFilter.value.search, 1, 4) . "-" . SubStr(queryFilter.value.search, 5, 2) . "-" . SubStr(queryFilter.value.search, 7, 2)
                : queryFilter.value.search
                loadedItems.Push(db().load(queryFilter.value.date, "birthday", bd, queryFilter.value.range)*)
            default:
                loadedItems.Push(db().load(queryFilter.value.date, searchBy.value, queryFilter.value.search, queryFilter.value.range)*)
        }

        if (!loadedItems.Length) {
            useListPlaceholder(listContent, colTitles, "No Data")
            return
        }

        listContent.set(loadedItems)
        App["select-all-btn"].Value := false
    }

    ; fill in profile by actions
    fillPmsProfile(*) {
        App.Hide()
        Sleep(500)

        LV := App["guest-profile-list"]
        if (!LV.GetNext()) {
            return
        }

        if (searchBy.value == "waterfall") {
            if (!queryFilter.value.search) {
                MsgBox("瀑流模式必须提供房号。", POPUP_TITLE, "T2 iconi")
                App.Show()
                return
            }

            ; rooms := StrSplit(queryFilter.value["search"].trim(), " ")
            rooms := roomNumSplitPipe(queryFilter.value.search.trim())
            party := ""
            ; party := App["party-num"].Text
            ; App["party-num"].Text := ""

            ; pick selected guests
            checkedRows := LV.getCheckedRowNumbers()
            if (!checkedRows.Length) {
                MsgBox("未选中 Profile。", POPUP_TITLE, "T2 icon!")
                App.Show()
                return
            }

            selectedGuests := checkedRows.map(row => listContent.value[row])
            groupedSelectedGuests := Map()
            for guest in selectedGuests {
                if (groupedSelectedGuests.Has(guest["roomNum"])) {
                    groupedSelectedGuests[guest["roomNum"]].Push(guest)
                }
                else {
                    groupedSelectedGuests[guest["roomNum"]] := [guest]
                }
            }

            if (isDelegate.value) {
                delegateContent := {
                    mode: "waterfall",
                    overwrite: settings.value["fillOverwrite"],
                    limitDate: App["limit-date-btn"].Value ? queryFilter.value.date : "",
                    rooms: rooms,
                    party: party,
                    profiles: groupedSelectedGuests
                }

                SetTimer(() => (
                    isOnline := agent.delegate(delegateContent),
                    isDelegate.set(isOnline ? true : false),
                    App["delegate-check-box"].Value := isOnline ? true : false
                ), -250)
            } else {
                PMN_Waterfall.cascade(
                    groupedSelectedGuests,
                    settings.value["fillOverwrite"],
                    App["limit-date-btn"].Value ? queryFilter.value.date : "",
                    party
                )
            }

            ; reset date limiter
            App["limit-date-btn"].Value := true
            settings.update("isLimitedDate", true)
        } 
        else {
            if (!WinExist("ahk_class SunAwtFrame")) {
                MsgBox("Opera 未启动！ ", "Profile Modify Next", "T1")
                return
            }

            targetId := LV.GetText(LV.GetNext(), LV.svanerWrapper.titleKeys.findIndex(key => key == "idNum"))
            PMN_Fillin.fill(listContent.value.find(item => item["idNum"] == targetId), settings.value["fillOverwrite"])
        }
    }

    ; QM2 agent
    showQm2Panel(*) {
        if (searchBy.value != "waterfall") {
            return
        }

        LV := App["guest-profile-list"]

        ; pick selected guests
        checkedRows := LV.getCheckedRowNumbers()
        if (!checkedRows.Length) {
            QM2_Panel({
                overwriteProfiles: settings.value["fillOverwrite"],
                limitDate: App["limit-date-btn"].Value ? queryFilter.value.date : ""
            })
            return
        }

        selectedGuests := checkedRows.map(row => listContent.value[row])
        groupedSelectedGuests := Map()
        for guest in selectedGuests {
            if (groupedSelectedGuests.Has(guest["roomNum"])) {
                groupedSelectedGuests[guest["roomNum"]].Push(guest)
            }
            else {
                groupedSelectedGuests[guest["roomNum"]] := [guest]
            }
        }

        QM2_Panel({
            overwriteProfiles: settings.value["fillOverwrite"],
            selectedGuests: groupedSelectedGuests,
            limitDate: App["limit-date-btn"].Value ? queryFilter.value.date : ""
        })
    }


    onMount() {
        ; hotkey setup
        HotIfWinActive(POPUP_TITLE)
        Hotkey("!f", (*) => App["searchBox"].Focus())
        Hotkey("!Left", (*) => toggleDate("-"))
        Hotkey("!Right", (*) => toggleDate("+"))
        Hotkey("!Up", (*) => toggleRange("+"))
        Hotkey("!Down", (*) => toggleRange("-"))

        toggleDate(direction) {
            diff := direction == "-" ? -1 : 1

            dt := App["type:DateTime"]
            dt.Value := DateAdd(dt.Value, diff, "Days")
            queryFilter.update("date", FormatTime(dt.Value, "yyyyMMdd"))
            handleListContentUpdate()
        }

        toggleRange(direction) {
            range := App["range"]
            if (!range.value) {
                range.value := 0
            }
            newRange := direction = "-" ? range.value - 10 : range.value + 10

            if (newRange <= 0) {
                return
            }

            range.value := newRange
            queryFilter.update("range", newRange)
            handleListContentUpdate()
        }

        ; bind check status
        shareCheckStatus(App["select-all-btn"], App["guest-profile-list"])
    }


    render() {
        App.AddGroupBox("Section y+20 w685 h420", "")
        App.AddText("xp15", moduleTitle . " ⓘ ").onClick((*) => PMN_Settings(settings, listContent))

        ; agent mode
        App.AddCheckBox("vdelegate-check-box x+10 Disabled", "后台代行", { check: isDelegate })
            .bind()
            .onClick(handleDelegateActivate)
        App.AddText("vconnection-status x+20 w80 Hidden", " {1}", serverConnection)

        ; datetime
        App.AddDateTime("vdate xs15 yp+25 w90 h25", "yyyy/MM/dd")
            .onChange((ctrl, _) => (
                queryFilter.update("date", FormatTime(ctrl.Value, "yyyyMMdd"))
                handleListContentUpdate()
            ))
        ; search conditions
        App.AddDDL("x+10 w80 Choose2", searchByMap.keys())
            .onChange((ctrl, _) => searchBy.set(searchByMap[ctrl.Text]))

        ; search box
        App.AddEdit("vsearchBox x+5 w125 h25")
            .onChange((ctrl, _) => queryFilter.update("search", Trim(ctrl.Value)))

        ; range
        App.AddText("x+10 h25 0x200", "最近")
        App.AddEdit("vrange Number x+1 w30 h25", queryFilter.value.range)
            .onChange((ctrl, _) => queryFilter.update("range", !ctrl.Value ? 60 * 24 : ctrl.Value))
        App.AddText("x+1 h25 0x200", "分钟")

        ; refresh/fill
        App.AddButton("vrefresh x+10 w80 h25", "刷 新(&R)").onClick(handleRefresh)
        App.AddButton("vfillin x+5 w80 h25 Default", "{1}", fillBtnText)
            .onClick(fillPmsProfile)
            .onContextMenu((*) => settings.update("fillOverwrite", o => !o))

        ; qm2 agent
        App.AddButton("vqm2-agent x+5 w80 h25 Disabled", "&QM2 Agent").onClick(showQm2Panel)

        ; profile list
        GuestProfileList(App, db, listContent, queryFilter, searchBy, fillPmsProfile, handleListContentUpdate)

        ; sent posts
        Show(() => SentPosts(App, isDelegate, listContent), isDelegate, cur => cur == true)

        ; waterfall controls
        Show(() => [
            App.AddCheckBox("vselect-all-btn Hidden w80 h25 @align[x]:date y+5", "全选 (&A)"),
            App.AddCheckBox("vlimit-date-btn Checked h25 x+15 0x200", "限定搜索日期")
        ], searchBy, cur => cur == "waterfall")

        ; offline controls
        OfflineControls(App, queryFilter)
    }

    return (
        render(),
        onMount()
    )
}