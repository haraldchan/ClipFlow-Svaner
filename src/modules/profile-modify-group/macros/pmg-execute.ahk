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

        ; uInhRooms := inhRooms.unique()
        ; index := 1
        ; curRoom := signal("")

        ; for room in uInhRooms {
        ;     curRoom.set(room)

        ;     for guest in groupGuests {
        ;         remaining := groupGuests.filter(g => g["roomNum"] = curRoom.value).Length
        ;         isNewShare := false

        ;         if (index > inhRooms.filter(r => r == curRoom.value).Length && remaining > 0) {
        ;             this.search(room, 1, isNewShare) ; find main resv and make share on it
        ;             if (!PMN_FillIn.isRunning) {
        ;                 msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
        ;                 return
        ;             }
        ;             this.makeShare()
        ;             isNewShare := true
        ;             if (!PMN_FillIn.isRunning) {
        ;                 msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
        ;                 return
        ;             }
        ;             Send("!r") ; clear
        ;         }

        ;         if (guest["roomNum"] == room) {
        ;             this.search(room, index, isNewShare)
        ;             utils.waitLoading()
        ;             this.modify(guest)
        ;             if (!PMN_FillIn.isRunning) {
        ;                 msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
        ;                 return
        ;             }
        ;             guest["roomNum"] := ""
        ;             index := (remaining = 1) ? 1 : index + 1
        ;         }

        ;         if (remaining == 1) {
        ;             break
        ;         }
        ;     }
        ; }

        for room, profiles in groupGuests {
            res := BlankShare_Action.search(room)
            if (!res) {
                continue
            }

            ; make shares if needed
            existShare := BlankShare_Action.getExistShares()
            if (existShare < profiles.Length) {
                sharesToMake := profiles.Length - existShare
                BlankShare_Action.makeShare(true, sharesToMake, true)
                if (!BlankShare_Action.isRunning) {
                    MsgBox("脚本已终止", POPUP_TITLE, "4096 T1 icon!")
                    return
                }
            }

            ; cascade one room at a time
            PMN_Waterfall.cascade(Map(room, profiles), false)
            if (!PMN_FillIn.isRunning) {
                MsgBox("脚本已终止", POPUP_TITLE, "4096 T1 icon!")
                return
            }
        }

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

    ; static search(roomNum, index, isNewShare) {
    ;     formattedRoom := StrLen(roomNum) == 3 ? "0" . roomNum : roomNum

    ;     Send("!r") ; room number field
    ;     utils.waitLoading()

    ;     Send(formattedRoom)
    ;     utils.waitLoading()

    ;     if (isNewShare) {
    ;         Send("{Tab}")
    ;         utils.waitLoading()
    ;         Send("{Text}1")
    ;         utils.waitLoading()
    ;     }

    ;     Send("!h") ; alt+h => search
    ;     utils.waitLoading()
    ;     if (!PMN_FillIn.isRunning) {
    ;         msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
    ;         return
    ;     }

    ;     ; sort by Prs.
    ; 	found := PmsImageFinder.find("opera-active-win.PNG")
    ; 	if (!found) {
    ; 		this.isRunning := false
    ; 	}
    ; 	else {
    ; 		Click(found.outX + 672, found.outY + 222, "Right")
    ; 		Sleep(200)
    ; 		Send("{Down}")
    ; 		Sleep(200)
    ; 		Send("{Enter}")
    ; 	}

    ;     if (!PMN_FillIn.isRunning) {
    ;         msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
    ;         return
    ;     }

    ;     ; choose resv
    ;     loop (index - 1) {
    ;         Send("{Down}")
    ;         utils.waitLoading()
    ;     }
    ; }


    ; static modify(guest) {
    ;     Send("!p") ; open profile
    ;     utils.waitLoading()
    ;     ; sleep 1000

    ;     PMN_FillIn.fill(guest, false, true)
    ;     Sleep(1100)
    ;     Send("!o") ; ok

    ;     utils.waitLoading()
    ;     ; sleep 1000
    ;     Send("!r") ; clear
    ; }

    ; static makeShare(initX := 949, initY := 599) {
    ;     Send("!t")
    ;     utils.waitLoading()
    ;     Send("!s")
    ;     utils.waitLoading()
    ;     Send("!m")
    ;     utils.waitLoading()
    ;     Send("{Esc}")
    ;     utils.waitLoading()
    ;     Send("{Text}1")
    ;     utils.waitLoading()
    ;     loop 4 {
    ;         Send("{Tab}")
    ;         utils.waitLoading()
    ;     }
    ;     if (!PMN_FillIn.isRunning) {
    ;         msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
    ;         return
    ;     }
    ;     Send("{Text}0")
    ;     utils.waitLoading()
    ;     Send("{Tab}")
    ;     utils.waitLoading()
    ;     Send("{Tab}")
    ;     utils.waitLoading()
    ;     Send("{Text}6")
    ;     utils.waitLoading()
    ;     if (!PMN_FillIn.isRunning) {
    ;         msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
    ;         return
    ;     }

    ;     ; TODO: change the flow, keep no post

    ;     Send("!o")
    ;     utils.waitLoading()
    ;     Send("!r")
    ;     utils.waitLoading()
    ;     MouseMove(initX, initY) ; 949, 599
    ;     utils.waitLoading()
    ;     Click()
    ;     utils.waitLoading()
    ;     Send("!d")
    ;     MouseMove(initX - 338, initY - 53) ; 611, 546
    ;     utils.waitLoading()
    ;     Click()
    ;     utils.waitLoading()
    ;     Send("!c")
    ;     MouseMove(initX - 625, initY - 92) ; 324, 507
    ;     utils.waitLoading()
    ;     if (!PMN_FillIn.isRunning) {
    ;         msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
    ;         return
    ;     }

    ;     Click("Down")
    ;     MouseMove(initX - 737, initY - 79) ; 212, 520
    ;     utils.waitLoading()
    ;     Click("Up")
    ;     utils.waitLoading()
    ;     Send("{Text}NRR")
    ;     utils.waitLoading()
    ;     Send("!o")
    ;     utils.waitLoading()
    ;     if (!PMN_FillIn.isRunning) {
    ;         msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
    ;         return
    ;     }

    ;     loop 4 {
    ;         Send("{Esc}")
    ;         utils.waitLoading()
    ;     }
    ;     utils.waitLoading()
    ;     Send("!i")
    ;     utils.waitLoading()
    ;     loop 5 {
    ;         Send("{Esc}")
    ;         utils.waitLoading()
    ;     }
    ;     if (!PMN_FillIn.isRunning) {
    ;         msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
    ;         return
    ;     }

    ;     utils.waitLoading()
    ;     Send("{Space}")
    ;     utils.waitLoading()
    ;     Send("!o")
    ;     utils.waitLoading()
    ;     Send("!c")
    ;     utils.waitLoading()
    ; }
}