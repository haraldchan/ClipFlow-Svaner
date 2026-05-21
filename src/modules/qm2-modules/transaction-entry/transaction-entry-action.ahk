/**
 * @typedef {Object} Transaction
 * @property {"VS" | "MC" | "AE" | "JC" | "UP"} cardType
 * @property {String} cardNum
 * @property {String} exp
 * @property {String} amount
 * @property {String} transType
 * @property {String} auth
 */

class TransactionEntry_Action {
    static isRunning := false
    static isSelected := "0xC5E5FF"

    static start() {
        WinMaximize("ahk_class SunAwtFrame")
        WinActivate("ahk_class SunAwtFrame")
        WinSetAlwaysOnTop(true, "ahk_class SunAwtFrame")
        BlockInput(true)
        CoordMode("Mouse", "Screen")
        CoordMode("Pixel", "Screen")

        Hotkey("F12", (*) => this.end(), "On")
        this.isRunning := true

        SUSPEND_CONTROLLER.suspendOtherScripts()
    }

    static end() {
        BlockInput(false)
        WinSetAlwaysOnTop(false, "ahk_class SunAwtFrame")
        CoordMode("Mouse", "Screen")
        CoordMode("Pixel", "Screen")

        Hotkey("F12", (*) => {}, "Off")
        this.isRunning := false

        SUSPEND_CONTROLLER.restoreAllScripts()
    }

    static Transaction := Struct({
        cardType: ["VS", "MC", "AE", "JC", "UP"],
        cardNum: num => IsNumber(num),
        exp: exp => StrLen(exp) == 4,
        amount: amount => IsFloat(amount),
        transType: ["预授权", "消费", "预授权"],
        auth: auth => StrLen(auth) == 6,
        room: room => IsNumber(room) && StrLen(room) == 4
    })

    static copyFromSPayPos() {
        if (!RegExMatch(A_Clipboard, "^;\d+=\d+\?$") || !WinExist("ahk_exe SPayPOS.exe")) {
            return
        }

        SUSPEND_CONTROLLER.suspendOtherScripts()

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

        CoordMode("Pixel", "Window")
        found := PixelSearch(&x, &y, 0, 0, 1300, 800, this.isSelected)
        if (!found) {
            MsgBox("未选中交易。", , "icon! T2")
            return
        }
        CoordMode("Pixel", "Screen")

        ; copy room num
        MouseMove(547, 191)
        Sleep(50)
        Click(2)
        Sleep(10)
        Send("^c")
        Sleep(10)
        room := StrLen(A_Clipboard) == 3 ? "0" . A_Clipboard : A_Clipboard

        ; copy auth num
        MouseMove(x + 232, y + 30)
        Sleep(50)
        Click(2)
        Sleep(10)
        Send("^c")
        Sleep(10)
        auth := A_Clipboard

        ; copy amount
        MouseMove(x + 704, y + 27)
        Sleep(50)
        Click(3)
        Sleep(10)
        Send("^c")
        Sleep(10)
        amount := A_Clipboard

        ; copy transaction type
        MouseMove(x + 861, y + 26)
        Sleep(50)
        Click(3)
        Sleep(10)
        Send("^c")
        Sleep(10)
        transType := A_Clipboard

        ; copy card type
        MouseMove(x + 1015, y + 31)
        Sleep(50)
        Click(3)
        Sleep(10)
        Send("^c")
        Sleep(10)

        cardType := match(A_Clipboard, Map(
            card => card.includes("VISA"), "VS",
            card => card.includes("MASTER"), "MC",
            card => card.includes("AMEX"), "AE",
            card => card.includes("JCB"), "JC",
        ), "UP")

        ; get full card num
        if (!cardNum.startsWith("1") && !cardNum.startsWith("2")) {
            MouseMove(368, 115)
            Sleep(100)
            Click()
            Sleep(100)
            Send("123456")
            Sleep(100)
            Send("{Enter}")
            Sleep(500)
            MouseMove(368, 479)
            Click()
            Sleep(200)
            MouseMove(544, 707)
            Click(2)
            Sleep(10)
            Send("^c")
            Sleep(10)
            cardNum := A_Clipboard
            Send("{Esc}")
        }

        ; reset window
        BlockInput(false)
        WinRestore("ahk_exe SPayPOS.exe")
        WinMove(prevX, prevY, prevW, prevH, "ahk_exe SPayPOS.exe")
        CoordMode("Mouse", "Screen")

        SUSPEND_CONTROLLER.restoreAllScripts()

        capturedTransaction := {
            cardType: cardType,
            cardNum: cardNum,
            exp: exp,
            amount: amount.replace("`t", ""),
            transType: transType.replace("`t", ""),
            auth: auth,
            room: room
        }

        if (!capturedTransaction.satisfies(this.Transaction)) {
            MsgBox("复制信息有误，请重试！", "Transaction Entry", "4096 T2 icon!")
            return
        }

        this.promptCompleteInfo(capturedTransaction)
    }

    /**
     * @param {Transaction} transactionInfo 
     */
    static promptCompleteInfo(transactionInfo) {
        if (WinExist("Transaction Entry")) {
            WinClose("Transaction Entry")
        }

        Prompt := Svaner({
            gui: {
                options: "+AlwaysOnTop",
                title: "Transaction Entry"
            },
            font: { name: "微软雅黑" },
            events: {
                close: (thisGui) => thisGui.Destroy()
            }
        })

        onMount() {
            Prompt.Show()
            WinGetPos(&x, &y, &w, &h, "Transaction Entry")
            MouseMove(x + w, y + h)
        }

        return (
            TransactionEntry(Prompt, { transactionInfo: transactionInfo }).render(),
            onMount()
        )
    }

