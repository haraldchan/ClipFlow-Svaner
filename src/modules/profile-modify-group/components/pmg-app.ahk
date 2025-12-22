PMG_App(App, popupTitle, db) {
    selectedGroup := signal(Map())
    currentGroupRooms := signal([])
    fetchPeriod := signal(5)
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
        checkedRows := App.getCtrlByType("ListView").getCheckedRowNumbers()
        selectedGuests := []
        for row in checkedRows {
            selectedGuests.Push(loadedGuests.value[row])
        }

        PMG_Execute.startModify(currentGroupRooms.value, selectedGuests)
    }

    return (
        App.AddGroupBox("R16 y+20 w685", " "),
        App.AddText("xp15 ", popupTitle . " ⓘ ")
           .OnEvent("Click", (*) => PMG_Settings(fetchPeriod)),

        ; shows due in groups
        OnDayGroups(App, selectedGroup),
        App.AddButton("x40 y470 w115 h35", "获取旅客").OnEvent("Click", handleListInitialize),
        App.AddButton("x+15 w115 h35", "开始录入").OnEvent("Click", performModify),

        ; matching guests
        GroupGuestList(App, loadedGuests)
    )
}