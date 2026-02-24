; schema
#Include schema\guest-profile.ahk
; components
#Include components\pmn-app.ahk
#Include components\guest-profile-list.ahk
#Include components\guest-profile-details.ahk
#Include components\sent-posts.ahk
#Include components\settings.ahk
; macros
#Include macros\fill-in.ahk
#Include macros\waterfall.ahk

class ProfileModifyNext {
    static name := "ProfileModifyNext"
    static title := "Flow Mode - " . this.name
    static popupTitle := "ClipFlow - " . this.name
    static identifier := "04047fce826f48f751891b4721f7ac70" ; MD5 hash: ProfileModifyNext

    static USE(App) {
        dbConfig := CONFIG.read("dbConfig")
        this.db := useFileDB({
            ; main: dbConfig["host"] . "\" . dbConfig["main"],
            ; archive: dbConfig["host"] . "\" . dbConfig["archive"],
            ; backup: dbConfig["host"] . "\" . dbConfig["backup"],
            main: "",
            archive: "",
            backup: "",
        })

        yesterday := A_Now.yesterday().toFormat("yyyyMMdd")

        ; if (!FileExist(this.db.archive . "\" . yesterday . " - archive.json")) {
            ; this.db.createArchive(yesterday)
        ; }
        
        PMN_App(App, this.title, this.db, this.identifier)
    }
}
