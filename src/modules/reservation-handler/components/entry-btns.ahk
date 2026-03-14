EntryBtns(App, curResv) {
    effect(curResv, handleEntryBtnUpdate)
    handleEntryBtnUpdate(cur) {
        entryBtns := [App["entry1"], App["entry2"]]

        if (cur["agent"] == "fedex") {
            crewLastNames := cur["crewNames"].map(name => name.split(" ")[2])

            for btn in entryBtns {
                exist := crewLastNames.has(A_Index)
                btn.Text := exist ? cur["crewNames"][A_Index] : ""
            }

            return
        }

        entryBtns[1].Text := "录入订单"
        entryBtns[2].Text := cur["roomQty"] > 1 ? "录入整个 Party " : ""
    }

    handleEntry(ctrl, _) {
        if (!ctrl.Text) {
            return
        }

        App.Hide()
        Sleep 200

        if (curResv.value["agent"] == "fedex") {
            FedexBookingEntry.USE(curResv.value, ctrl.name == "entry1" ? 1 : 2)
        } else {
            OTA_Formatter.USE(
                curResv.value,
                ctrl.name == "entry2" ? true : false,
                App["with-remarks"].Value,
                App["with-trace"].Value,
                App["extra-packages"].Value.trim(),
                App["overriden-ratecode"].Value.trim()
            )

            App["with-remarks"].Value := false
            App["with-trace"].Value := false
            App["extra-packages"].Value := ""
            App["overriden-ratecode"].Value := ""
        }
    }

    return (
        App.AddGroupBox("Section y+10 w310 h70", "录入订单"),
        App.AddButton("ventry1 xs10 w140 h40 yp+20", "").OnEvent("Click", handleEntry),
        App.AddButton("ventry2 w140 x+10 h40", "").OnEvent("Click", handleEntry)
    )
}