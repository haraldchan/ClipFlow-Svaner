#Include ..\index.ahk

db := useFileDB({
    main: "C:\Users\haraldchan\Code\ClipFlow - SvanerTest\lib\use-file-db\test-base"
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
    res := db.load()

    msgbox JSON.stringify(res)
}
TestLoad()