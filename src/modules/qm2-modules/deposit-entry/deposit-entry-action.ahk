/**
 * @typedef {Object} Deposit
 * @property {"VS" | "MC" | "AE" | "JC" | "UP"} cardType
 * @property {String} cardNum
 * @property {String} exp
 * @property {String} amount
 * @property {String} auth
 */

class DepositEntry_Action {
    static isRunning := false

    static start() {
        WinMaximize("ahk_class SunAwtFrame")
        WinActivate("ahk_class SunAwtFrame")
        WinSetAlwaysOnTop(true, "ahk_class SunAwtFrame")
        BlockInput(true)
        CoordMode("Mouse", "Screen")
        CoordMode("Pixel", "Screen")

        Hotkey("F12", (*) => this.end(), "On")
        this.isRunning := true
    }

    static end() {
        BlockInput(false)
        WinSetAlwaysOnTop(false, "ahk_class SunAwtFrame")
        CoordMode("Mouse", "Screen")
        CoordMode("Pixel", "Screen")

        Hotkey("F12", (*) => {}, "Off")
        this.isRunning := false
    }

    /**
     * @param {String} cardInfo 
     * @returns {"VS" | "MC" | "AE" | "JC" | "UP"} 
     */
    static validateType(cardInfo) {
        switch {
            case cardInfo.includes("VISA"):
                return "VS"
            case cardInfo.includes("MASTER"):
                return "MC"
            case cardInfo.includes("AMEX"):
                return "AE"
            case cardInfo.includes("JCB"):
                return "JC"
            default:
                return "UP"
        }
    }

    static copyFromSPayPos() {
        if (!RegExMatch(A_Clipboard, "^;\d+=\d+\?$") || !WinExist("ahk_exe SPayPOS.exe")) {
            return
        }

        ; set window
        BlockInput(true)
        WinRestore("ahk_exe SPayPOS.exe")
        WinGetPos(&prevX, &prevY, &prevW, &prevH, "ahk_exe SPayPOS.exe")
        WinMove(0, 0, 1300, 800, "ahk_exe SPayPOS.exe")
        WinActivate("ahk_exe SPayPOS.exe")
        CoordMode("Mouse", "Window")

        cardInfoCopied := A_Clipboard
        parsedCard := cardInfoCopied.replaceThese([";", "?"]).split("=")
        cardNum := parsedCard[1]
        exp := parsedCard[2].substr(3, 4) . parsedCard[2].substr(1, 2)

        ; copy room num
        MouseMove 547, 191
        Sleep 50
        Click 2
        Sleep 10
        Send "^c"
        Sleep 10
        room := StrLen(A_Clipboard) == 3 ? "0" . A_Clipboard : A_Clipboard

        ; copy auth num
        MouseMove 465, 358
        Sleep 50
        Click 2
        Sleep 10
        Send "^c"
        Sleep 10
        auth := A_Clipboard

        ; copy amount
        MouseMove 950, 355
        Sleep 50
        Click 2
        Sleep 10
        Send "^c"
        Sleep 10
        amount := A_Clipboard

        ; copy card type
        MouseMove 1245, 345
        Sleep 50
        Click 3
        Sleep 10
        Send "^c"
        Sleep 10
        cardType := this.validateType(A_Clipboard)

        ; get full card num
        if (!cardNum.startsWith("1") && !cardNum.startsWith("2")) {
            MouseMove 368, 115
            Sleep 100
            Click
            Sleep 100
            Send "123456"
            Sleep 100
            Send "{Enter}"
            Sleep 500
            MouseMove 368, 479
            Click
            Sleep 200
            MouseMove 544, 707
            Click 2
            Sleep 10
            Send "^c"
            Sleep 10
            cardNum := A_Clipboard
            Send "{Esc}"
        }

        ; reset window
        BlockInput false
        WinRestore("ahk_exe SPayPOS.exe")
        WinMove(prevX, prevY, prevW, prevH, "ahk_exe SPayPOS.exe")
        CoordMode("Mouse", "Screen")

        this.promptCompleteInfo({
            cardType: cardType,
            cardNum: cardNum,
            exp: exp,
            amount: amount,
            auth: auth,
            room: room
        })
    }

    /**
     * @param {Deposit} depositInfo 
     */
    static promptCompleteInfo(depositInfo) {
        if (WinExist("Deposit Entry")) {
            WinClose("Deposit Entry")
        }

        Prompt := Svaner({
            gui: {
                options: "+AlwaysOnTop",
                title: "Deposit Entry"
            },
            font: { name: "微软雅黑" },
            events: {
                close: (thisGui) => thisGui.Destroy()
            }
        })

        return (
            DepositEntry(Prompt, { depositInfo: depositInfo }).render(),
            Prompt.Show()
        )
    }

