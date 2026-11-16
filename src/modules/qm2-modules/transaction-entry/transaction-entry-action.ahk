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
    static OPERA := "ahk_class SunAwtFrame"
    static SPAY := "ahk_exe SPayPOS.exe"

    static Transaction := Struct({
        cardType: ["VS", "MC", "AE", "JC", "UP"],
        cardNum: num => IsNumber(num),
        exp: exp => StrLen(exp) == 4,
        amount: amount => IsFloat(amount),
        transType: ["预授权", "消费", "预授权完成", "预授权（已撤销）", "预授权撤销", "预授权（已完成）"],
        auth: auth => StrLen(auth) == 6,
        room: room => IsNumber(room) && StrLen(room) == 4
    })

    static start() {
        WinMaximize(this.OPERA)
        WinActivate(this.OPERA)
        WinSetAlwaysOnTop(true, this.OPERA)
        BlockInput(true)
        CoordMode("Mouse", "Screen")
        CoordMode("Pixel", "Screen")

        Hotkey("F12", (*) => this.end(), "On")
        this.isRunning := true

        SUSPEND_CONTROLLER.suspendOtherScripts()
    }

    static end() {
        BlockInput(false)
        WinSetAlwaysOnTop(false, this.OPERA)
        CoordMode("Mouse", "Screen")
        CoordMode("Pixel", "Screen")

        Hotkey("F12", (*) => {}, "Off")
        this.isRunning := false

        SUSPEND_CONTROLLER.restoreAllScripts()
    }

    static startCopy() {
        BlockInput(true)
        SUSPEND_CONTROLLER.suspendOtherScripts()
    }

    static endCopy() {
        BlockInput(false)
        SUSPEND_CONTROLLER.restoreAllScripts()
    }

    static copyFromSPayPos() {
        if (!RegExMatch(A_Clipboard, "^;\d+=\d+\?$") || !WinExist(this.SPAY)) {
            return
        }

        this.startCopy()

        maskedCardNum := A_Clipboard.split("=")[1].replace(";")
        
        isCard := !maskedCardNum.startsWith("1") && !maskedCardNum.startsWith("2")
        if (isCard) {
            CoordMode("Pixel", "Screen")
            loop {
                if (ImageSearch(&outX, &outY, 0, 0, A_ScreenWidth, A_ScreenHeight, IMAGES["spay-card-detail.png"])) {
                    break
                }
                Sleep(200)
                if (A_Index > 20) {
                    return
                }
            }

            Click(outX + 5, outY + 5)
            Sleep(500)
            Send("{Text}123456")
            Sleep(100)
            Send("{Enter}")
            Sleep(1000)
            loop 3 {
                Send("{Tab}")
                Sleep(100)
            }
            Send("{Enter}")
            Sleep(100)

        }

        Send("^a")
        Sleep(100)
        Send("^c")
        Sleep(100)

        rawInfo := A_Clipboard.split("`r`n")

        room := pipe(
            r => r.findIndex(line => line.includes("房号")),
            i => rawInfo[i + 1],
            n => StrLen(n) == 3 ? "0" . n : n
        )(rawInfo)

        start := rawInfo.findIndex(line => line.includes("交易检索号"))
        rawInfo.RemoveAt(1, start)
        transactions := []
        for (line in rawInfo) {
            splittedLine := line.split("`t")
            
            if (IsNumber(splittedLine[1])) {
                ; only show matched card transactions
                isMatchedCardNum := splittedLine[3].substr(1, 6) == maskedCardNum.substr(1, 6) && splittedLine[3].substr(-4) == maskedCardNum.substr(-4)
                if (!isMatchedCardNum) {
                    continue
                }
                ; skip voided transactions
                transType := splittedLine[6]
                if (transType.includes("已撤销")) {
                    continue
                }

                auth := splittedLine[2]

                cardNum := isCard ? rawInfo.at(-4) : maskedCardNum

                exp := splittedLine[4].substr(3, 4) . splittedLine[4].substr(1, 2)

                amount := splittedLine[5]

                cardType := match(splittedLine[7], Map(
                        card => card.includes("VISA"), "VS",
                        card => card.includes("MASTER"), "MC",
                        card => card.includes("AMEX"), "AE",
                        card => card.includes("JCB"), "JC",
                    ), "UP")

                time := splittedLine[8]

                transactions.Push({
                    room: room,
                    auth: auth,
                    cardNum: cardNum,
                    exp: exp,
                    amount: amount,
                    transType: transType,
                    cardType: cardType,
                    time: time
                })
            }
            else {
                break
            }
        }

        this.endCopy()
        this.promptCompleteInfo(transactions)
    }

    /**
     * @param {Transaction} transactionInfo 
     */
    static promptCompleteInfo(transactions) {
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
                close: (thisGui) => thisGui.Destroy(),
                escape: (thisGui) => thisGui.Destroy()
            }
        })

        onMount() {
            Prompt.Show()
            WinGetPos(&x, &y, &w, &h, "Transaction Entry")
            MouseMove(x + w, y + h)
        }

        return (
            transactions.map((info, index) => TransactionEntry(Prompt, { transactionInfo: info, index: index }).render()),
            onMount()
        )
    }

    /**
     * @param {Transaction} transactionInfo 
     */
    static entry(transactionInfo) {
        if (transactionInfo.transType == "消费" || transactionInfo.transType == "预授权完成") {
            this.entryPayment(transactionInfo)
        }
        else {
            this.entryDeposit(transactionInfo)
        }
    }

    /**
     * @param {Transaction} transactionInfo 
     */
    static entryDeposit(transactionInfo) {
        this.start()

        if (!WinExist(this.OPERA)) {
            return
        }
        WinActivate(this.OPERA)

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

    /**
     * @param {Transaction} transactionInfo 
     */
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
