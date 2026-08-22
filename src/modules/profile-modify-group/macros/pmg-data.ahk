class PMG_Data {
    static saveFileName := ""

    static reportFiling(blockcode, initX := 433, initY := 598) {
        WinSetAlwaysOnTop(true, "ahk_class SunAwtFrame")
        BlockInput(true)
        WinMaximize("ahk_class SunAwtFrame")
        WinActivate("ahk_class SunAwtFrame")

        if (utils.checkClearWin(POPUP_TITLE, IMAGES["opera-logo.png"]) = "Cancel"){
            utils.cleanReload(WIN_GROUP)
        }

        utils.waitLoading()
        Send("!m")
        utils.waitLoading()
        Send("{Text}R")
        utils.waitLoading()
        Send(Format("{Text}{1}", "grpinhousebyroom"))
        utils.waitLoading()
        Send("!h")
        utils.waitLoading()
        MouseMove(initX, initY) ; 433, 598
        utils.waitLoading()
        Click()
        utils.waitLoading()

        MouseMove(initX + 380, initY)
        Click()
        loop 2 {
            Send("{Down}")
            utils.waitLoading()
        }
        utils.waitLoading()
        Send("{Enter}")
        utils.waitLoading()
        Send("!o")

        ; run saving actions, return filename
        this.saveGroupInhouse(blockcode)
        this.saveFileName := blockcode . ".XML"

        utils.waitLoading()
        Send("!f")
        utils.waitLoading()
        Send("{Backspace}")
        utils.waitLoading()
        Send(Format("{Text}{1}", this.saveFileName))
        Sleep(1500)
        Send("{Enter}")
        TrayTip(Format("正在保存：{1}", this.saveFileName))

        isWindows7 := StrSplit(A_OSVersion, ".")[1] = 6
        
        if (WinWait("Warning",, 20)) {
            WinSetAlwaysOnTop(false, "ahk_class SunAwtFrame")
            WinSetAlwaysOnTop(true, "Warning")
        }
        
        loop 30 {
            sleep(1000)

            if (!isWindows7 && WinExist("Warning")) {

                utils.waitLoading()
                Send("{Enter}")
                utils.waitLoading()
                WinSetAlwaysOnTop(true, "ahk_class SunAwtFrame")
            }

            if (FileExist(A_MyDocuments . "\" . this.saveFileName)) {
                break
            }

            if (A_Index = 30) {
                MsgBox("保存出错，脚本已终止。", "ReportMaster", "T1 4096")
                utils.cleanReload(WIN_GROUP)
            }
        }

        utils.waitLoading()
        WinSetAlwaysOnTop(true, "ahk_class SunAwtFrame")
        Send("!c")
        BlockInput(false)
        WinSetAlwaysOnTop(false, "ahk_class SunAwtFrame")
    }

    static saveGroupInhouse(blockcode) {
        MouseMove(737, 395)
        utils.waitLoading()
        Click()
        utils.waitLoading()
        Send(Format("{Text}{1}", blockcode))
        utils.waitLoading()
        Send("!h")
        utils.waitLoading()
        loop 2 {
            Send("{Tab}")
            utils.waitLoading()
        }
        Send("{Space}")
        utils.waitLoading()
        Send("!o")
        utils.waitLoading()
    }

    /**
     * 
     * @param {String} xmlPath fullpath of GroupInHouse report xml
     * @returns {Array} list of group room numbers
     */
    static getGroupRoomNumbers(xmlPath) {
        xmlDoc := ComObject("msxml2.DOMDocument.6.0")
        xmlDoc.async := false
        xmlDoc.load(xmlPath)
        roomElements := xmlDoc.getElementsByTagName("ROOM")
        
        inhRooms := []
        loop roomElements.Length {
            curRoom := roomElements[A_Index - 1].ChildNodes[0].nodeValue
            if (inhRooms.Length && inhRooms.at(-1) == curRoom) {
                continue
            }

            inhRooms.Push(curRoom)
        }

        xmlDoc := ""
        
        return inhRooms
    }

    /**
     * 
     * @param {Datebase} db db object
     * @param {Array} inhRooms in house room numbers
     * @param {Integer} fetchPeriod fetch period hrs
     * @returns {Array} grouped guest profiles
     */
    static getGroupGuests(db, inhRooms, fetchPeriod) {
        loadedGuests := []
        for (room in inhRooms) {
            loadedGuests.Push(db.load(, "roomNum", room, 60 * fetchPeriod)*)
        }

        return loadedGuests
    }
}
