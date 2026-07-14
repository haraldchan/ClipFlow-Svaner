class PMN_FillPSB {
    static dict := useDict()
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

        WinActivate("ahk_exe 360se.exe")
        BlockInput(c.blockInput)

        SUSPEND_CONTROLLER.suspendOtherScripts()
    }

    static end() {
        this.isRunning := false
        Hotkey("F12", "Off")

        WinSetAlwaysOnTop(false, "ahk_exe 360se.exe")
        BlockInput(false)

        SUSPEND_CONTROLLER.restoreAllScripts()
    }

    /**
     * @param {"内地旅客" | "港澳台旅客" | "国外旅客"} guestProfile
     */
    static anchorField(guestType) {
        yOffset := Map(
            "内地旅客", -346,
            "港澳台旅客", -287,
            "国外旅客", -276
        )

        CoordMode("Pixel", "Screen")
        CoordMode("Mouse", "Screen")
        if (ImageSearch(&x, &y, 0, 0, A_ScreenWidth, A_ScreenHeight, IMAGES["psb-photo-icon.png"])) {
            Click(x, y + yOffset[guestType])
        }
        else {
            MsgBox("旅业系统界面定位失败，请重试。", POPUP_TITLE, "4096 T2 icon!")
            return
        }
    }

    /**
     * @param {Map} guestProfile
     */
    static fill(guestProfile) {
        Sleep(200)
        this.start()

        this.anchorField(guestProfile["guestType"])

        switch guestProfile["guestType"] {
            case "内地旅客":
                this.fillMainlandTraveler(guestProfile)
            case "港澳台旅客":
                this.fillHkMoTwTraveler(guestProfile)
            case "国外旅客":
                this.fillForeignTraveler(guestProfile)
        }

        this.end()
    }

    static fillMainlandTraveler(guestProfile) {
        ; name
        Send("{Text}" . guestProfile["name"].replace("👤", ""))
        Sleep(100)
        Send("{Tab}")
        Sleep(100)

        ; gender
        Send(guestProfile["gender"])
        Sleep(100)
        Send("{Down}")
        Sleep(100)
        Send("{Enter}")
        Sleep(100)
        Send("{Tab}")
        Sleep(100)

        ; ethnic
        Sleep(100)
        Send("{Down}")
        Sleep(100)
        Send("{Enter}")
        Sleep(100)
        Send("{Tab}")
        Sleep(100)

        ; birthday
        Send(guestProfile["birthday"])
        Sleep(100)
        Send("{Tab}")
        Sleep(100)

        ; address
        Send("{Text}" . guestProfile["addr"])
        Sleep(200)
        Send("{Tab}")
        Sleep(200)
        Send("{Down}")
        Sleep(200)
        Send("{Tab}")
        Sleep(200)
        Send("{Tab}")
        Sleep(200)

        ; idType
        Send(guestProfile["idType"])
        Sleep(100)
        Send("{Down}")
        Sleep(100)
        Send("{Enter}")
        Sleep(100)
        Send("{Tab}")
        Sleep(100)

        ; idNum
        Send("{Text}" . guestProfile["idNum"])
        Sleep(100)
        Send("{Tab}")
        Sleep(100)

        ; roomNum
        Send("{Text}" . guestProfile["roomNum"])
        Sleep(100)
        Send("{Tab}")
        Sleep(100)

        ; tel
        Send("{Text}" . guestProfile["tel"])
        Sleep(100)
        Send("{Tab}")
        Sleep(100)
    }

    static fillHkMoTwTraveler(guestProfile) {
        isTaiwanese := guestProfile["guestType"] == "港澳台旅客" && guestProfile["region"] == "台湾"
        if (isTaiwanese) {
            unpack(this.dict.getFullnamePinyin(guestProfile["name"]), [&nameLast, &nameFirst])
        }
        else {
            unpack(this.dict.getFullnamePinyinCantonese(guestProfile["name"]), [&nameLast, &nameFirst])
        }

        ; name
        Send("{Text}" . guestProfile["name"].replace("👤", ""))
        Sleep(100)
        Send("{Tab}")
        Sleep(100)

        ; gender
        Send(guestProfile["gender"])
        Sleep(100)
        Send("{Down}")
        Sleep(100)
        Send("{Enter}")
        Sleep(100)
        Send("{Tab}")
        Sleep(100)

        ; birthday
        Send(guestProfile["birthday"])
        Sleep(100)
        Send("{Tab}")
        Sleep(100)

        ; roomNum
        Send("{Text}" . guestProfile["roomNum"])
        Sleep(100)
        Send("{Tab}")
        Sleep(100)

        ; eng lastname
        Send("{Text}" . nameLast)
        Sleep(100)
        Send("{Tab}")
        Sleep(100)

        ; eng firstname
        Send("{Text}" . nameFirst)
        Sleep(100)
        Send("{Tab}")
        Sleep(100)

        ; idType
        Send(guestProfile["idType"])
        Sleep(100)
        Send("{Down}")
        Sleep(100)
        Send("{Enter}")
        Sleep(100)
        Send("{Tab}")
        Sleep(100)

        ; idNum
        Send("{Text}" . guestProfile["idNum"])
        Sleep(100)
        Send("{Tab}")
        Sleep(100)

        ; region
        Send(guestProfile["region"])
        Sleep(100)
        Send("{Down}")
        Sleep(100)
        Send("{Enter}")
        Sleep(100)
        Send("{Tab}")
        Sleep(100)

        ; tel
        Send("{Text}" . guestProfile["tel"])
        Sleep(100)
        Send("{Tab}")
        Sleep(100)
    }

    static fillForeignTraveler(guestProfile) {
        ; skip cn name
        Send("{Tab}")
        Sleep(100)

        ; gender
        Send(guestProfile["gender"])
        Sleep(100)
        Send("{Down}")
        Sleep(100)
        Send("{Enter}")
        Sleep(100)
        Send("{Tab}")
        Sleep(100)

        ; birthday
        Send(guestProfile["birthday"])
        Sleep(100)
        Send("{Tab}")
        Sleep(100)

        ; roomNum
        Send("{Text}" . guestProfile["roomNum"])
        Sleep(100)
        Send("{Tab}")
        Sleep(100)

        ; lastname
        Send("{Text}" . guestProfile["nameLast"])
        Sleep(100)
        Send("{Tab}")
        Sleep(100)

        ; firstname
        Send("{Text}" . guestProfile["nameFirst"])
        Sleep(100)
        Send("{Tab}")
        Sleep(100)

        ; idType
        Send(guestProfile["idType"])
        Sleep(100)
        Send("{Down}")
        Sleep(100)
        Send("{Enter}")
        Sleep(100)
        Send("{Tab}")
        Sleep(100)

        ; idNum
        Send("{Text}" . guestProfile["idNum"])
        Sleep(100)
        Send("{Tab}")
        Sleep(100)

        ; country
        Send(guestProfile["country"])
        Sleep(100)
        if (guestProfile["country"] == "美国") {
            Send("{Down}")
            Sleep(100)
        }
        Send("{Down}")
        Sleep(100)
        Send("{Enter}")
        Sleep(100)
        Send("{Tab}")
        Sleep(100)

        ; tel
        Send("{Text}" . guestProfile["tel"])
        Sleep(100)
        Send("{Tab}")
        Sleep(100)
    }
}
