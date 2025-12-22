PostDetails_Profile(post) {
    App := Gui(, "Post Details - " . post["id"])
    App.SetFont(, "微软雅黑")
    App.OnEvent("Close", (*) => App.Destroy())
    
    profilesList := []
    for groupedProfiles in post["content"]["profiles"] {
        for room, profiles in groupedProfiles {
            profilesList.Push(profiles*)
        }        
    }
    profiles := signal(profilesList)

    columnDetails := {
        keys: ["roomNum","name", "gender", "idType", "idNum", "addr"],
        titles: ["房号", "姓名", "性别", "类型", "证件号码", "地址"],
        widths: [60, 90, 40, 80, 145, 120]
    }

    options := {
        lvOptions: "vguestProfileList Grid NoSortHdr ReadOnly -Multi LV0x4000 w550 r8 y+10",
        itemOptions: ""
    }

    handleRepost(*) {
        SetTimer(() => (
            agent.delegate({
                mode: post["content"]["mode"],
                overwrite: post["content"]["overwrite"],
                rooms: profiles.value.map(p => p["roomNum"]).unique(),
                party: post["content"]["party"],
                profiles: post["content"]["profiles"]
            }),
            renameResendPost(post["id"])
        ), -250)

        App.Destroy()
    }

    renameResendPost(id) {
        loop files (agent.pool . "\*.json") {
            if (InStr(A_LoopFileFullPath, id)) {
                status := StrSplit(A_LoopFileName, "==")[1]
                FileMove(A_LoopFileFullPath, StrReplace(A_LoopFileFullPath, status, "RESENT"))
                break
            }
        }
    }

    getSelectedCell(LV, row, key) {
        return LV.GetText(row, columnDetails.keys.findIndex(item => item == key))
    }

    handleProfilesUpdate(LV, row, *) {
        profileToChange := profiles.value.find(profile => profile["idNum"] == getSelectedCell(LV, row, "idNum"))
        profileToChange["roomNum"] := getSelectedCell(LV, row, "roomNum")

        profiles.update(profiles.value.findIndex(p => p["idNum"] == profileToChange["idNum"]), profileToChange)
    }

    return (
        App.AddGroupBox("Section w560 r12", "代行详情").SetFont("Bold"),
        App.AddText("xs10 yp+20", "发送状态: " . post["status"]),
        App.AddText("xs10 yp+20", "发送时间: " . post["time"]),
        App.AddText("xs10 w200 yp+30" , "客人资料").SetFont("Bold s10"),
        
        ; post guest list
        App.ARListView(options, columnDetails, profiles).OnEvent("ItemEdit", handleProfilesUpdate),
        
        ; repost btn
        App.AddButton("w120 h30 y+25", "重新发送代行").OnEvent("Click", handleRepost),
        
        App.Show()
    )
}