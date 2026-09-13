#Include landow-image-finder.ahk

class Landow {
    static appPath := "C:\Program Files (x86)\Landow\CmsManager\CmsManager.exe"
    static loginTitle := "登录"
    static winTitle := "住客服务管家"
    static exe := "ahk_exe CmsManager.exe"

    static runAndLogin() {
        Run(this.appPath)
        loop {
            if (WinExist(this.exe)) {
                break
            }
            Sleep(100)

            if (A_Index > 100) {
                break
            }
        }

        WinActivate(this.loginTitle)
        Send("{Tab}")
        Sleep(100)
        Send("{Space}")
        Sleep(100)
        Send("{Enter}")
        Sleep(100)

        WinWait(, this.winTitle, 3)
        res := LandowImageFinder.find("landow-contact.png", 1000)
        if (!res) {
            return
        }

        WinActivate(this.winTitle)
        Sleep(100)

        CoordMode("Mouse", "Client")
        Click(65, 225)
        CoordMode("Mouse", "Screen")
    }

    static close() {
        DetectHiddenWindows(true)
        loop {
            if (id := WinExist(this.winTitle)) {
                pid := WinGetPID("ahk_id " . id)
                if (!pid) {
                    break
                }
                ProcessClose(pid)
            }
        } until (!WinExist(this.winTitle))
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
        if (!WinExist(this.winTitle)) {
            this.runAndLogin()
        }
        WinActivate(this.winTitle)

        this.clickGuestService()
        Sleep(100)
        this.clickNewOrder()
        Sleep(100)
        this.clickItemAndService()
        Sleep(100)

        found := LandowImageFinder.find("landow-no-guest.png", 50)
        if (!found) {
            throw Error("Landow CmsManager failed.")
        }

        ; send room num and wait for guest to load
        Sleep(200)
        Send("{Text}" . roomNum)
        Sleep(100)
        Send("{Enter}")
        Sleep(100)

        found := LandowImageFinder.find("landow-loaded.png", 50)
        if (!found) {
            this.close()
            throw Error("Landow CmsManager failed.")
        }

        ; send order type
        WinActivate(this.winTitle)
        Click()
        Sleep(2000)
        Send("{Tab}")
        Sleep(100)
        Send("{Text}" . orderType)
        Sleep(100)
        Send("{Enter}")
        Sleep(1000)

        ; send qty
        Send("{Tab}")
        Sleep(100)
        Send("{Text}" . qty)
        Sleep(100)
        Send("{Tab}")
        Sleep(100)

        ; move to remarks
        Send("{Tab}")
        Sleep(100)
        Send("{Text}" . remarks)

        ; confirm send
        Send("{Tab}")
        Sleep(100)
        Send("{Enter}")
        Sleep(100)
        ; TODO: resolve duplicated order
    }
}