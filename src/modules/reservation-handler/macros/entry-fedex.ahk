class FedexBookingEntry {
    static isRunning := false

    static start(config := {}) {
        c := useProps(config, {
            setOnTop: false,
            blockInput: false
        })

        this.isRunning := true
        HotIf (*) => this.isRunning
        Hotkey("F12", (*) => this.end(), "On")

        CoordMode "Pixel", "Screen"
        CoordMode "Mouse", "Screen"

        WinActivate "ahk_class SunAwtFrame"
        WinSetAlwaysOnTop c.setOnTop, "ahk_class SunAwtFrame"

        BlockInput c.blockInput
    }

    static end() {
        this.isRunning := false
        Hotkey("F12", "Off")

        WinSetAlwaysOnTop false, "ahk_class SunAwtFrame"
        BlockInput false
    }

    static dismissPopup() {
        loop {
            if (
                ImageSearch(&_, &_, 0, 0, A_ScreenWidth, A_ScreenHeight, IMAGES["alert.png"])
                || ImageSearch(&_, &_, 0, 0, A_ScreenWidth, A_ScreenHeight, IMAGES["info.png"])
            ) {
                Send "{Escape}"
                utils.waitLoading()
                Sleep 200
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
        isCheckedIn := ImageSearch(&_, &_, 0, 0, A_ScreenWidth, A_ScreenHeight, A_ScriptDir . "\src\Assets\isCheckedIn.png")
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
        loop 10 {
            if (ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenWidth, IMAGES["AltNameAnchor.png"])) {
                anchorX := FoundX - 10
                anchorY := FoundY
                break
            }
            Sleep 100
        }
        MouseMove anchorX, anchorY
        utils.waitLoading()
        Click
        utils.waitLoading()

        MouseMove initX - 91, initY + 338 ; 380, 555 ; search existing profile
        utils.waitLoading()
        Click
        utils.waitLoading()
        Send Format("{Text}{1}", crewName[2])
        utils.waitLoading()
        Send "{Tab}"
        utils.waitLoading()
        Send Format("{Text}{1}", crewName[1])
        utils.waitLoading()
        Send "{Tab}"
        utils.waitLoading()

        ; check profile existence
        CoordMode "Pixel", "Screen"
        if (PixelGetColor(initX + 109, initY + 288) != "0x0000FF") { ; profile is found 580, 505
            Send "{Enter}"
            utils.waitLoading()
        } else { ; profile not found, create a new one
            Send "{Enter}"
            utils.waitLoading()
            Send "!n"
            utils.waitLoading()
            Send "{Esc}"
            utils.waitLoading()
            MouseMove initX - 39, initY + 68 ; 432, 285
            utils.waitLoading()
            Click 3
            utils.waitLoading()
            Send Format("{Text}{1}", crewName[2])
            MouseMove initX - 72, initY + 95 ; 399, 312
            utils.waitLoading()
            Click 3
            utils.waitLoading()
            Send Format("{Text}{1}", crewName[1])
            utils.waitLoading()
        }
        Send "!o"
        utils.waitLoading()
    }


    static dateTimeEntry(checkin, checkout, ETA, ETD, isCheckedIn) {
        ImageSearch(&initX, &initY, 0, 0, A_ScreenWidth, A_ScreenWidth, IMAGES["opera-active-win.png"])

        ; fill-in checkin/checkout
        if (!isCheckedIn) {
            MouseMove initX + 154, initY + 176
            utils.waitLoading()
            Click 1
            utils.waitLoading()
            Send "!c"
            utils.waitLoading()
            Send Format("{Text}{1}", checkin)
            utils.waitLoading()
            Send "{Tab}"
            utils.waitLoading()
            this.dismissPopup()
        }

        MouseMove initX + 154, initY + 220
        utils.waitLoading()
        Click
        utils.waitLoading()
        Send "!c"
        utils.waitLoading()
        Send Format("{Text}{1}", checkout)
        utils.waitLoading()
        Send "{Enter}"
        utils.waitLoading()
        this.dismissPopup()

        if (!isCheckedIn) {
            MouseMove initX + 124, initY + 415
            utils.waitLoading()
            Click 3
            utils.waitLoading()
            Send Format("{Text}{1}", ETA)
            utils.waitLoading()
            Send "{Tab}"
            utils.waitLoading()
        }

        MouseMove initX + 258, initY + 415
        utils.waitLoading()
        Click 3
        utils.waitLoading()
        Send Format("{Text}{1}", ETD)
        Send "{Tab}"
        utils.waitLoading()
    }


    static moreFieldsEntry(sCheckin, sCheckout, ETA, ETD, flightIn, flightOut) {
        Send "!i"
        utils.waitLoading()
        Sleep 250
        
        ImageSearch(&initX, &initY, 0, 0, A_ScreenWidth, A_ScreenWidth, IMAGES["opera-active-win.png"])

        MouseMove initX + 475, initY + 113
        utils.waitLoading()
        Click 3
        utils.waitLoading()
        Send Format("{Text}{1}", flightIn)
        utils.waitLoading()
        loop 2 {
            Send "{Tab}"
            utils.waitLoading()
        }

        Send Format("{Text}{1}", sCheckin)
        Sleep 100
        Send "{Tab}"
        utils.waitLoading()
        Send Format("{Text}{1}", ETA)
        utils.waitLoading()

        MouseMove initX + 713, initY + 113
        utils.waitLoading()
        Click 2
        utils.waitLoading()
        Send Format("{Text}{1}", flightOut)
        utils.waitLoading()
        loop 2 {
            Send "{Tab}"
            utils.waitLoading()
        }
        utils.waitLoading()
        Send Format("{Text}{1}", sCheckout)
        utils.waitLoading()
        Send "{Tab}"
        utils.waitLoading()
        Send Format("{Text}{1}", ETD)
        utils.waitLoading()
        Send "!o"
        utils.waitLoading()
        this.dismissPopup()
    }


    static commentEntry(infoObj) {
        ImageSearch(&initX, &initY, 0, 0, A_ScreenWidth, A_ScreenWidth, IMAGES["opera-active-win.png"])
        comment := ""

        ; select current comment
        MouseMove initX + 426, initY + 412
        Click "Down"
        MouseMove initX + 944, initY + 421
        Sleep 1000 ; hold to cover long comment
        Click "Up"

        utils.waitLoading()
        Send "^x"
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

        Send Format("{Text}{1}", comment)
        utils.waitLoading()

        ; fill-in new flight and trip
        MouseMove initX + 733, initY + 370 ; 929, 554
        utils.waitLoading()
        Click 3
        utils.waitLoading()
        Send Format("{Text}{1}  {2}", infoObj["flightIn"], infoObj["tripNum"])
        utils.waitLoading()
    }


    static dailyDetailsEntry(daysActual, pmsNts) {
        ImageSearch(&initX, &initY, 0, 0, A_ScreenWidth, A_ScreenWidth, IMAGES["opera-active-win.png"])

        MouseMove initX + 176, initY + 340 ; 372, 524
        utils.waitLoading()
        Click
        utils.waitLoading()
        Send "!d"
        utils.waitLoading()
        loop daysActual {
            Send "{Down}"
            utils.waitLoading()
        }
        Send "!e"
        utils.waitLoading()
        Sleep 100

        ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenWidth, A_ScriptDir . "\src\Assets\opera-active-win.png")
        MouseMove FoundX + 226, FoundY + 142
        Click 3
        Send "{Text}" . (daysActual < pmsNts ? "NRR" : "FEDEXN")
        utils.waitLoading()
        Send "{Tab}"
        utils.waitLoading()
        this.dismissPopup()

        utils.waitLoading()
        Send "!o"
        utils.waitLoading()
        this.dismissPopup()
        Send "!o"
        utils.waitLoading()
        this.dismissPopup()
    }

    static postRoomChargeAlertEntry(pmsNts, daysActual) {

        Send "!t"
        utils.waitLoading()
        loop 3 {
            Send "{Down}"
            utils.waitLoading()
        }
        Send "{Enter}"
        utils.waitLoading()

        ImageSearch(&popX, &popY, 0, 0, A_ScreenWidth, A_ScreenWidth, IMAGES["opera-active-win.png"])
        if (PixelGetColor(popX + 55, popY + 55) == "0x000080") {
            Send "!n"
            utils.waitLoading()
        }

        Send "{Text}OTH"
        utils.waitLoading()
        Send "{Tab}"
        utils.waitLoading()
        loop 2 {
            Send "{Up}"
            Sleep 100
        }
        Send "{Tab}"
        utils.waitLoading()
        loop 25 {
            Send "{Delete}"
        }
        Send Format("{Text}实际需收取 {1} 晚房费。退房请补入 {2} 晚房费。", daysActual, daysActual - pmsNts)
        utils.waitLoading()
        Send "!o"
        utils.waitLoading()
        Send "!c"
        utils.waitLoading()
        Send "!c"
        utils.waitLoading()
    }


    static crsNumEntry(tracking) {
        ImageSearch(&initX, &initY, 0, 0, A_ScreenWidth, A_ScreenWidth, IMAGES["opera-active-win.png"])

        MouseMove initX + 543, initY + 321
        utils.waitLoading()
        Click
        utils.waitLoading()

        ; check if record exists
        Send "!e"
        utils.waitLoading()

        ImageSearch(&popX, &popY, 0, 0, A_ScreenWidth, A_ScreenWidth, IMAGES["opera-active-win.png"])
        if (PixelGetColor(popX + 64, popY + 55) == "0xD7D7D7") {
            Send "{Tab}"
            utils.waitLoading()
            Send "^c"
            utils.waitLoading()
            if (!A_Clipboard.includes(tracking)) {
                loop 10 {
                    Send "^{Left}"
                }
                Send "{Text}" . tracking . "/"
                utils.waitLoading()
            }
        } else {
            Send "!n"
            utils.waitLoading()
            Send "{Tab}"
            utils.waitLoading()
            Send "{Text}MIGRATION"
            utils.waitLoading()
            Send "{Tab}"
            utils.waitLoading()
            Send "{Text}" . tracking
            utils.waitLoading()
        }

        Send "!o"
        utils.waitLoading()

        Send "!c"
        utils.waitLoading()
    }
}
