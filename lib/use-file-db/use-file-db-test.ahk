#SingleInstance Force
#Include ..\index.ahk

db := useFileDB({
    main: "C:\Users\haraldchan\Code\ClipFlow - SvanerTest\lib\use-file-db\test-base",
    cacheKey: "regTime"
})

testJSON := {
    name: "hc",
    age: 36
}

TestAdd() {
    db.add(JSON.stringify(testJSON))
}
; TestAdd()

TestLoad() {
    TL := Svaner({})

    data := signal(db.load())
    ; cache := signal(JSON.stringify(db.cache))

    handleRefresh(*) {
        date := TL["dt"].Value.toFormat("yyyyMMdd")
        data.set(db.load(, date, 60 * 24 * 30))
        ; cache.set(JSON.stringify(db.cache))
    }

    return (
        TL.AddDateTime("vdt w100", "yyyy/MM/dd"),
        TL.AddButton("w100 x+5", "refresh").onClick(handleRefresh),

        TL.AddListView(
            {
                lvOptions: "vguest-profile-list Grid -ReadOnly -Multi LV0x4000 w650 r16 @align[x]:dt y+10",
                itemOptions: ""
            }, 
            {
                keys: ["roomNum", "name", "gender", "idType", "idNum", "addr"],
                titles: ["房号", "姓名", "性别", "类型", "证件号码", "地址"],
                widths: [70, 120, 45, 80, 180, 150]
            }, 
            data
        ).onDoubleClick((LV, row) => MsgBox(JSON.stringify(data.value[row]),,"4096")),

        ; TL.AddEdit("y+5 w650 h300", "{1}", cache),

        TL.Show()
    )
}
TestLoad()