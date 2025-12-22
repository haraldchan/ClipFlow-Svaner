;utils: general utility methods
class utils {
    ; Reset windows and key states.
    static cleanReload(winGroup, quit := 0) {
        ; Windows set default
        loop winGroup.Length {
            if (WinExist(winGroup[A_Index])) {
                WinSetAlwaysOnTop false, winGroup[A_Index]
            }
        }
        ; Key/Mouse state set default
        BlockInput false
        SetCapsLockState false
        CoordMode "Mouse", "Screen"
        if (quit = "quit") {
            ExitApp
        }
        Reload
    }

    ; Exit app with clean reload.
    static quitApp(appName, popupTitle, winGroup) {
        if (MsgBox(Format("是否退出 {1}？", appName), popupTitle, "OKCancel 4096") == "OK") {
            this.cleanReload(winGroup, "quit")
        } else {
            return true
        }
    }

    ; Insert text at the beginning of file.
    static filePrepend(textToInsert, fileToPrepend) {
        textOrigin := FileRead(fileToPrepend)
        FileDelete fileToPrepend
        FileAppend textToInsert . textOrigin, fileToPrepend
    }

    ; Type checking with error msg.
    static checkType(val, typeChecking, errMsg) {
        if (!(val is typeChecking)) {
            throw TypeError(Format("{1}; `n`nCurrent Type: {2}", errMsg, Type(val)))
        }
    }

    static imgSearchAll(imgPath, method := "TD") {
        ; method: "LeftRight" or "LR", "TopDown" or "TD"
        target := imgPath
        coords := []
        fromWidth := 0
        fromHeight := 0

        loop {
            if (!ImageSearch(&FoundX, &FoundY, fromWidth, fromHeight, A_ScreenWidth, A_ScreenWidth, target)) {
                if (A_Index = 1) {
                    MsgBox("Image Not Found.")
                }
                break
            } else {
                x := FoundX
                y := FoundY
                coords.Push([x, y])

                if (method = "LeftRight" || method = "LR") {
                    fromWidth := x
                } else if (method = "TopDown" || method = "TD") {
                    fromHeight := y
                }
            }
        }
    }

    static waitLoading(interval := 150) {
        loop {
            sleep interval
            if (A_Cursor != "Wait") {
                break
            }
        }
    }

    static checkClearWin(msgboxTitle, operaLogo){
        isFound := ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenWidth, operaLogo)
        if (isFound = false) {
            WinSetAlwaysOnTop false, "ahk_class SunAwtFrame"
            BlockInput false
            clearWin := MsgBox("请先清空 Opera 界面中的子窗口。", msgboxTitle, "OKCancel 4096")
            if (clearWin = "Cancel") {
                return "Cancel"
            } else {
                WinSetAlwaysOnTop true, "ahk_class SunAwtFrame"
                BlockInput "SendAndMouse"
                return "OK"
            }
        }
    }
}