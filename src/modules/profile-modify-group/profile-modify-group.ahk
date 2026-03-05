; components
#Include components\pmg-app.ahk
#Include components\group-guest-list.ahk
#Include components\on-day-group.ahk
#Include components\settings.ahk
; macros
#Include macros\pmg-data.ahk
#Include macros\pmg-execute.ahk


class ProfileModify_Group {
    static name := "ProfileModify Group"
    static title := "Flow Mode - " . this.name
    static popupTitle := "ClipFlow - " . this.name

    static USE(App) {
        dbConfig := CONFIG.read("dbConfig")
        this.db := useFileDB({
            main: dbConfig["host"] . dbConfig["main"],
            archive: dbConfig["host"] . dbConfig["archive"],
            backup: dbConfig["host"] . dbConfig["backup"],
        })

        PMG_App(App, this.title, this.db)
    }
}