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
		roomNums := Trim(form["shareRoomNums"])
		shareQty := Trim(form["shareQty"])
		checkIn := form["checkIn"]

		this.start()
		; single room share(s)
		if (!roomNums) {
			this.makeShare(checkIn, shareQty)
			return
		}

		; multi room share(s)
		shareQty := shareQty.includes(" ") ? shareQty.split(" ") : [shareQty]
		roomNums := roomNums.includes(" ") ? roomNums.split(" ") : [roomNums]
		for room in roomNums {
			if (shareQty[A_Index] == 0) {
				continue
			}

			res := this.search(room)
			if (res == "not found") {
				continue
			}

			if (!this.isRunning) {
            	msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
            	return	
			}
			utils.waitLoading()
			this.makeShare(checkIn, shareQty[A_Index], true)
			utils.waitLoading()
		}

		this.end()
	}

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
        Click 838, 378, "Right" 
        Sleep 200
        Send "{Down}"
        Sleep 200
        Send "{Enter}"
        if (!this.isRunning) {
            msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
            return
        }
	}

	static makeShare(checkIn, shareQty, keepGoing := false, initX := 949, initY := 599) {
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


		; delete comment
		loop {
			; delete multiple
			CoordMode "Pixel"
			if (!PixelSearch(&_, &_, initX - 328, initY, initX, initY, "0xFFFF00")) {
				break
			}

			MouseMove initX, initY ; 949, 599
			utils.waitLoading()
			Click
			utils.waitLoading()
			Send "!d"
			MouseMove initX - 338, initY - 53 ; 611, 546
			utils.waitLoading()
			Click
			utils.waitLoading()
			Send "!c"
			utils.waitLoading()
		}

		MouseMove initX, initY ; 949, 599
		utils.waitLoading()
		Click
		utils.waitLoading()
		Send "!d"
		MouseMove initX - 338, initY - 53 ; 611, 546
		utils.waitLoading()
		Click
		utils.waitLoading()
		Send "!c"
		utils.waitLoading()

		if (!this.isRunning) {
			msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
			return
		}


		; check multiple RateCode
		; from := [initX - 682, initY - 107] ; 267, 492
		; to := [initX - 585, initY - 62] ; 364, 537
		; if (PixelSearch(&_, &_, from[1], from[2], to[1], to[2], "0xFFFF00")) {
		; 	Send "!i"
		; 	utils.waitLoading()
		; 	Send "!c"
		; 	utils.waitLoading()
		; 	Send "{Tab}"
		; 	utils.waitLoading()

		; 	; copy orignal nts
		; 	Send "^c"
		; 	utils.waitLoading()
		; 	originalNts := A_Clipboard
		; 	Send "{Text}0"
		; 	utils.waitLoading()
		; 	Send "{Tab}"
		; 	utils.waitLoading()
		; 	loop 4 {
		; 		Send "{Esc}"
		; 		utils.waitLoading()
		; 	}
		; }

		; change RateCode to NRR
		MouseMove initX - 625, initY - 92 ; 324, 507
		utils.waitLoading()
		Click "Down"
		MouseMove initX - 737, initY - 79 ; 212, 520
		utils.waitLoading()
		Click "Up"
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


		; restore original nts
		; if (PixelSearch(&_, &_, from[1], from[2], to[1], to[2], "0xFFFF00")) {
		; 	Send "!i"
		; 	utils.waitLoading()
		; 	Send "!c"
		; 	utils.waitLoading()
		; 	Send "{Tab}"
		; 	utils.waitLoading()

		; 	; restore orignal nts
		; 	Send "{Text}" . originalNts
		; 	utils.waitLoading()
		; 	Send "{Tab}"
		; 	utils.waitLoading()
		; 	loop 4 {
		; 		Send "{Esc}"
		; 		utils.waitLoading()
		; 	}
		; }


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