    /**
     * @param {Deposit} transactionInfo 
     */
    static entry(transactionInfo) {
        if (transactionInfo.transType == "预授权") {
            this.entryDeposit(transactionInfo)
        }
        else {
            this.entryPayment(transactionInfo)
        }
    }

    static entryDeposit(transactionInfo) {
        this.start()

        if (!WinExist("ahk_class SunAwtFrame")) {
            return
        }
        WinActivate("ahk_class SunAwtFrame")

        if (transactionInfo is Map) {
            transactionInfo := JSON.parse(JSON.stringify(transactionInfo), , false)
        }

        ; dismiss alerts
        loop {
            ; if there is a alert box
            if (PixelGetColor(551, 421) != "0xFFFFFF") {
                break
            }

            Send("{Enter}")
            Sleep(250)
        }
        if (!this.isRunning) {
            msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
            return
        }

        found := PmsImageFinder.find("opera-active-win.PNG")
        if (!found) {
            utils.cleanReload(WIN_GROUP)
        }

        ; move to payment field
        MouseMove(found.outX + 447, found.outY + 257)
        Sleep(100)
        Click(3)
        Sleep(100)
        Send("{Text}" . transactionInfo.cardType)
        Sleep(100)
        Send("{Tab}")
        utils.waitLoading()
        Send("{Esc}") ; attach card to profile prompt, choose "No"
        utils.waitLoading()
        if (!this.isRunning) {
            msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
            return
        }

        ; dismiss pre-exist card select
        CoordMode("Pixel", "Screen")
        if (PixelGetColor(found.outX + 130, found.outY + 164) == "0x000080") {
            Send("!c")
            utils.waitLoading()
        }

        Send("{Esc}")
        utils.waitLoading()
        if (!this.isRunning) {
            msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
            return
        }

        ; enter cardNum & exp
        Send("{Text}" . transactionInfo.cardNum)
        Sleep(100)
        Send("{Tab}")
        utils.waitLoading()
        Send "{Esc}" ; attach card to profile prompt, choose "No"
        utils.waitLoading()
        Send("{Text}" . transactionInfo.exp)
        Sleep(100)
        Send("!s")
        utils.waitLoading()
        loop 3 {
            Send("{Esc}")
            utils.waitLoading(100)
        }

        ; enter deposit amount & auth
        Send("!t")
        utils.waitLoading()
        Send("!e")
        utils.waitLoading()
        Send("!a")
        utils.waitLoading()
        Send("!m")
        utils.waitLoading()
        Send("{Text}" . transactionInfo.amount)
        Sleep(100)
        Send("{Tab}")
        Sleep(100)
        Send("{Text}" . transactionInfo.auth)
        Sleep(100)
        Send("!o")
        utils.waitLoading()
        Send("!c")
        utils.waitLoading()

        this.end()
    }

    static entryPayment(transactionInfo) {
        this.start()

        mcBtn := PmsImageFinder.find("payment-mc.png")
        if (!mcBtn) {
            Send("!y")
            utils.waitLoading()
        }

        Send(Format("{Text}{1}", transactionInfo.cardType))
        Send("{Tab}")
        utils.waitLoading()

        ; dismiss exist credit card list
        if (!PmsImageFinder.find("payment-mc.png")) {
            Send("!c")
            utils.waitLoading()
        }

        Send("{Esc}") ; dismiss attach card msgbox
        utils.waitLoading()
        Send(transactionInfo.amount)
        Sleep(100)
        Send("{Tab}")
        Send(transactionInfo.cardNum)
        Sleep(100)
        Send("{Tab}")
        Send(transactionInfo.exp)
        Sleep(100)
        Send("!p")
        utils.waitLoading()

        this.end()
    }

    static USE(transactionInfo) {
        if (transactionInfo is Map) {
            transactionInfo := JSON.parse(JSON.stringify(transactionInfo), , false)
        }

        ; clear form
        Send("!r")
        utils.waitLoading()

        ; search room
        Send("{Text}" . transactionInfo.room)

        Sleep(100)
        Send("!h")
        utils.waitLoading()
        CoordMode("Pixel", "Screen")
        CoordMode("Mouse", "Screen")

        errorIconFound := PmsImageFinder.find("error.png")
        if (errorIconFound) {
            Send("{Enter}")
            utils.waitLoading()
            Send("{Enter}")
            utils.waitLoading()
            return Error("room not found")
        }

        ; get main-profile
        found := PmsImageFinder.find("opera-active-win.PNG")
        if (!found) {
            Send("{Enter}")
            utils.waitLoading()
            Send("{Enter}")
            utils.waitLoading()
            return Error("room not found")
        }

        Click(found.outX + 672, found.outY + 222, "Right")
        Sleep(100)
        Send("{Down}")
        Sleep(100)
        Send("{Enter}")
        utils.waitLoading()
        Send("!e")
        utils.waitLoading()
        this.entry(transactionInfo)
        utils.waitLoading()

        Send("!o")
        loop 3 {
            Send("{Esc}")
            utils.waitLoading(100)
        }
    }
}