#Include landow-image-finder.ahk

class Landow {
    static appPath := "" ; TODO: check path
    static ahkExe := "ahk_exe CmsManager.exe"

    static runAndLogin() {
        Run(this.appPath)
        loop {
            if (WinExist(this.ahkExe)) {
                break
            }
            Sleep(100)
        }

        WinActivate(this.ahkExe)
        Send("{Tab}")
        Sleep(100)
        Send("{Space}")
        Sleep(100)
        Send("{Enter}")
        Sleep(100)

        res := LandowImageFinder.find("landow-contact.png", 30)
        if (!res) {
            return
        }
    }

    static close() {
        DetectHiddenWindows(true)
        loop {
            if (id := WinExist(this.ahkExe)) {
                pid := WinGetPID("ahk_id " . id)
                if (!pid) {
                    break
                }
                ProcessClose(pid)
            }
        } until (!WinExist(this.ahkExe))
    }

    ; 对客服务
    static clickGuestService() {
        CoordMode("Mouse", "Window")
        Click(69, 161)
        CoordMode("Mouse", "Screen")
    }

    ; 新建服务单
    static clickNewOrder() {
        CoordMode("Mouse", "Window")
        Click(201, 59)
        CoordMode("Mouse", "Screen")
    }

    ; 物品服务
    static clickItemAndService() {
        CoordMode("Mouse", "Window")
        Click(207, 140)
        CoordMode("Mouse", "Screen")
    }

    static createOrder(roomNum, orderType, qty := 1, remarks := 0) {
        if (!WinExist(this.ahkExe)) {
            this.runAndLogin()
        }
        WinActivate(this.ahkExe)

        this.clickGuestService()
        Sleep(100)
        this.clickNewOrder()
        Sleep(100)
        this.clickItemAndService()
        Sleep(100)

        found := LandowImageFinder.find("landow-no-guest.png", 30)
        if (!found) {
            throw Error("Landow CmsManager failed.")
        }

        ; send room num and wait for guest to load
        Send("{Text}" . roomNum)
        Sleep(100)
        Send("{Enter}")
        Sleep(100)

        found := LandowImageFinder.find("landow-loaded.png", 30)
        if (!found) {
            this.close()
            throw Error("Landow CmsManager failed.")
        }

        ; send order type
        Send("{Tab}")
        Sleep(100)
        Send("{Text}" . orderType)
        Sleep(100)
        Send("{Enter}")
        Sleep(100)

        ; send qty  
        Send("{Tab}")
        Sleep(100)
        Send("{Text}" . qty)
        Sleep(100)
        Send("{Enter}")
        Sleep(100)

        ; move to remarks
        loop 2 {
            Send("{Tab}")
            Sleep(100)
        }
        Send("{Text}" . remarks)

        ; confirm send
        Send("{Tab}")
        Sleep(100)
        Send("{Enter}")
        Sleep(100)
        ; TODO: resolve duplicated order
    }
}