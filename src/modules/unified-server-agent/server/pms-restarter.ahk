#SingleInstance Force

PMS_USERNAME := "FOHARALDC"
PMS_PASSWORD := "sxzc123456"
        
shell := ComObject("WScript.Shell")
chrome360Path := "F:\360\360se6\Application\360se.exe"
pmsPath := "https://wsh-opr-app1"
command := A_ComSpec . Format(" /c start {1} {2}", chrome360Path, pmsPath)

shell.Exec(command)
WinWait("ahk_exe 360se.exe")
WinActivate("ahk_exe 360se.exe")
shell := ""

WinWait("OPERA Login")        
Sleep(200)

; log into opera
Click(129, 251)
Sleep(100)
Send("{TEXT}" . PMS_USERNAME)
Sleep(100)
Send("{Tab}")
Sleep(100)
Send("{TEXT}" . PMS_PASSWORD)
loop 3 {
    Sleep(100)
    Send("{Tab}")
}
Sleep(100)
Send("{Enter}")
waitLoading(1000)

ImageSearch(&x, &y, 0, 0, A_ScreenWidth, A_ScreenHeight, "Z:\19-个人文件夹\HC\Software - 软件及脚本\AHK_Scripts\ClipFlow-SvanerTest-main\assets\pms-login.png")
Sleep(200)
Click(x, y)

; wait for PMS app
WinWait("OPERA PMS")
Sleep(500)
WinActivate("ahk_class SunAwtFrame")
Sleep(2000)
Send("!f")
Sleep(100)
Send("{Down}")
Sleep(100)
Send("{Enter}")
waitLoading()
WinMaximize("ahk_class SunAwtFrame")
Sleep(100)

waitLoading(interval := 150) {
    loop {
        sleep(interval)
        if (A_Cursor != "Wait") {
            break
        }
    }
}