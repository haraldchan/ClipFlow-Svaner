class PmsImageFinder {
    static images := useImages(A_ScriptDir . "\assets")

    /**
     * Finds image on screen.
     * @param {String} imageFileName 
     * @param {Integer} interval wait interval in millisecond
     * @param {Integer} timeoutTick wait tick
     * @returns { { outX: Integer, outY: Integer } | false} 
     */
    static find(imageFileName, interval := 250, timeoutTick := 10) {
        if (WinExist("ahk_class SunAwtFrame")) {
            WinActivate("ahk_class SunAwtFrame")
        }
        CoordMode("Pixel", "Screen")
        timeoutCount := 0

        loop {
            ImageSearch(&outX, &outY, 0, 0, A_ScreenWidth, A_ScreenHeight, this.images[imageFileName])
            if (outX && outY) {
                return { outX: Integer(outX), outY: Integer(outY) }
            }

            timeoutCount++
            Sleep(interval)
        } until (timeoutCount > timeoutTick)

        return false
    }
}