GroupGuestList(App, loadedGuests) {
    onMount() {
        shareCheckStatus(App["check-all"], App["group-guest-list"])
    }

    return (
        App.AddCheckBox("vcheck-all Checked @relative[x+10]:block-list y120", " 全选").SetFont("bold s10"),
        App.AddListView(
            {
                lvOptions: "vgroup-guest-list Checked Grid NoSortHdr LV0x4000 @relative[x+10]:block-list @align[yhw]:block-list",
                itemOptions: "Check"
            },
            {
                keys: ["roomNum", "name", "addr"],
                titles: ["房号", "姓名", "地址"],
                widths: [70, 120, 120]
            }, 
            loadedGuests
        )
    )
}