    /**
     * @param {Deposit} depositInfo 
     */
    static entry(depositInfo) {
        this.start()

        if (!WinExist("ahk_class SunAwtFrame")) {
            return
        }
        WinActivate("ahk_class SunAwtFrame")

        if (depositInfo is Map) {
            depositInfo := JSON.parse(JSON.stringify(depositInfo), , false)
        }

        ; dismiss alerts
        loop {
            ; if there is a alert box
            if (PixelGetColor(551, 421) != "0xFFFFFF") {
                break
            }

            Send "{Enter}"
            Sleep 250
        }
        if (!this.isRunning) {
            msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
            return
        }

        ; loop {
        ;     if (ImageSearch(&outX, &outY, 0, 0, A_ScreenWidth, A_ScreenHeight, IMAGES["opera-active-win.PNG"])) {
        ;         break
        ;     }
        ;     Sleep 200
        ; } until (A_Index > 5)
        found := PmsImageFinder.find("opera-active-win.PNG")
        if (found is Error) {
            utils.cleanReload(WIN_GROUP)
        }

        ; move to payment field
        MouseMove found.outX + 447, found.outY + 257
        Sleep 100
        Click 3
        Sleep 100
        Send "{Text}" . depositInfo.cardType
        Sleep 100
        Send "{Tab}"
        utils.waitLoading()
        if (!this.isRunning) {
            msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
            return
        }

        ; dismiss pre-exist card select
        CoordMode("Pixel", "Screen")
        if (PixelGetColor(found.outX + 130, found.outY + 164) == "0x000080") {
            Send "!c"
            utils.waitLoading()
        }

        ; attach card to profile prompt, choose "No"
        ; loop {
        ;     if (ImageSearch(&_, &_, 0, 0, A_ScreenWidth, A_ScreenHeight, IMAGES["alert.PNG"])) {
        ;         break
        ;     }

        ;     Sleep 200
        ; } until (A_Index > 5)
        found := PmsImageFinder.find("alert.png")
        if (found is Error) {
            utils.cleanReload(WIN_GROUP)
        }

        Send "{Esc}"
        utils.waitLoading()
        if (!this.isRunning) {
            msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
            return
        }

        ; enter cardNum & exp
        Send Format("{Text}{1}`n{2}", depositInfo.cardNum, depositInfo.exp)
        Sleep 100
        Send "!s"
        utils.waitLoading()
        loop 3 {
            Send "{Esc}"
            utils.waitLoading(100)
        }

        ; enter deposit amount & auth
        Send "!t"
        utils.waitLoading()
        Send "!e"
        Send "!a"
        Send "!m"
        utils.waitLoading()
        Send Format("{Text}{1}`n{2}", depositInfo.amount, depositInfo.auth)
        Sleep 200
        Send "!o"
        utils.waitLoading()
        Send "!c"
        utils.waitLoading()

        this.end()
    }

    static USE(depositInfo) {
        if (depositInfo is Map) {
            depositInfo := JSON.parse(JSON.stringify(depositInfo), , false)
        }

        ; clear form
        Send "!r"
        utils.waitLoading()

        ; search room
        Send "{Text}" . depositInfo.room

        Sleep 100
        Send "!h"
        utils.waitLoading()
        CoordMode "Pixel", "Screen"
        CoordMode "Mouse", "Screen"
        ; if (ImageSearch(&outX, &outY, 0, 0, A_ScreenWidth, A_ScreenHeight, IMAGES["error.PNG"])) {
        ;     Send "{Enter}"
        ;     utils.waitLoading()
        ;     Send "{Enter}"
        ;     utils.waitLoading()
        ;     return Error("room not found")
        ; }
        errorIconFound := PmsImageFinder.find("error.png")
        if !(errorIconFound is Error) {
            Send "{Enter}"
            utils.waitLoading()
            Send "{Enter}"
            utils.waitLoading()
            return Error("room not found") 
        }

        ; get main-profile
        ; ImageSearch(&outX, &outY, 0, 0, A_ScreenWidth, A_ScreenHeight, IMAGES["opera-active-win.PNG"])
        ; if (!outX || !outY) {
        ;     Send "{Enter}"
        ;     utils.waitLoading()
        ;     Send "{Enter}"
        ;     utils.waitLoading()
        ;     return Error("room not found")
        ; }
        found := PmsImageFinder.find("opera-active-win.PNG")
        if (found is Error) {
            Send "{Enter}"
            utils.waitLoading()
            Send "{Enter}"
            utils.waitLoading()
            return Error("room not found")
        }

        Click found.outX + 672, found.outY + 222, "Right"
        Sleep 100
        Send "{Down}"
        Sleep 100
        Send "{Enter}"
        utils.waitLoading()
        Send "!e"
        utils.waitLoading()
        this.entry(depositInfo)
        utils.waitLoading()

        Send "!o"
        loop 3 {
            Send "{Esc}"
            utils.waitLoading(100)
        }
    }
}
