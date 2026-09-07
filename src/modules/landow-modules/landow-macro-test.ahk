#Include "..\..\..\ClipFlow_x64.ahk"

testCreateOrder(roomNum, orderType, qty := 1, remarks := 0) {
    LandowImageFinder.images := A_ScriptDir . "\landow-ui-pics"

    Landow.createOrder(roomNum, orderType, qty := 1, remarks := 0)
}