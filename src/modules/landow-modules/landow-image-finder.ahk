class LandowImageFinder {
    static images := useImages(A_ScriptDir . "\src\modules\landow-modules\landow-ui-pics")

    /**
     * Finds image on screen.
     * @param {String} imageFileName 
     * @param {Integer} timeoutTick wait tick
     * @param {Integer} interval wait interval in millisecond
     * @returns {false | { outX: Integer, outY: Integer }}
     */
    static find(imageFileName, timeoutTick := 1, interval := 200) {
        if (WinExist(Landow.ahkExe)) {
            WinActivate(Landow.ahkExe)
            WinGetClientPos(,,&w, &h, "A")
        }

        CoordMode("Pixel", "Window")
        timeoutCount := 0
        result := false
        
        loop {
            ImageSearch(&outX, &outY, 0, 0, w, h, this.images[imageFileName])
            if (outX && outY) {
                result := { outX: Integer(outX), outY: Integer(outY) }
                break
            }

            timeoutCount++
            Sleep(interval)
        } until (timeoutCount > timeoutTick)

        CoordMode("Pixel", "Screen")
        return result
    }
}