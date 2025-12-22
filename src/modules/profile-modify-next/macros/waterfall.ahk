class PMN_Waterfall {
    static cascade(groupedSelectedGuests, isOverwrite, party := "") {
        PMN_FillIn.start()

        for roomProfiles in groupedSelectedGuests {
            for guest in roomProfiles.values()[1] {
                res := this.search(guest["roomNum"], A_Index, party)
                if (res == "not found") {
                    return "Room not found"
                }

                if (!PMN_FillIn.isRunning) {
                    msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
                    return "Ended Unexpectedly"
                }

                this.modify(guest, isOverwrite)
                Sleep 1000

                if (!PMN_FillIn.isRunning) {
                    msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
                    return "Ended Unexpectedly"
                }
            }
        }

        PMN_FillIn.end()
        MsgBox("已完成全部选中 Profile 录入。", "Waterfall cascaded", "4096 T1")
    }

    static handleWindowError() {
        PMN_FillIn.end()
        ; clear err popup
        loop 2 {
            Send "!o"
            utils.waitLoading()
        }

        ; close all windows
        loop {
            Send "!w"
            Sleep 100
            Send "{Up}"
            Sleep 100
            Send "{Enter}"
            Sleep 100
            Send "!c"
            utils.waitLoading()
            Send "{Esc}"
            utils.waitLoading()

            if (ImageSearch(&_, &_, 0, 0, A_ScreenWidth, A_ScreenWidth, IMAGES["opera-logo.PNG"])) {
                break
            }
        }

        ; restore In-house window
        Send "!f"
        utils.waitLoading()
        Send "{Down}"
        Sleep 100
        Send "{Enter}"
        utils.waitLoading()
    }

    static search(roomNum, index, party := 0) {
        formattedRoom := StrLen(roomNum) = 3 ? "0" . roomNum : roomNum

        Send "!r"
        utils.waitLoading()
        if (!PMN_FillIn.isRunning) {
            msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
            return
        }

        Send formattedRoom
        utils.waitLoading()

        if (party) {
            loop 16 {
                Send "{Tab}"
                Sleep 10
            }
            Send "{Text}" . party
            utils.waitLoading()
        }

        Send "!h" ; alt+h => search
        utils.waitLoading()

        CoordMode "Pixel", "Screen"
        if (ImageSearch(&_, &_, 0, 0, A_ScreenWidth, A_ScreenHeight, IMAGES["info.PNG"])) {
            Send "{Enter}"
            PMN_FillIn.end()
            return "not found"
        }

        if (!PMN_FillIn.isRunning) {
            msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
            return
        }

        ; sort by Prs.
        Click 838, 378, "Right"
        Sleep 200
        Send "{Down}"
        Sleep 200
        Send "{Enter}"
        utils.waitLoading()
        if (!PMN_FillIn.isRunning) {
            msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
            return
        }
        if (ImageSearch(&_, &_, 0, 0, A_ScreenWidth, A_ScreenWidth, IMAGES["error.png"])) {
            return this.handleWindowError()
        }

        ; choose resv
        loop (index - 1) {
            Send "{Down}"
            utils.waitLoading()
        }

        utils.waitLoading()
    }

    static modify(guest, isOverwrite) {
        Send "!p" ; open profile
        utils.waitLoading()

        PMN_FillIn.fill(guest, isOverwrite, true)
        utils.waitLoading()
        ; Sleep 1000

        Send "!o" ; ok
        utils.waitLoading()
        sleep 1000
    }
}