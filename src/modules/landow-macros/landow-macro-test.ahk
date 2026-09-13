#Include "..\..\..\lib\index.ahk"
#Include "landow.ahk"
#Include "landow-image-finder.ahk"

LandowImageFinder.images := useImages(A_ScriptDir . "\landow-ui-pics")

testCreateOrder(roomNum, orderType, qty := 1, remarks := 0) {
    Landow.createOrder(roomNum, orderType, qty, remarks)
}
testCreateOrder("2406", "其他服务", , "测试，请无视此单")

testLogin() {
    Landow.runAndLogin()
}
; testLogin()