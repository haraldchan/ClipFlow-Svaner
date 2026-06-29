; schema
#Include schema\guest-profile.ahk
#Include schema\ws-message-formatter.ahk
; components
#Include components\pmn-app.ahk
#Include components\guest-profile-list.ahk
#Include components\guest-profile-details.ahk
#Include components\sent-posts.ahk
#Include components\settings.ahk
#Include components\db-selector.ahk
; macros
#Include macros\fill-in.ahk
#Include macros\fill-psb.ahk
#Include macros\waterfall.ahk

class ProfileModifyNext {
    static name := "ProfileModifyNext"
    static title := "Flow Mode - " . this.name
    static popupTitle := "ClipFlow - " . this.name
    static identifier := "04047fce826f48f751891b4721f7ac70" ; MD5 hash: ProfileModifyNext
    static usingDB := signal("uncDB")

    static USE(App) {
        dbConfig := CONFIG.read("dbConfig")

        this.uncDB := {
            name: "uncDB",
            main: dbConfig["host"] . dbConfig["main"],
            archive: dbConfig["host"] . dbConfig["archive"],
            backup: dbConfig["host"] . dbConfig["backup"],
        }

        this.localDB := {
            name: "localDB",
            main: "c:\ClipFlow\db\GuestProfilesDB\GuestProfiles",
            archive: "c:\ClipFlow\db\GuestProfilesDB\GuestProfilesArchive",
            backup: "c:\ClipFlow\db\GuestProfilesBackup",
        }

        ; initialize db
        try {
            this.db := useFileDB(this.uncDB)
        }
        catch {
            this.db := useFileDB(this.localDB)
            this.usingDB.set("localDB")
        }
        effect(this.usingDB, newUsingDB => this.db := useFileDB(this.%newUsingDB%))

        ; create archive on launch
        yesterday := A_Now.yesterday().toFormat("yyyyMMdd")
        if (!FileExist(this.db.archive . "\" . yesterday . " - archive.json")) {
            this.db.createArchive(yesterday)
        }

        ; add ws message listener
        clbListeners.addListener({
            description: "离线证件读取",
            isOn: true,
            type: "module",
            callback: (*) => WSMessageParser.capture(WSMessageParser.identifier)
        })

        ; mount module component
        PMN_App(App, this.title, this.db, this.identifier)
    }
}