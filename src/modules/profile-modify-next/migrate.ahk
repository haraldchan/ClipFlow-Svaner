/**
 * @param {()=>Datebase} db 
 */
MigrateHelper(db) {
    Win := Svaner({
        gui: {
            title: "PMN Settings"
        },
        font: {
            name: "微软雅黑"
        },
        events: {
            close: handleWinClose,
        }
    })

    handleWinClose(*) {
        Win.Destroy()
    }

    dbConfig := CONFIG.read("dbConfig")
    onDayDir := dbConfig["host"] . "\" . dbConfig["main"]
    archiveDir := dbConfig["host"] . "\" . dbConfig["archive"]

    archivedProfiles := []
    archivedProfileCount := 0
    loop files (archiveDir . "\*.json") {
        curDay := JSON.parse(FileRead(A_LoopFilePath, "utf-8"))
        archivedProfileCount += curDay.Length
        archivedProfiles.Push(Map(
            A_LoopFileName.replace(" - archive.json", ""),
            curDay
        ))
    }

    onDayProfiles := []
    onDayProfileCount := 0
    curDay := FormatTime(A_Now, "yyyyMMdd")
    loop files (onDayDir . "\" . curDay . "\*.json") {
        onDayProfiles.Push(JSON.parse(FileRead(A_LoopFileFullPath, "utf-8")))
        onDayProfileCount++
    }


    handleMigration(ctrl, _) {
        if (ctrl.Name.includes("archive")) {
            for (dayArc in archivedProfiles) {
                for (date, profiles in dayArc) {
                    for (profile in profiles) {
                        profile["tsId"] := utils.newGuid()
                        db().add(JSON.stringify(profile), date)
                        Win["archive-progress"].Value++
                    }
                }
            }
        }
        else {
            for (profile in onDayProfiles) {
                profile["tsId"] := utils.newGuid()
                db().add(JSON.stringify(profile))
                Win["onday-progress"].Value++
            }
        }
    }


    render() {
        StackBox(Win, {
            name: "migrate-archive-stackbox",
            font: { options: "bold" },
            groupbox: {
                title: "迁移 Archive",
                options: "Section x10 w280 h85"
            }
        },
            () => [
                Win.AddButton("vmigrate-archive-btn xs10 yp+25 w260 h30", Format("开始迁移已存档 Profile({})", archivedProfileCount))
                   .onClick(handleMigration),
                Win.gui.AddProgress("varchive-progress xs10 yp+40 w260 h10 c4592D8 BackgroundD6DEE8 " . Format("range1-{}", archivedProfileCount))
            ]
        )
        StackBox(Win, {
            name: "migrate-onday-stackbox",
            font: { options: "bold" },
            groupbox: {
                title: "迁移 On-Day",
                options: "Section x10 w280 h85"
            }
        },
            () => [
                Win.AddButton("vmigrate-onday-btn xs10 yp+25 w260 h30", Format("开始迁移当天保存 Profile({})", onDayProfileCount))
                   .onClick(handleMigration),
                Win.gui.AddProgress("vonday-progress xs10 yp+40 w260 h10 c4592D8 BackgroundD6DEE8 " . Format("range1-{}", onDayProfileCount))
            ]
        )
    }

    return (
        render(),
        Win.Show()
    )
}