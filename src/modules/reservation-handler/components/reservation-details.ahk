ReservationDetails(App, curResv) {

    effect(curResv, handleListUpdate)
    handleListUpdate(curResv) {
        LV := App["resv-detail-list"]
        LV.Delete()

        if (curResv["agent"] == "fedex") {
            for key, field in RH_Models.fedexListFields {
                if (key == "crewNames") {
                    val := curResv[key].join(", ")
                } else if (key == "ciDate" || key == "coDate") {
                    val := FormatTime(curResv[key], "yyyy-MM-dd")
                } else {
                    val := curResv[key]
                }

                LV.Add(, field, val)
            }
        } else {
            for key, field in RH_Models.otaListFields {
                if (key == "guestNames" || key == "roomRates") {
                    val := curResv[key].join(", ")
                } else if (key == "ciDate" || key == "coDate") {
                    val := FormatTime(curResv[key], "yyyy-MM-dd")
                } else if (key == "bbf") {
                    val := match(curResv[key], { 0: "不含早", 1: "单早", 2: "双早" })
                } else {
                    val := curResv.has(key) ? curResv[key] : ""
                }

                LV.Add(, field, val)
            }
        }
    }

    return (
        App.AddListView("vresv-detail-list Grid @lv:label-tip NoSortHdr w310 r13 yp+30", ["预订项目", "预订详情"])
    )
}