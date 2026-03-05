class BlankShare_Action {
	static isRunning := false

	static start() {
		this.isRunning := true
		HotIf (*) => this.isRunning
		Hotkey("F12", (*) => this.end(), "On")

		WinMaximize "ahk_class SunAwtFrame"
		WinActivate "ahk_class SunAwtFrame"
		Sleep 500
		WinSetAlwaysOnTop true, "ahk_class SunAwtFrame"
		BlockInput true
	}

	static end() {
		this.isRunning := false
		Hotkey("F12", "Off")

		BlockInput false
		WinSetAlwaysOnTop false, "ahk_class SunAwtFrame"
	}

	static USE(form) {
		form := JSON.parse(JSON.stringify(form))
		roomNumsInput := Trim(form["shareRoomNums"])
		shareQtyInput := Trim(form["shareQty"])
		checkIn := form["checkIn"]

		this.start()
		; single room share(s)
		if (!roomNumsInput) {
			this.makeShare(checkIn, shareQtyInput)
			return
		}

		; multi room share(s)
		shareQty := shareQtyInput.includes(" ") ? shareQtyInput.split(" ") : [shareQtyInput]
		roomNums := roomNumsInput.includes(" ") ? roomNumsInput.split(" ") : [roomNumsInput]
		for room in roomNums {
			if (shareQty[A_Index] == 0) {
				continue
			}

			res := this.search(room)
			if (res == "not found") {
				continue
			}

			; this.search(room)
			existShares := this.getExistShares()

			if (existShares < shareQty[A_Index]) {
				sharesToMake := shareQty[A_Index] - existShares
				this.search(room)
			} else {
				continue
			}

			if (!this.isRunning) {
            	msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
            	return	
			}
			utils.waitLoading()
			this.makeShare(checkIn, sharesToMake ?? 0, true)
			utils.waitLoading()
		}

		this.end()
	}

	/**
	 * @param {String} roomNum 
	 * @returns {void | String} 
	 */
	static search(roomNum) {
        formattedRoom := StrLen(roomNum) == 3 ? "0" . roomNum : roomNum

		Send "!r" ; room number field
        utils.waitLoading()
        if (!this.isRunning) {
            msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
            return
        }

        Send "{Text}" . formattedRoom
        utils.waitLoading()


        Send "!h" ; alt+h => search
        utils.waitLoading()

        CoordMode "Pixel", "Screen"
        if (ImageSearch(&_, &_ ,0, 0, A_ScreenWidth, A_ScreenHeight, IMAGES["info.png"])) {
        	Send "{Enter}"
        	return "not found"
        }

        if (!this.isRunning) {
            msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
            return
        }

        ; sort by Prs.
        ImageSearch(&outX, &outY, 0, 0, A_ScreenWidth, A_ScreenHeight, IMAGES["opera-active-win.PNG"])
        Click outX + 672, outY + 222, "Right"
        Sleep 200
        Send "{Down}"
        Sleep 200
        Send "{Enter}"
        if (!this.isRunning) {
            msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
            return
        }
	}

	/**
	 * @returns {Integer} 
	 */
	static getExistShares() {
		CoordMode "Pixel", "Screen"
		existShareCount := 0

        ImageSearch(&outX, &outY, 0, 0, A_ScreenWidth, A_ScreenHeight, IMAGES["opera-active-win.PNG"])
		x := outX + 635
		y := outY + 264

		loop {
			Send "{Down}"
			utils.waitLoading()
			if (PixelGetColor(x, y) == "0x000080") {
				existShareCount++
				y += 22
			} else {
				break
			}
		}

		return existShareCount
	}

	/**
	 * @param {true | false} checkIn 
	 * @param {Integer} shareQty 
	 * @param {true | false} keepGoing 
	 * @param {Integer} initX 
	 * @param {Integer} initY 
	 */
	static makeShare(checkIn, shareQty, keepGoing := false) {
		this.start()

		; create share
		Send "!t"
		utils.waitLoading()
		Send "!s"
		utils.waitLoading()
		Send "!m"
		utils.waitLoading()
		Send "{Esc}"
		utils.waitLoading()
		Send "{Text}1"
		utils.waitLoading()
		loop 4 {
			Send "{Tab}"
			utils.waitLoading()
		}
		if (!this.isRunning) {
			msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
			return
		}

		Send "{Text}0"
		utils.waitLoading()
		Send "{Tab}"
		utils.waitLoading()
		Send "{Tab}"
		utils.waitLoading()
		Send "{Text}6"
		utils.waitLoading()
		Send "!o"
		utils.waitLoading()

		if (!this.isRunning) {
			msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
			return
		}

		; open resv
		Send "!r"
		utils.waitLoading()
		Sleep 100


		; delete comment
		CoordMode "Pixel"
		ImageSearch(&x, &y, 0, 0, A_ScreenWidth, A_ScreenHeight, IMAGES["opera-active-win.PNG"])
		MouseMove x + 752, y + 415
		Click
		utils.waitLoading()
		loop {
			Send "!d"
			utils.waitLoading()
			if (!ImageSearch(&_, &_, 0, 0, A_ScreenWidth, A_ScreenHeight, IMAGES["alert.PNG"])) {
				break
			}
			Send "!y"
			utils.waitLoading()
		}
		; close comment win
		Send "!c"
		utils.waitLoading()
		if (!this.isRunning) {
			msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
			return
		}

		; change RateCode to NRR
		MouseClickDrag "L", x + 131, y + 324, x + 40, y + 324 
		utils.waitLoading()
		Send "{Text}NRR"
		utils.waitLoading()
		Send "!o"
		utils.waitLoading()
		loop 4 {
			Send "{Esc}"
			utils.waitLoading()
		}
	
		if (!this.isRunning) {
			msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
			return
		}

		if (checkIn) {
			Send "!i"
			utils.waitLoading()

			CoordMode "Pixel", "Screen"
			if (ImageSearch(&foundX, &foundY, 0, 0, A_ScreenWidth, A_ScreenHeight, IMAGES["alert.png"])) {
				if (PixelGetColor(foundX + 303, foundY) == "0xD7D7D7") {
					Send "!y"
					utils.waitLoading()
				} 
			}

			Send "{Esc}"
			utils.waitLoading()
			Send "{Space}"
			utils.waitLoading()
		}

		if (shareQty > 1) {
			loop (shareQty - 1) {
				if (!this.isRunning) {
					msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
					return
				}
				loop 5 {
					Send "{Down}"
					utils.waitLoading()
				}
				Send "!m"
				utils.waitLoading()
				Send "{Esc}"
				utils.waitLoading()
				Send "{Text}1"
				utils.waitLoading()
				loop 4 {
					Send "{Tab}"
					utils.waitLoading()
				}
				Send "{Text}0"
				utils.waitLoading()
				Send "{Tab}"
				utils.waitLoading()
				Send "{Tab}"
				utils.waitLoading()
				Send "{Text}6"
				utils.waitLoading()
				Send "!o"
				utils.waitLoading()

				if (checkIn) {
					Send "!i"
					utils.waitLoading()
		
					CoordMode "Pixel", "Screen"
					if (ImageSearch(&foundX, &foundY, 0, 0, A_ScreenWidth, A_ScreenHeight, IMAGES["alert.PNG"])) {
						if (PixelGetColor(foundX + 303, foundY) == "0xD7D7D7") {
							Send "!y"
							utils.waitLoading()
						} 
					}
		
					Send "{Esc}"
					utils.waitLoading()
					Send "{Space}"
					utils.waitLoading()
				}
			}
		}

		Send "!o"
		utils.waitLoading()
		Send "!c"
		utils.waitLoading()

		( !keepGoing && this.end() )
	}
}
