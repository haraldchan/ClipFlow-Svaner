class PmsImageFinder {
    static images := useImages(A_ScriptDir . "\assets")

    /**
     * Finds image on screen.
     * @param {String} imageFileName 
     * @param {Integer} interval wait interval in millisecond
     * @param {Integer} timeoutTick wait tick
     * @returns { { outX: Integer, outY: Integer } | false} 
     */
    static find(imageFileName, interval := 250, timeoutTick := 10, findOptions := { coordMode: "Screen", x1: 0, y1:0, x2: A_ScreenWidth, y2: A_ScreenHeight }) {
        if (WinExist("ahk_class SunAwtFrame")) {
            WinActivate("ahk_class SunAwtFrame")
        }

        coordMode := findOptions.HasOwnProp("coordMode") ? findOptions.coordMode : "Screen"
        x1 := findOptions.HasOwnProp("x1") ? findOptions.x1 : 0
        y1 := findOptions.HasOwnProp("y1") ? findOptions.y1 : 0
        x2 := findOptions.HasOwnProp("x2") ? findOptions.x2 : A_ScreenWidth
        y2 := findOptions.HasOwnProp("y2") ? findOptions.y2 : A_ScreenHeight

        CoordMode("Pixel", coordMode)
        timeoutCount := 0

        loop {
            ImageSearch(&outX, &outY, x1, y1, x2, y2, this.images[imageFileName])
            if (outX && outY) {
                return { outX: Integer(outX), outY: Integer(outY) }
            }

            timeoutCount++
            Sleep(interval)
        } until (timeoutCount > timeoutTick)

        return false
    }
}