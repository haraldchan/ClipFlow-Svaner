/**
 * @typedef {Object} Deposit
 * @property {"VS" | "MC" | "AE" | "JC" | "UP"} cardType
 * @property {String} cardNum
 * @property {String} exp
 * @property {String} amount
 * @property {String} auth
 */

class DepositEntry {
    static isRunning := false

    static start() {
        WinMaximize "ahk_class SunAwtFrame"
        WinActivate "ahk_class SunAwtFrame"
        WinSetAlwaysOnTop true, "ahk_class SunAwtFrame"
        BlockInput true

        Hotkey("F12", (*) => this.end(), "On")
        this.isRunning := true
    }

    static end() {
        BlockInput false
        WinSetAlwaysOnTop false, "ahk_class SunAwtFrame"

        Hotkey("F12", (*) => {}, "Off")
        this.isRunning := false
    }

    static regex := {
        visa: "^4\d{12}(\d{3})?$",
        master: "^(5[1-5]\d{14}|2(2[2-9]\d{12}|[3-6]\d{13}|7[01]\d{12}|720\d{12}))$",
        amex: "^3[47]\d{13}$",
        jcb: "^35(2[89]|[3-8]\d)\d{12}$"
    }

    /**
     * @param {String} cardInfo 
     * @returns {"VS" | "MC" | "AE" | "JC" | "UP"} 
     */
    static validateType(cardInfo) {
        switch {
            ; Visa
            case RegExMatch(cardInfo, this.regex.visa):
                return "VS"
                ; MasterCard
            case RegExMatch(cardInfo, this.regex.master):
                return "MC"
                ; Amex
            case RegExMatch(cardInfo, this.regex.amex):
                return "AE"
                ; JCB
            case RegExMatch(cardInfo, this.regex.jcb):
                return "JC"
                ; Union Pay
            default:
                return "UP"
        }
    }

    /**
     * @param {Gui.CheckBox} controlCheckBox 
     */
    static copyFromMipay(controlCheckBox) {
        if (controlCheckBox.Value == false || !RegExMatch(A_Clipboard, "^;\d+=\d+\?$")) {
            return
        }
        cardInfoCopied := A_Clipboard
        ; dismiss success popup
        if (WinActive("ahk_exe oHotel.exe")) {
            BlockInput true
            Send "{Enter}"
            Sleep 200

            CoordMode "Mouse", "Client"
            MouseMove 231, 78
            Sleep 100
            Click 3
            Sleep 100
            Send "^c"
            Sleep 100
            CoordMode "Mouse", "Screen"
            BlockInput false

            room := StrLen(A_Clipboard) == 3 ? "0" . A_Clipboard : A_Clipboard
        }

        parsedCard := cardInfoCopied.replaceThese([";", "?"]).split("=")

        cardType := this.validateType(parsedCard[1])
        cardNum := parsedCard[1]
        exp := parsedCard[2].substr(3, 4) . parsedCard[2].substr(1, 2)
        auth := cardType == "UP" && (cardNum.startsWith(1) || cardNum.startsWith(2)) ? cardNum.substr(1, 1) . cardNum.substr(-5) : ""

        if (cardType != "UP" && InStr(cardNum, "000000",, 7)) {
            MsgBox("外卡卡号不完整，请手动录入。", "Deposit Entry", "4096 T2")
            return
        }

        depositInfo := {
            cardType: cardType,
            cardNum: cardNum,
            exp: exp,
            amount: "",
            auth: auth,
            room: IsSet(room) ? room : ""
        }

        this.promptCompleteInfo(depositInfo)
    }

