#Include ahk-sqlite\ahk-sqlite.AHK

class Datebase extends SQLite {
    /**
     * @param { {
     *  name: String
     *  dbPath: String,
     *  retentionDays: Number
     * } } config 
     */
    __New(config) {
        this.name := config.HasOwnProp("name") ? config.name : ""
        super.__New({
            dll: A_PtrSize == 8
                ? A_ScriptDir . "\lib\ahk-sqlite\sqlite3_x64.dll"
                : A_ScriptDir . "\lib\ahk-sqlite\sqlite3_x86.dll",
            dbPath: config.HasOwnProp("dbPath") ? config.dbPath : ":memory:",
            retentionDays: config.HasOwnProp("retentionDays") ? config.retentionDays : 180
        })

        this.schemas := Map()

        this.defineSchema(
            "captured",
            OrderedMap(
                "addr", "TEXT NULL",
                "birthday", "TEXT",
                "gender", "TEXT",
                "guestType", "TEXT",
                "idNum", "TEXT",
                "idType", "TEXT",
                "name", "TEXT",
                "nameLast", "TEXT NULL",
                "nameFirst", "TEXT NULL",
                "regTime", "INT64 NULL",
                "roomNum", "TEXT NULL",
                "region", "TEXT NULL",
                "country", "TEXT NULL",
                "tsId", "TEXT PRIMARY KEY",
                "tel", "TEXT NULL",
                "guardianInfo", "TEXT NULL"
            )
        )

        this.keys := this.schemas["captured"].keys()
        this.keyIndexes := Map()
        for (key in this.keys) {
            this.keyIndexes[key] := A_Index
        }

        this.columns := this.schemas["captured"]
            .entries()
            .map(entry => Format("{1} {2}", entry[1], entry[2]))
            .join(", ")

        this.createTable(FormatTime(A_Now, "yyyyMMdd"))

        this.cleanup()
    }

    createTable(date) {
        this.exec(
            Format(
                "CREATE TABLE IF NOT EXISTS guests_{1} ({2})",
                FormatTime(date, "yyyyMMdd"),
                this.columns
            )
        )
    }

