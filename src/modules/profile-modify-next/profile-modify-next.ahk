; schema
#Include schema\guest-profile.ahk
; parsers
#Include parsers\ws-message-formatter.ahk
#Include parsers\psb-sheet-exporter.ahk
; components
#Include components\pmn-app.ahk
#Include components\guest-profile-list.ahk
#Include components\guest-profile-details.ahk
#Include components\sent-posts.ahk
#Include components\settings.ahk
#Include components\offline-controls.ahk
; macros
#Include macros\fill-in.ahk
#Include macros\fill-psb.ahk
#Include macros\waterfall.ahk

#Include migrate.ahk

class ProfileModifyNext {
    static name := "ProfileModifyNext"
    static title := "Flow Mode - " . this.name
    static popupTitle := "ClipFlow - " . this.name
    static identifier := "04047fce826f48f751891b4721f7ac70" ; MD5 hash: ProfileModifyNext
    static usingDB := signal("uncDB")
    /**
     * @type {Datebase}
     */
    static db := ""

    static USE(App) {
        sqliteConfig := CONFIG.read("sqliteConfig")

        this.uncDB := {
            name: "uncDB",
            dbPath: sqliteConfig["dbPath"],
            retentionDays: sqliteConfig["retentionDays"]
        }

        this.localDB := {
            name: "localDB",
            dbPath: "c:\ClipFlow\db\GuestProfilesDB\guests.sqlite",
            retentionDays: sqliteConfig["retentionDays"]
        }

        ; initialize db
        if (FileExist(this.uncDB.dbPath.replace("\guests.sqlite"))) {
            this.db := Datebase(this.uncDB)
        }
        else {
            this.db := Datebase(this.localDB)
            this.usingDB.set("localDB")
        }
        effect(this.usingDB, newUsingDB => (
            this.db.close(),
            this.db := Datebase(this.%newUsingDB%)
        ))

        ; create backup
        if (FileExist(sqliteConfig["dbPath"])) {
            FileCopy(sqliteConfig["dbPath"], sqliteConfig["backupDir"] . "\guests_backup.sqlite", true)
        }

        ; add ws message listener
        clbListeners.addListener({
            description: "离线证件读取",
            isOn: true,
            type: "module",
            callback: (*) => WSMessageParser.capture(WSMessageParser.identifier)
        })

        ; mount module component
        PMN_App(App, this.title, this.switchDB.Bind(this), this.identifier)

        ; MigrateHelper(this.switchDB.Bind(this))
    }

    /**
     * @returns {Datebase} 
     */
    static switchDB() {
        if (this.usingDB.value == "uncDB" && !FileExist(this.uncDB.dbPath)) {
            this.usingDB.set("localDB")
        }

        return this.db
    }
}