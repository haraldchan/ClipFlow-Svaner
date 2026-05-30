class PMG_Execute {
    /**
     * 
     * @param {Array} inhRooms selected room numbers
     * @param groupGuests grouped guest profiles
     */
    static startModify(inhRooms, groupGuests) {
        PMN_FillIn.start()

        if (utils.checkClearWin(POPUP_TITLE, IMAGES["opera-logo.png"]) = "Cancel") {
            utils.cleanReload(WIN_GROUP)
        }
        this.openInHouse()

        BlankShare_Action.isRunning := true
        for room, profiles in groupGuests {
            res := BlankShare_Action.search(room)
            if (!res) {
                continue
            }

            ; make shares if needed
            existShare := BlankShare_Action.getExistShares()
            if (existShare < (profiles.Length - existShare)) {
                sharesToMake := profiles.Length - existShare
                BlankShare_Action.makeShare(true, sharesToMake, true)
                if (!BlankShare_Action.isRunning) {
                    MsgBox("脚本已终止", POPUP_TITLE, "4096 T1 icon!")
                    return
                }
            }

            ; cascade one room at a time
            PMN_Waterfall.cascade(Map(room, profiles), false)
        }

        BlankShare.isRunning := false
        PMN_FillIn.end()
        Sleep(1000)
        MsgBox("Group Modify 已完成。")
    }


    static openInHouse() {
        WinActivate("ahk_class SunAwtFrame")
        Send("!f")
        utils.waitLoading()
        Send("{Text}i")
        utils.waitLoading()
        Sleep(500)
    }
}