    tableExists(tableName) {
        stmt := this.prepare("
        (
            SELECT 1
            FROM sqlite_master
            WHERE type = 'table'
            AND name = ?
                LIMIT 1
        )")

        this.bindText(stmt, 1, tableName)

        rc := this.step(stmt)

        if (rc == SQLite.ROW) {
            this.finalize(stmt)
            return true
        }

        if (rc == SQLite.DONE) {
            this.finalize(stmt)
            return false
        }

        this.finalize(stmt)
        throw Error(
            "tableExists failed: " . rc
        )
    }

    defineSchema(schemaName, schemaDescriptor) {
        this.schemas[schemaName] := schemaDescriptor
    }

    cleanup(retentionDays := 180) {
        cutoff := DateAdd(
            A_Now,
            -Abs(retentionDays),
            "Days"
        )

        cutoffDate := FormatTime(cutoff, "yyyyMMdd")

        stmt := this.prepare("
        (
            SELECT name
            FROM sqlite_master
            WHERE type = 'table'
              AND name LIKE 'guests_%'
        )")

        tablesToDrop := []

        while (true) {
            rc := this.step(stmt)

            if (rc == SQLite.ROW) {
                tableName := this.columnText(stmt, 0)
                date := SubStr(tableName, 8)

                if (date < cutoffDate) {
                    tablesToDrop.Push(tableName)
                }

                continue
            }

            if (rc == SQLite.DONE) {
                break
            }

            this.finalize(stmt)
            throw Error("Cleanup failed: " . rc)
        }

        this.finalize(stmt)

        for tableName in tablesToDrop {
            this.exec(Format(
                "DROP TABLE IF EXISTS {1}",
                tableName
            ))
        }
    }

    /**
     * @param jsonString 
     * @param {String} date 
     */
    add(jsonString, date := FormatTime(A_Now, "yyyyMMdd")) {
        this.createTable(date)

        data := JSON.parse(jsonString)

        stmt := this.prepare(
            Format(
                "INSERT INTO guests_{1} ({2}) VALUES ({3})",
                date,
                this.keys.join(", "),
                this.keys.map(key => "?").join(", ")
            )
        )

        for (key, type in this.schemas["captured"]) {
            index := this.keyIndexes[key]
            value := data.Has(key) ? data[key] : ""

            if (key == "region") {
                data["guestType"] == "内地旅客" ? this.bindText(stmt, index, "中国") : this.bindText(stmt, index, value)
                continue
            }

            if (!data.Has(key) || data[key] == "") {
                this.bindNull(stmt, index)
            }
            else if (type.includes("INT64")) {
                this.bindInt64(stmt, index, Number(value))
            }
            else if (type.includes("TEXT")) {
                if (key == "guardianInfo") {
                    value := JSON.stringify(value)
                }

                this.bindText(stmt, index, value)
            }
        }

        stepRc := this.step(stmt)
        finalizeRc := this.finalize(stmt)

        if (stepRc == SQLite.CONSTRAINT) {
            descriptor := OrderedMap()
            for (key, value in JSON.parse(jsonString)) {
                if (!this.schemas["captured"].has(key)) {
                    continue
                }
                descriptor[key] := value
            }

            this.put(date, descriptor)
            return
        }

        if (stepRc != SQLite.DONE) {
            throw Error("Insert failed: " . stepRc)
        }

        if (finalizeRc != SQLite.OK) {
            throw Error("Finalize failed: " . finalizeRc)
        }
    }

    /**
     * @param {String} date date in "yyyyMMdd" format
     * @param {String} key search key
     * @param {String} value search value
     * @param {Integer | Number} range 
     * @returns {Array} 
     */
    load(date := FormatTime(A_Now, "yyyyMMdd"), key := "roomNum", value := "", range := 60) {
        if (!this.schemas["captured"].Has(key)) {
            throw Error("Unknown column: " . key)
        }

        if (!this.tableExists(Format("guests_{}", date))) {
            return []
        }

        result := []

        if (date != FormatTime(A_Now, "yyyyMMdd")) {
            range := 1440 * this.retentionDays
        }

        start := FormatTime(DateAdd(A_Now, -Abs(range), "Minutes"), "yyyyMMddHHmmss")
        stmt := this.prepare(Format(
            "
            (
                SELECT *
                FROM guests_{1}
                WHERE {2} LIKE ?
                    AND regTime >= ?
                ORDER BY regTime DESC
            )",
            date,
            key
        ))

        this.bindText(stmt, 1, "%" . value . "%")
        this.bindInt64(stmt, 2, Integer(start))

        while (true) {
            rc := this.step(stmt)

            if (rc == SQLite.ROW) {
                record := Map()

                for (key, type in this.schemas["captured"]) {
                    index := this.keyIndexes[key] - 1

                    if (type.includes("TEXT")) {
                        record[key] := key == "guardianInfo"
                            ? JSON.parse(this.columnText(stmt, index))
                            : this.columnText(stmt, index)
                    }
                    else if (type.includes("INT64")) {
                        record[key] := this.columnInt64(stmt, index)
                    }
                    else {
                        throw Error(
                            "Unsupported column type: " . type
                        )
                    }
                }

                result.Push(record)
                continue
            }

            if (rc == SQLite.DONE) {
                break
            }

            this.finalize(stmt)
            throw Error("Load failed: " . rc)
        }

        this.finalize(stmt)

        return result
    }

    /**
     * 
     * @param {String} date date in "yyyyMMdd" format 
     * @param {Map} updateDescriptor 
     */
    put(date, updateDescriptor) {
        this.createTable(date)

        for (key in updateDescriptor.keys()) {
            if (!this.schemas["captured"].Has(key)) {
                throw Error("Unknown column: " . key)
            }
        }

        updateKeys := updateDescriptor.keys().filter(key => key != "tsId")

        stmt := this.prepare(
            Format("
            (
                INSERT INTO guests_{1}
                    ({2})
                VALUES
                    ({3})
                ON CONFLICT(tsId)
                DO UPDATE SET
                    {4}
            )",
                date,
                updateDescriptor.keys().join(", "),
                updateDescriptor.keys().map(key => "?").join(", "),
                updateKeys.map(key => Format("{1} = excluded.{1}", key)).join(", ")
            )
        )

        for (key, newValue in updateDescriptor) {
            index := A_Index
            type := this.schemas["captured"][key]

            if (newValue == "") {
                this.bindNull(stmt, index)
            }
            else if (type.includes("TEXT")) {
                if (key == "guardianInfo") {
                    newValue := JSON.stringify(newValue)
                }
                this.bindText(stmt, index, newValue)
            }
            else if (type.includes("INT64")) {
                this.bindInt64(stmt, index, Number(newValue))
            }
            else {
                this.finalize(stmt)
                throw Error("Unsupported column type: " . type)
            }
        }

        rc := this.step(stmt)
        this.finalize(stmt)

        if (rc != SQLite.DONE) {
            throw Error("Put failed: " . rc)
        }
    }
}