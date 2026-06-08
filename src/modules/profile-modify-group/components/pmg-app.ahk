/**
 * @param {Svaner} App 
 * @param {String} popupTitle 
 * @param {useFileDB} db 
 */
PMG_App(App, popupTitle, db) {
    selectedGroup := signal(Map())
    currentGroupRooms := signal([])
    fetchPeriod := signal(CONFIG.read("matchRangeHour"))
    loadedGuests := signal([])

    effect(selectedGroup, handleGroupSelect)
    handleGroupSelect(curSelectedGroup) {
        if (!FileExist(A_MyDocuments . "\" . curSelectedGroup["blockCode"] . ".XML")) {
            useListPlaceholder(loadedGuests, ["roomNum", "name"], "No Data")
            return
        }

        handleListInitialize()
    }

    handleListInitialize(args*) {
        if (args.Length > 0) {
            PMG_Data.reportFiling(selectedGroup.value["blockCode"])
        }

        useListPlaceholder(loadedGuests, ["roomNum", "name"], "Loading...")

        groupRoomNums := PMG_Data.getGroupRoomNumbers(A_MyDocuments . "\" . selectedGroup.value["blockCode"] . ".XML")
        guestProfiles := PMG_Data.getGroupGuests(db, groupRoomNums, fetchPeriod.value)

        currentGroupRooms.set(groupRoomNums)
        loadedGuests.set(guestProfiles.Length == 0 ? [{ roomNum: "Nil", name: "Nil" }] : guestProfiles)
    }

    performModify(*) {
        checkedRows := App["group-guest-list"].getCheckedRowNumbers()
        selectedGuests := checkedRows.map(row => loadedGuests.value[row])
        groupedSelectedGuests := Map()
        for room in currentGroupRooms.value {
            groupedSelectedGuests[room] := []
        }

        for guest in selectedGuests {
            groupedSelectedGuests[guest["roomNum"]].Push(guest)
        }


        PMG_Execute.startModify(currentGroupRooms.value, groupedSelectedGuests)
    }

    return StackBox(
        App, {
            groupbox: {
                title: popupTitle . " ⓘ ",
                options: "Section y+20 w685 h410",
            }
        },
        () => [
            ; due in groups
            OnDayGroups(App, selectedGroup),
            ; btns
            App.AddButton("@align[x]:block-list y+5 w145 h35", "获取旅客").onClick(handleListInitialize),
            App.AddButton("x+10 w145 h35", "开始录入").onClick(performModify),
            ; matched guests
            GroupGuestList(App, loadedGuests)
        ]
    )
}