    /**
     * @param {Deposit} depositInfo 
     */
    static promptCompleteInfo(depositInfo) {
        if (WinExist("Deposit Entry")) {
            WinClose("Deposit Entry")
        }

        Prompt := Gui("+AlwaysOnTop", "Deposit Entry")
        Prompt.SetFont(, "微软雅黑")
        Prompt.OnEvent("Close", destroyPrompt)

        destroyPrompt(*) {
            ; restore card info
            A_Clipboard := Format("{1}`t{2}", depositInfo.cardNum, depositInfo.exp)
            Prompt.Destroy()
        }

        completeInfo(*) {
            depositInfo.cardType := Prompt.getCtrlByTypeAll("Radio")
                .find(radio => radio.Value == true)
                .Text
                .replace("&", "")
            depositInfo.cardNum := Prompt["card-num"].Value
            depositInfo.exp := Prompt["exp"].Value
            depositInfo.amount := Prompt["amount"].Value
            depositInfo.auth := Prompt["auth"].Value
            depositInfo.room := Prompt["room"].Value

            SetTimer(() => destroyPrompt(), -100)

            if (Prompt["de-delegate"].Value == true) {
                sendQmPost(depositInfo)
            } else {
                this.entry(depositInfo)
            }
        }

        isDelegate := signal(false)
        delegateDepositEntry(ctrl, _) {
            isDelegate.set(ctrl.Value)

            Prompt["room"].Enabled := isDelegate.value
            Prompt["room"].Focus()
        }

        sendQmPost(depositInfo) {
            agent := useServerAgent({ pool: "\\10.0.2.13\fd\19-个人文件夹\HC\Software - 软件及脚本\AHK_Scripts\ClipFlow\src\Servers\qm-pool" })
            agent.POST({
                module: "DepositEntry",
                form: depositInfo
            })
        }

        onMount() {
            Prompt.Show()

            Prompt[depositInfo.cardType].Value := true
            Prompt["amount"].Focus()

            isDelegate.set(Prompt["de-delegate"].Value)
        }

        return (
            Prompt.AddGroupBox("Section w330 h150", "押金信息").SetFont("bold"),
            ; card type
            Prompt.AddText("xs10 yp+23 w80 h25 0x200", "支付类型"),
            Prompt.AddRadio("x+1 w45 h25", "&UP"),
            Prompt.AddRadio("x+1 w45 h25", "&VS"),
            Prompt.AddRadio("x+1 w45 h25", "&MC"),
            Prompt.AddRadio("x+1 w45 h25", "&AE"),
            Prompt.AddRadio("x+1 w45 h25", "&JC"),
            ; card info
            Prompt.AddText("xs10 yp+30 w80 h25 0x200", "卡号信息"),
            Prompt.AddEdit("vcard-num x+1 w150 h25 0x200", depositInfo.cardNum),
            Prompt.AddEdit("vexp x+1 w70 h25", depositInfo.exp),
            ; amount auth
            Prompt.AddText("xs10 yp+30 w80 h25 0x200", "金额/授权号"),
            Prompt.AddEdit("vamount x+1 w150 h25", ""),
            Prompt.AddEdit("vauth x+1 w70 h25", depositInfo.auth),
            ; server delegate
            Prompt.AddCheckbox("vde-delegate Checked xs10 yp+30 w80 h25", "后台代行").onEvent("Click", delegateDepositEntry),
            Prompt.AddEdit("vroom x+1 w150 h25", (depositInfo.room || "(房间号)")),
            ; btns
            Prompt.AddButton("x175 w80 h25", "取消 (&C)").OnEvent("Click", destroyPrompt),
            Prompt.AddButton("x+5 w80 h25 Default", "确定 (&O)").OnEvent("Click", completeInfo),
            onMount()
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

        loop {
            if (ImageSearch(&outX, &outY, 0, 0, A_ScreenWidth, A_ScreenHeight, IMAGES["opera-active-win.PNG"])) {
                break
            }
            Sleep 200
        } until (A_Index > 5)

        ; move to payment field
        MouseMove outX + 447, outY + 257
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
        if (PixelGetColor(outX + 130, outY + 164) == "0x000080") {
            Send "!c"
            utils.waitLoading()
        }

        ; attach card to profile prompt, choose "No"
        loop {
            if (ImageSearch(&_, &_, 0, 0, A_ScreenWidth, A_ScreenHeight, IMAGES["alert.PNG"])) {
                break
            }

            Sleep 200
        } until (A_Index > 5)
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
            depositInfo := JSON.parse(JSON.stringify(depositInfo),, false)
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
        if (ImageSearch(&outX, &outY, 0, 0, A_ScreenWidth, A_ScreenHeight, IMAGES["info.PNG"])) {
            Send "{Enter}"
            return
        }

        ; get main-profile
        ImageSearch(&outX, &outY, 0, 0, A_ScreenWidth, A_ScreenHeight, IMAGES["opera-active-win.PNG"])
        Click outX + 672, outY + 222, "Right"
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