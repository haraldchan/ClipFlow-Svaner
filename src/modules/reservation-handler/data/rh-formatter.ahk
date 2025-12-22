class OTA_Formatter {
    static dict := useDict()
    static supportList := [
        "jielv",
        "kingsley",
        "ctrip-ota",
        ; "ctrip-business",
        "meituan"
    ]

    static USE(curResv, splitParty := false, withRemarks := false, withTrace := false, extraPackages := "", overridenRateCode := "") {
        if (!this.supportList.find(agent => agent == curResv["agent"])) {
            return
        }

        this.parseReservation(curResv, splitParty, withRemarks, withTrace, extraPackages, overridenRateCode)
    }

    static roomTypeMap := OrderedMap(
        "SKC", "标准大床房",
        "SKC", "城市景观标准大床房",
        "DKC", "豪华城景大床房",
        "CKC", "行政豪华城景大床房",
        "DKR", "豪华江景大床房",
        "CKR", "行政豪华江景大床房",
        "CSK", "行政尊贵套房",
        "STC", "标准双床房",
        "STC", "城市景观标准双床房",
        "DTC", "豪华城景双床房",
        "CTC", "行政豪华城景双床房",
        "DTR", "豪华江景双床房",
        "CTR", "行政豪华江景双床房",
    )

    static parseReservation(curResv, splitParty, withRemarks, withTrace, extraPackages, overridenRateCode) {
        ; convert roomType
        try {
            roomType := this.roomTypeMap.keyOf(curResv["roomType"])
        } catch {
            rt := InputBox(Format("房型 ({1}) 未找到，请输入 RoomType Code。`n如：DKC。", curResv["roomType"]), POPUP_TITLE)
            if (rt.Result == "Cancel") {
                return
            }

            roomType := rt.Value
        }
        

        ; define breakfast type
        breakfastType := (roomType.substr(1, 1) == "C") ? "CBF" : "BBF"
        breakfastQty := curResv["bbf"]

        ; suite exception
        if (roomType == "CSK") {
            breakfastQty := 2
        }

        ; comment formatting
        comment := ""
        if (curResv["payment"].includes("预付")) {
            comment := (breakfastQty == 0) ? "RM TO TA" : Format("RM INCL {1}{2} TO TA", breakfastQty, breakfastType)
        } else {
            comments := []
            roomTotal := curResv["roomRates"].Length > 1
                ? Format("Total:RMB{} || ", curResv["roomRates"].reduce((acc, cur) => acc + cur, 0))
                    : ""

            loop curResv["roomRates"].Length {
                date := FormatTime(DateAdd(curResv["ciDate"], A_Index - 1, "Days"), "MM/dd")
                datePrint := ""
                rate := curResv["roomRates"][A_Index]

                if (A_Index > 1 && rate == curResv["roomRates"][A_Index - 1]) {
                    prevDate := comments.at(-1)[1]
                    datePrint := prevDate.includes("-")
                        ? prevDate.split("-")[1] . "-" . date
                        : prevDate . "-" . date

                    comments[comments.Length][1] := datePrint
                } else {
                    comments.Push([date, rate])
                }
            }

            comment := roomTotal . comments.map(cmmt => Format("{1}:RMB{2}net{3}", cmmt[1], cmmt[2], breakfastQty > 0 ? " INCL " . breakfastQty . breakfastType : "")).join("; ")
        }

        if (withRemarks) {
            comment .= ", " . curResv["remarks"]
        }

        ; reformat guest names
        pmsGuestNames := []
        loop curResv["guestNames"].Length {
            curGuestName := curResv["guestNames"][A_Index].trim()
            if (RegExMatch(curGuestName, "^[a-zA-Z/ ]+$") > 0) {
                ; if only includes English alphabet, push [lastName, firstName]
                if (curGuestName.includes("/")) {
                    pmsGuestNames.Push(StrSplit(curGuestName, "/"))
                } else {
                    splittedName := curGuestName.split(" ")
                    lastName := splittedName.Pop()
                    pmsGuestNames.Push([lastName, splittedName.join(" ")])
                }
            } else {
                unpack([&lastName, &firstName], this.dict.getFullnamePinyin(curGuestName))
                pmsGuestNames.Push([lastName, firstName, curGuestName])
            }
        }

        agentConfigName := (curResv["agent"] == "ctrip-ota" && curResv["payment"].includes("商旅")) ? "ctrip-ota-shanglv" : curResv["agent"]
        configFields := CONFIG.read(agentConfigName)

        if (overridenRateCode) {
            configFields["ratecode"] := [overridenRateCode, overridenRateCode, overridenRateCode]
        }

        ; apply booking modification
        RH_OtaBookingEntry.USE(
            curResv,
            roomType,
            comment,
            pmsGuestNames,
            splitParty,
            extraPackages,
            configFields,
            withTrace
        )
    }
}
