class FedexBookingEntry {
    static isRunning := false

    static start(config := {}) {
        c := useProps(config, {
            setOnTop: false,
            blockInput: false
        })

        this.isRunning := true
        HotIf((*) => this.isRunning)
        Hotkey("F12", (*) => this.end(), "On")

        CoordMode("Pixel", "Screen")
        CoordMode("Mouse", "Screen")

        WinActivate("ahk_class SunAwtFrame")
        WinSetAlwaysOnTop(c.setOnTop, "ahk_class SunAwtFrame")

        BlockInput(c.blockInput)

        SUSPEND_CONTROLLER.suspendOtherScripts()
    }

    static end() {
        this.isRunning := false
        Hotkey("F12", "Off")

        WinSetAlwaysOnTop(false, "ahk_class SunAwtFrame")
        BlockInput(false)

        SUSPEND_CONTROLLER.restoreAllScripts()
    }

    static dismissPopup() {
        loop {
            if (
                ImageSearch(&_, &_, 0, 0, A_ScreenWidth, A_ScreenHeight, IMAGES["alert.png"])
                || ImageSearch(&_, &_, 0, 0, A_ScreenWidth, A_ScreenHeight, IMAGES["info.png"])
            ) {
                Send("{Escape}")
                utils.waitLoading()
                Sleep(200)
            } else {
                utils.waitLoading()
                break
            }
        }
    }

    static USE(infoObj, index := 1, bringForwardTime := 10) {
        schdCiDate := infoObj["ciDate"]
        schdCoDate := infoObj["coDate"]

        pmsCiDate := StrSplit(infoObj["ETA"], ":")[1] < bringForwardTime
            ? DateAdd(schdCiDate, -1, "days")
            : schdCiDate
        pmsCoDate := schdCoDate
        pmsNts := DateDiff(pmsCoDate, pmsCiDate, "days")
        ; reformat to match pms date format
        schdCiDate := FormatTime(schdCiDate, "MMddyyyy")
        schdCoDate := FormatTime(schdCoDate, "MMddyyyy")
        pmsCiDate := FormatTime(pmsCiDate, "MMddyyyy")
        pmsCoDate := FormatTime(pmsCoDate, "MMddyyyy")

        ; workflow start
        this.start()

        isCheckedIn := ImageSearch(&_, &_, 0, 0, A_ScreenWidth, A_ScreenHeight, IMAGES["isCheckedIn.png"])
        if (!isCheckedIn) {
            this.profileEntry(infoObj["crewNames"], index)
        }
        if (!this.isRunning) {
            msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
            return
        }

        this.dateTimeEntry(pmsCiDate, pmsCoDate, infoObj["ETA"], infoObj["ETD"], isCheckedIn)
        if (!this.isRunning) {
            msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
            return
        }

        this.moreFieldsEntry(schdCiDate, schdCoDate, infoObj["ETA"], infoObj["ETD"], infoObj["flightIn"], infoObj["flightOut"])
        if (!this.isRunning) {
            msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
            return
        }

        this.commentEntry(infoObj)
        if (!this.isRunning) {
            msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
            return
        }

        this.dailyDetailsEntry(infoObj["daysActual"], pmsNts)
        if (!this.isRunning) {
            msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
            return
        }

        ; post Alert reminder when room charge needs to be post manually
        if (infoObj["daysActual"] > pmsNts) {
            this.postRoomChargeAlertEntry(pmsNts, infoObj["daysActual"])
            if (!this.isRunning) {
                msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
                return
            }
        }

        this.crsNumEntry(infoObj["tracking"])
        if (!this.isRunning) {
            msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
            return
        }

        MsgBox("Completed.", "Reservation Handler", "T1 4096")
        this.end()
    }


    static profileEntry(crewNames, index, initX := 471, initY := 217) {
        crewName := StrSplit(crewNames[index], " ")

        ; open profile
        found := PmsImageFinder.find("AltNameAnchor.png", 5)
        if (!found) {
            MsgBox("界面定位失败，请重新打开预订界面。", POPUP_TITLE, "4096 T2")
            this.end()
        }

        Click(found.outX - 10, found.outY)
        utils.waitLoading()
        Click(found.outX - 91, found.outY + 338)
        utils.waitLoading()
        Send(Format("{Text}{1}", crewName[2]))
        utils.waitLoading()
        Send("{Tab}")
        utils.waitLoading()
        Send(Format("{Text}{1}", crewName[1]))
        utils.waitLoading()
        Send("{Tab}")
        utils.waitLoading()

        ; check profile existence
        CoordMode("Pixel", "Screen")
        if (PixelGetColor(found.outX + 109, found.outY + 288) != "0x0000FF") { ; profile is found 580, 505
            Send("{Enter}")
            utils.waitLoading()
        } else { ; profile not found, create a new one
            Send("{Enter}")
            utils.waitLoading()
            Send("!n")
            utils.waitLoading()
            Send("{Esc}")
            utils.waitLoading()
            Click(found.outX - 39, found.outY + 68, 3) ; 432, 285
            utils.waitLoading()
            Send(Format("{Text}{1}", crewName[2]))
            Click(found.outX - 72, found.outY + 95, 3) ; 399, 312
            utils.waitLoading()
            Send(Format("{Text}{1}", crewName[1]))
            utils.waitLoading()
        }
        Send("!o")
        utils.waitLoading()
    }


