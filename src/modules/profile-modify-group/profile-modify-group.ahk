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
    /**
     * @type {Datebase}
     */
    static db := ""


    static USE(App) {
        sqliteConfig := CONFIG.read("sqliteConfig")
        this.db := DateBase({
            name: "pmgDB",
            dbPath: sqliteConfig["dbPath"],
            retentionDays: sqliteConfig["retentionDays"]
        })

        PMG_App(App, this.title, this.db)
    }
}
