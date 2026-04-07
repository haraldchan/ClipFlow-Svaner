class PmsImageFinder {
    static images := useImages(A_ScriptDir . "\assets")

    /**
     * Finds image on screen.
     * @param {String} imageFileName 
     * @param {Integer} interval wait interval in millisecond
     * @param {Integer} timeoutTick wait tick
     * @returns { { outX: Integer, outY: Integer } | false} 
     */
    static find(imageFileName, interval := 250, timeoutTick := 1, findOptions := { coordMode: "Screen", x1: 0, y1:0, x2: A_ScreenWidth, y2: A_ScreenHeight }) {
        if (WinExist("ahk_class SunAwtFrame")) {
            WinActivate("ahk_class SunAwtFrame")
        }

        userCoordMode := findOptions.HasOwnProp("coordMode") ? findOptions.coordMode : "Screen"
        x1 := findOptions.HasOwnProp("x1") ? findOptions.x1 : 0
        y1 := findOptions.HasOwnProp("y1") ? findOptions.y1 : 0
        x2 := findOptions.HasOwnProp("x2") ? findOptions.x2 : A_ScreenWidth
        y2 := findOptions.HasOwnProp("y2") ? findOptions.y2 : A_ScreenHeight

        CoordMode("Pixel", userCoordMode)
        timeoutCount := 0
        result := false

        loop {
            ImageSearch(&outX, &outY, x1, y1, x2, y2, this.images[imageFileName])
            if (outX && outY) {
                result := { outX: Integer(outX), outY: Integer(outY) }
                break
            }

            timeoutCount++
            Sleep(interval)
        } until (timeoutCount > timeoutTick)

        return result
    }
}