    static dateTimeEntry(checkin, checkout, ETA, ETD, isCheckedIn) {
        found := PmsImageFinder.find("opera-active-win.png", 5)
        if (!found) {
            MsgBox("界面定位失败，请重新打开预订界面。", POPUP_TITLE, "4096 T2")
            this.end()
        }

        ; set nts to 0 as init
        Click(found.outX + 88, found.outY + 194, 3)
        utils.waitLoading()
        Send("{Delete}")
        utils.waitLoading()
        Send("{Tab}")
        utils.waitLoading()
        Send("{Delete}")
        utils.waitLoading()
        Send("!s")
        utils.waitLoading()
        this.dismissPopup()

        ; fill-in checkin/checkout
        if (!isCheckedIn) {
            Click(found.outX + 154, found.outY + 176)
            utils.waitLoading()
            Send("!c")
            utils.waitLoading()
            Send(Format("{Text}{1}", checkin))
            utils.waitLoading()
            Send("{Tab}")
            utils.waitLoading()
            this.dismissPopup()
        }

        Click(found.outX + 154, found.outY + 220)
        utils.waitLoading()
        Send("!c")
        utils.waitLoading()
        Send(Format("{Text}{1}", checkout))
        utils.waitLoading()
        Send("{Enter}")
        utils.waitLoading()
        this.dismissPopup()

        if (!isCheckedIn) {
            Click(found.outX + 124, found.outY + 415, 3)
            utils.waitLoading()
            Send(Format("{Text}{1}", ETA))
            utils.waitLoading()
            Send("{Tab}")
            utils.waitLoading()
        }

        Click(found.outX + 258, found.outY + 415, 3)
        utils.waitLoading()
        Send(Format("{Text}{1}", ETD))
        Send("{Tab}")
        utils.waitLoading()
    }


    static moreFieldsEntry(scheduledCheckin, scheduledCheckout, ETA, ETD, flightIn, flightOut) {
        Send("!i")
        utils.waitLoading()
        Sleep(250)
        
        found := PmsImageFinder.find("opera-active-win.png", 5)
        if (!found) {
            MsgBox("界面定位失败，请重新打开预订界面。", POPUP_TITLE, "4096 T2")
            this.end()
        }

        Click(found.outX + 475, found.outY + 113, 3)
        utils.waitLoading()
        Send(Format("{Text}{1}", flightIn))
        utils.waitLoading()
        loop 2 {
            Send("{Tab}")
            utils.waitLoading()
        }

        Send(Format("{Text}{1}", scheduledCheckin))
        Sleep(100)
        Send("{Tab}")
        utils.waitLoading()
        Send(Format("{Text}{1}", ETA))
        utils.waitLoading()

        Click(found.outX + 713, found.outY + 113, 2)
        utils.waitLoading()
        Send(Format("{Text}{1}", flightOut))
        utils.waitLoading()
        loop 2 {
            Send("{Tab}")
            utils.waitLoading()
        }
        utils.waitLoading()
        Send(Format("{Text}{1}", scheduledCheckout))
        utils.waitLoading()
        Send("{Tab}")
        utils.waitLoading()
        Send(Format("{Text}{1}", ETD))
        utils.waitLoading()
        Send("!o")
        utils.waitLoading()
        this.dismissPopup()
    }


    static commentEntry(infoObj) {
        found := PmsImageFinder.find("opera-active-win.png", 5)
        if (!found) {
            MsgBox("界面定位失败，请重新打开预订界面。", POPUP_TITLE, "4096 T2")
            this.end()
        }
        comment := ""

        ; select current comment
        MouseMove(found.outX + 426, found.outY + 412)
        Click("Down")
        MouseMove(found.outX + 944, found.outY + 421)
        Sleep(1000) ; hold to cover long comment
        Click("Up")
        utils.waitLoading()
        Send("^x")
        utils.waitLoading()

        ; set new comment
        if (infoObj["resvType"] == "ADD") {
            comment := Format(
                "RM INCL 1BBF TO CO,Hours@Hotel: {1}={2}day(s), ActualStay: {3}-{4}",
                infoObj["stayHours"],
                infoObj["daysActual"],
                infoObj["ciDate"],
                infoObj["coDate"]
            )
        } else {
            prevComment := A_Clipboard.split(',').map(c => c.trim())
            comment := Format(
                "{1}, {2}, CHANGE:{3}={4}day(s), ActualStay: {5}-{6}",
                prevComment[1],
                prevComment[2],
                infoObj["stayHours"],
                infoObj["daysActual"],
                infoObj["ciDate"],
                infoObj["coDate"]
            )
        }

        Send(Format("{Text}{1}", comment))
        utils.waitLoading()

        ; fill-in new flight and trip
        Click(found.outX + 733, found.outY + 370, 3) ; 929, 554
        utils.waitLoading()
        Send(Format("{Text}{1}  {2}", infoObj["flightIn"], infoObj["tripNum"]))
        utils.waitLoading()
    }


