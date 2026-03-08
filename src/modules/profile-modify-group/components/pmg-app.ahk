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

        groupInfo := PMG_Data.getGroupHouseInformations(A_MyDocuments . "\" . selectedGroup.value["blockCode"] . ".XML")
        guestInfo := PMG_Data.getGroupGuests(db, groupInfo["inhRooms"], fetchPeriod.value)

        currentGroupRooms.set(groupInfo["inhRooms"])
        loadedGuests.set(guestInfo.Length == 0 ? [{ roomNum: "Nil", name: "Nil" }] : guestInfo)
    }

    performModify(*) {
        checkedRows := App["group-guest-list"].getCheckedRowNumbers()
        selectedGuests := []
        for row in checkedRows {
            selectedGuests.Push(loadedGuests.value[row])
        }

        PMG_Execute.startModify(currentGroupRooms.value, selectedGuests)
    }

    return (
        StackBox(
            App,
            {
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
    )
}
