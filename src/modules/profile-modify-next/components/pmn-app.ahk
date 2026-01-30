/**
 * @param {Svaner} App 
 * @param {String} moduleTitle 
 * @param {useFileDB} db 
 * @param {String} identifier 
 */
PMN_App(App, moduleTitle, db, identifier) {
    ; server agent delegate
    delegate := signal(false)
    serverConnection := signal("")
    serverConnStatus := Map(
        "default", "Norm cBlack",
        "后台服务在线", "Bold cGreen",
        "超时无响应", "Bold cRed",
    )
    handleDelegateActivate(ctrl, _) {
        delegate.set(ctrl.Value)
        if (ctrl.Value == false) {
            return
        }
        
        ctrl.Enabled := false
        serverConnection.set("尝试连接中...")
        App["connection-status"].Visible := true

        SetTimer(() => ((
            agent.PING()
                ? (
                    serverConnection.set("后台服务在线"), 
                    SetTimer(() => App["connection-status"].Visible := false, -2000)
                ) : (
                    delegate.set(false), 
                    ctrl.Value := false, 
                    serverConnection.set("超时无响应")
                )
        ), ctrl.Enabled := true) , -100)
    }
    effect(delegate, state => App["qm2Agent"].Enabled := state)


    ; settings
    settings := signal({ fillOverwrite: false }, { asMap: true })
    fillBtnText := computed(
        [delegate, settings], 
        (curDelegate, curSettings) => handleFillInBtnTextUpdate(curDelegate, curSettings)
    )
    handleFillInBtnTextUpdate(curDelegate, curSettings) {
        curOverwrite := curSettings["fillOverwrite"]
        return (curDelegate ? (curOverwrite ? "覆盖代行" : "代 行") : (curOverwrite ? "覆盖填入" : "填 入"))
    }


    ; data states
    listContent := signal(db.load(), { asMap: true })
    queryFilter := signal({ date: FormatTime(A_Now, "yyyyMMdd"), search: "", range: 60 }, { asMap: true })


    ; list UI states/effect
    lvIsCheckedAll := signal(true)
    searchBy := signal("nameRoom")
    searchByMap := OrderedMap(
        "瀑流模式", "waterfall",
        "姓名/房号", "nameRoom",
        "证件号码", "idNum",
        "地址", "addr",
        "电话", "tel",
        "生日", "birthday",
        "时间戳 ID", "tsId",
    )

    effect(searchBy, handleSearchByChange)
    handleSearchByChange(cur) {
        App["type:ListView"].Opt(cur == "waterfall" ? "+Checked +Multi" : "-Checked -Multi")
        App["delegate-check-box"].Enabled := cur == "waterfall"
        App["selecti-all-btn"].Visible := cur == "waterfall"
        App["Party: "].Visible := cur == "waterfall"
        App["party-num"].Visible := cur == "waterfall"
        if (cur != "waterfall") {
            App["delegate-check-box"].Value := false
            delegate.set(false)
        }
    }
    

    ; incoming data handling
    currentGuest := signal(Map("idNum", 0))
    OnClipboardChange (*) => handleCaptured(identifier)
    handleCaptured(identifier) {
        if (!InStr(A_Clipboard, identifier)) {
            return
        }
        ; save a copy in mem for comparison
        incomingGuest := JSON.parse(A_Clipboard)

        ; updating from add guest modal
        if (currentGuest.value["idNum"] == incomingGuest["idNum"] && !incomingGuest["isMod"]) {
            handleGuestInfoUpdateFromAdd(incomingGuest)
            MsgBox(Format("已更新信息：{1}", incomingGuest["name"]), POPUP_TITLE, "T1.5")

        
        } 
        ; updating from saved guest modal
        else if (incomingGuest["isMod"]) {
            updatedGuest := handleGuestInfoUpdateFromMod(incomingGuest)
            if (!updatedGuest) {
                return
            }
            
            MsgBox(Format("已保存修改：{1}", updatedGuest["name"]), POPUP_TITLE, "T1.5")
        } 
        ; adding guest
        else {
            incomingGuest["fileName"] := A_Now . "==" . Random(10000, 99999)
            incomingGuest["regTime"] := A_Now

            ; handle "港澳台居民居住证" missing lastname/firstname
            if (incomingGuest["guestType"] == "港澳台居民居住证" && (!incomingGuest["nameLast"] || !incomingGuest["nameFirst"])) {
                dict := useDict()
                unpack(dict.getFullnamePinyin(incomingGuest["name"]), [&nameLast, &nameFirst])
                incomingGuest["nameLast"] := nameLast
                incomingGuest["nameFirst"] := nameFirst
            }

            db.add(JSON.stringify(incomingGuest))

            isBirthday := incomingGuest["birthday"] == FormatTime(A_Now, "yyyy-MM-dd")
            MsgBox(
                Format("已保存信息：{1}{2}", incomingGuest["name"], isBirthday ? "`n`n此客人今天生日！" : ""),
                POPUP_TITLE,
                isBirthday ? "T3" : "T1.5"
            )
        }
    

        currentGuest.set(JSON.parse(A_Clipboard))

        ; uodate date if not today
        if (queryFilter.value["date"] != FormatTime(A_Now, "yyyyMMdd")) {
            queryFilter.update("date", FormatTime(A_Now, "yyyyMMdd"))
            App.getCtrlByName("date").Value := FormatTime(A_Now, "yyyyMMdd")
        }

        handleListContentUpdate()

        ; clear clipboard
        A_Clipboard := ""
    } 

    handleGuestInfoUpdateFromAdd(captured) {
        recentGuests := db.load()
        for guest in recentGuests {
            if (guest["idNum"] == captured["idNum"]) {
                captured["regTime"] := guest["regTime"]
                captured["fileName"] := guest["fileName"]

                db.updateOne(JSON.stringify(captured), queryFilter.value["date"], guest["fileName"])
                return
            }
        }
    }

    handleGuestInfoUpdateFromMod(updater) {
        recentGuests := db.load(, , 60 * 24)
        matchedGuest := signal(Map())
        items := updater.keys()

        for guest in recentGuests {
            if (guest["tsId"] == updater["tsId"]) {
                for item in items {
                    if (InStr(updater[item], "*")) {
                        continue
                    }
                    guest[item] := updater[item]
                }
                matchedGuest.set(guest)
                break
            }
        }

        try {
            db.updateOne(JSON.stringify(matchedGuest.value), queryFilter.value["date"], matchedGuest.value["fileName"])
        } catch {
            MsgBox("无匹配目标...", POPUP_TITLE, "4096 T1.5")
            return
        }

        return matchedGuest.value
    }

    handleListContentUpdate(*) {
        colTitles := App["type:ListView"].svanerWrapper.titleKeys
        useListPlaceholder(listContent, colTitles, "Loading...")

        App["range"].Enabled := (queryFilter.value["date"] == FormatTime(A_Now, "yyyyMMdd"))
        loadedItems := db.load(, queryFilter.value["date"], queryFilter.value["range"]) 

        if (!loadedItems.Length) {
            useListPlaceholder(listContent, colTitles, "No Data")
            return
        }

        listContent.set(handleSearchResultFilter(loadedItems))
        lvIsCheckedAll.set(false)
    }

    handleSearchResultFilter(loadedItems) {
        filteredItems := []
        searchInput := queryFilter.value["search"]

        if (!searchInput) {
            return loadedItems
        }

        if (searchBy.value == "nameRoom") {
            if (IsNumber(searchInput)) {
                ; searching by room number
                for item in loadedItems {
                    if (InStr(item["roomNum"], searchInput)) {
                        filteredItems.InsertAt(1, item)
                    }
                }
            } 
            else {
                ; searching by name fragment
                for item in loadedItems {
                    if (!item.satisfies(ProfileMainland) || !item.satisfies(ProfileAbroad) || !item.satisfies(ProfileHkMoTw)) {
                        continue
                    }

                    ; from mainland
                    if (item["guestType"] == "内地旅客") {
                        if (InStr(item["name"], searchInput)) {
                            filteredItems.InsertAt(1, item)
                        }
                    } 
                    ; from HK/MO/TW
                    else if (item["guestType"] == "港澳台旅客") {
                        if (InStr(item["name"], searchInput) || InStr(item["nameLast"], searchInput) || InStr(item["nameFirst"], searchInput)) {
                            filteredItems.InsertAt(1, item)
                        }
                    } 
                    ; from abroad
                    else {
                        if (InStr(item["nameLast"], searchInput) || InStr(item["nameFirst"], searchInput)) {
                            filteredItems.InsertAt(1, item)
                        }
                    }
                }
            }
        } 
        else if (searchBy.value == "waterfall"){
            roomNums := StrSplit(queryFilter.value["search"], " ")
            ; filtering all entered room numbers
            for roomNum in roomNums {
                for item in loadedItems {
                    if (InStr(item["roomNum"], roomNum)) {
                        filteredItems.InsertAt(1, item)
                    }
                }
            }
        } 
        else if (searchBy.value == "birthday") {
            bd := StrLen(searchInput) == 8
                ? SubStr(searchInput, 1, 4) . "-" . SubStr(searchInput, 5, 2) . "-" . SubStr(searchInput, 7, 2)
                : searchInput
            for item in loadedItems {
                if (InStr(item[searchBy.value], bd)) {
                    filteredItems.InsertAt(1, item)
                }
            }
        } 
        else {
            for item in loadedItems {
                if (InStr(item[searchBy.value], searchInput)) {
                    filteredItems.InsertAt(1, item)
                }
            }
        }

        return filteredItems
    }


    ; fill in profile by actions
    fillPmsProfile(*) {
        if (!WinExist("ahk_class SunAwtFrame")) {
            MsgBox("Opera 未启动！ ", "Profile Modify Next", "T1")
            return
        }
        
        App.Hide() 
        Sleep 500 
        
        LV := App["type:ListView"]
        if (!LV.GetNext()) {
            return
        }

        if (searchBy.value == "waterfall") {
            if (!queryFilter.value["search"]) {
                MsgBox("瀑流模式必须提供房号。", POPUP_TITLE, "T2")
                App.Show()
                return
            }

            rooms := StrSplit(queryFilter.value["search"], " ")
            party := App["party-num"].Text
            App["party-num"].Text := ""

            selectedGuests := []
            ; pick selected guests
            checkedRows := LV.getCheckedRowNumbers()
            if (!checkedRows.Length) {
                MsgBox("未选中 Profile。", POPUP_TITLE, "T2")
                App.Show()
                return 
            }

            for row in LV.checkedRows {
                selectedGuests.Push(listContent.value[row])
            }

            groupedSelectedGuests := []
            for room in rooms {
                r := room
                grouped := selectedGuests.filter(g => g["roomNum"] == r)
                for guest in grouped {
                    if (guest["name"].includes("👤")) {
                        grouped.RemoveAt(A_Index)
                        grouped.InsertAt(1, guest)
                    }
                }

                groupedSelectedGuests.Push(Map(room, grouped))
            }

            if (delegate.value) {
                SetTimer(() => (
                    agent.delegate({
                        mode: "waterfall",
                        overwrite: settings.value["fillOverwrite"],
                        rooms: rooms,
                        party: party,
                        profiles: groupedSelectedGuests
                    })
                ), -250)
            } else {
                PMN_Waterfall.cascade(groupedSelectedGuests, settings.value["fillOverwrite"], party)
            }
        } else {
            targetId := LV.GetText(LV.GetNext(), LV.arcWrapper.titleKeys.findIndex(key => key == "idNum"))
            PMN_Fillin.fill(listContent.value.find(item => item["idNum"] == targetId), settings.value["fillOverwrite"])
        }
    }


    ; QM2 agent
    showQm2Panel(*) {
        if (searchBy.value != "waterfall") {
            return
        }

        LV := App["guest-profile-list"]

        selectedGuests := []
        ; pick selected guests
        checkedRows := LV.getCheckedRowNumbers()
        if (!checkedRows.Length) {
            QM2_Panel({ sendPm: false })
            return
        }

        for checkedRow in checkedRows {
            selectedGuests.Push(listContent.value[checkedRow])
        }

        rooms := StrSplit(queryFilter.value["search"], " ")
        groupedSelectedGuests := []
        for room in rooms {
            r := room
            grouped := selectedGuests.filter(g => g["roomNum"] == r)
            for guest in grouped {
                if (guest["name"].includes("👤")) {
                    grouped.RemoveAt(A_Index)
                    grouped.InsertAt(1, guest)
                }
            }

            groupedSelectedGuests.Push(Map(room, grouped))
        }

        QM2_Panel({ selectedGuests: groupedSelectedGuests })
    }


    ; hotkey setup
    setHotkeys() {
        HotIfWinActive(POPUP_TITLE)
        Hotkey "!f", (*) => App["searchBox"].Focus()
        Hotkey "!Left", (*) => toggleDate("-")
        Hotkey "!Right", (*) => toggleDate("+")
        Hotkey "!Up", (*) => toggleRange("+")
        Hotkey "!Down", (*) => toggleRange("-")
        Hotkey "!a", (*) => toggleSelectAll()

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

        toggleSelectAll() {
            if (searchBy.value != "waterfall") {
                return
            }

            lvIsCheckedAll.set(c => !c)
        }
    }


    return (
        App.AddGroupBox("Section R18 w685 y+20", ""),
        App.AddText("xp15", moduleTitle . " ⓘ ").onClick((*) => PMN_Settings(settings)),
        
        ; agent mode
        App.AddCheckBox("vdelegate-check-box x+10 Disabled", "后台代行").OnEvent("Click", handleDelegateActivate),
        App.AddText("vconnection-status x+20 w80 Hidden", " {1}", serverConnection).SetFontStyles(serverConnStatus),
        
        ; datetime
        App.AddDateTime("vdate xs15 yp+25 w90 h25", "yyyy/MM/dd")
           .onChange((ctrl, _) => (
            queryFilter.update("date", FormatTime(ctrl.Value, "yyyyMMdd")),
            handleListContentUpdate()
        )),
        
        ; search conditions
        App.AddDDL("x+10 w80 Choose2", searchByMap.keys())
           .onChange((ctrl, _) => searchBy.set(searchByMap[ctrl.Text])),
        
        ; search box
        App.AddEdit("vsearchBox x+5 w125 h25")
           .onBlur((ctrl, _) => queryFilter.update("search", Trim(ctrl.Value))),
        
        ; range
        App.AddText("x+10 h25 0x200", "最近"),
        App.AddEdit("vrange Number x+1 w30 h25", queryFilter.value["range"])
           .onChange((ctrl, _) => queryFilter.update("range", !ctrl.Value ? 60 * 24 : ctrl.Value)),
        App.AddText("x+1 h25 0x200", "分钟"),
        
        ; btns
        App.AddButton("vrefresh x+10 w80 h25", "刷 新(&R)").onClick(handleListContentUpdate),
        App.AddButton("vfillin x+5 w80 h25 Default", "{1}", fillBtnText)
           .onClick(fillPmsProfile)
           .onContextMenu((*) => settings.update("fillOverwrite", o => !o)),
        App.AddButton("vqm2-agent x+5 w80 h25", "&QM2 Agent").onClick(showQm2Panel),

        ; profile list
        GuestProfileList(App, db, listContent, queryFilter, searchBy, fillPmsProfile),

        ; waterfall controls
        App.AddCheckBox("vselecti-all-btn Hidden w80 h20 xp6 y+5", "全选 (&A)"),
        shareCheckStatus(
            App["selecti-all-btn"], 
            App["guest-profile-list"], 
            lvIsCheckedAll
        ),
        App.AddText("Hidden h20 x+15 0x200", "Party: "),
        App.AddEdit("vparty-num Hidden x+1 w100 h20", ""),

        ; hotkey setup
        setHotkeys()
    )
}