    static dailyDetailsEntry(daysActual, pmsNts) {
        found := PmsImageFinder.find("opera-active-win.png", 5)
        if (!found) {
            MsgBox("界面定位失败，请重新打开预订界面。", POPUP_TITLE, "4096 T2")
            this.end()
        }

        Click(found.outX + 176, found.outY + 340, 3) ; 372, 524
        utils.waitLoading()
        Send("!d")
        utils.waitLoading()
        loop daysActual {
            Send("{Down}")
            utils.waitLoading()
        }
        Send("!e")
        utils.waitLoading()
        Sleep(100)

        ; opend daily details editor
        found := PmsImageFinder.find("opera-active-win.png", 5)
        if (!found) {
            MsgBox("界面定位失败，请重新打开预订界面。", POPUP_TITLE, "4096 T2")
            this.end()
        }

        Click(found.outX + 226, found.outY + 142, 3)
        Send("{Text}" . (daysActual < pmsNts ? "NRR" : "FEDEXN"))
        utils.waitLoading()
        Send("{Tab}")
        utils.waitLoading()
        this.dismissPopup()

        utils.waitLoading()
        Send("!o")
        utils.waitLoading()
        this.dismissPopup()
        Send("!o")
        utils.waitLoading()
        this.dismissPopup()
    }

    static postRoomChargeAlertEntry(pmsNts, daysActual) {
        Send("!t")
        utils.waitLoading()
        loop 3 {
            Send("{Down}")
            utils.waitLoading()
        }
        Send("{Enter}")
        utils.waitLoading()

        found := PmsImageFinder.find("opera-active-win.png", 5)
        if (!found) {
            MsgBox("界面定位失败，请重新打开预订界面。", POPUP_TITLE, "4096 T2")
            this.end()
        }

        if (PixelGetColor(found.outX + 55, found.outY + 55) == "0x000080") {
            Send("!n")
            utils.waitLoading()
        }

        Send("{Text}OTH")
        utils.waitLoading()
        Send("{Tab}")
        utils.waitLoading()
        loop 2 {
            Send("{Up}")
            Sleep(100)
        }
        Send("{Tab}")
        utils.waitLoading()
        loop 25 {
            Send("{Delete}")
        }
        Send(Format("{Text}实际需收取 {1} 晚房费。退房请补入 {2} 晚房费。", daysActual, daysActual - pmsNts))
        utils.waitLoading()
        Send("!o")
        utils.waitLoading()
        Send("!c")
        utils.waitLoading()
        Send("!c")
        utils.waitLoading()
    }


    static crsNumEntry(tracking) {
        found := PmsImageFinder.find("opera-active-win.png", 5)
        if (!found) {
            MsgBox("界面定位失败，请重新打开预订界面。", POPUP_TITLE, "4096 T2")
            this.end()
        }

        ; MouseMove(initX + 543, initY + 321)
        ; utils.waitLoading()
        ; Click()
        Click(found.outX + 543, found.outY + 321)
        utils.waitLoading()

        ; check if record exists
        Send("!e")
        utils.waitLoading()

        ; open crs. number editor
        found := PmsImageFinder.find("opera-active-win.png", 5)
        if (!found) {
            MsgBox("界面定位失败，请重新打开预订界面。", POPUP_TITLE, "4096 T2")
            this.end()
        }

        if (PixelGetColor(found.outX + 64, found.outY + 55) == "0xD7D7D7") {
            Send("{Tab}")
            utils.waitLoading()
            Send("^c")
            utils.waitLoading()
            if (!A_Clipboard.includes(tracking)) {
                loop 10 {
                    Send("^{Left}")
                }
                Send("{Text}" . tracking . "/")
                utils.waitLoading()
            }
        } else {
            Send("!n")
            utils.waitLoading()
            Send("{Tab}")
            utils.waitLoading()
            Send("{Text}MIGRATION")
            utils.waitLoading()
            Send("{Tab}")
            utils.waitLoading()
            Send("{Text}" . tracking)
            utils.waitLoading()
        }

        Send("!o")
        utils.waitLoading()

        Send("!c")
        utils.waitLoading()
    }
}
