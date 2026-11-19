class ClipDB extends SQLite {
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
                ? A_AppData . "\ClipFlow\sqlite\sqlite3_x64.dll"
                : A_AppData . "\ClipFlow\sqlite\sqlite3_x86.dll",
            dbPath: config.HasOwnProp("dbPath") ? config.dbPath : ":memory:",
        })
        this.retentionCount := config.retentionCount

        this.schemas := Map()

        this.defineSchema(
            "clip",
            OrderedMap(
                "type", "TEXT",
                "text", "TEXT PRIMARY KEY",
                "content", "BLOB",
                "createdAt", "TEXT"
            )
        )

        this.keys := this.schemas["clip"].keys()
        this.keyIndexes := Map()
        for (key in this.keys) {
            this.keyIndexes[key] := A_Index
        }

        this.columns := this.schemas["clip"]
            .entries()
            .map(entry => Format("{1} {2}", entry[1], entry[2]))
            .join(", ")

        this.createTable()

        this.cleanup(this.retentionCount)
    }

    /**
     * @param {String} schemaName 
     * @param {Map} schemaDescriptor 
     */
    defineSchema(schemaName, schemaDescriptor) {
        this.schemas[schemaName] := schemaDescriptor
    }

    cleanup(retentionCount) {
        stmt := this.prepare("
        (
            DELETE FROM clips
            WHERE rowid NOT IN (
                SELECT rowid
                FROM clips
                ORDER BY createdAt DESC, rowid DESC
                LIMIT ?)
        )")

        this.bindInt(stmt, 1, retentionCount)

        result := this.step(stmt)
        this.finalize(stmt)

        return result
    }

    /**
     * Creates table with name `clips`
     */
    createTable() {
        this.exec(
            Format(
                "CREATE TABLE IF NOT EXISTS clips ({1})",
                this.columns
            )
        )
    }

    /**
     * Checks if a table exists.
     * @returns {true | false | Error} 
     */
    tableExists() {
        stmt := this.prepare("
        (
            SELECT 1
            FROM sqlite_master
            WHERE type = 'table'
            AND name = ?
                LIMIT 1
        )")

        this.bindText(stmt, 1, "clips")

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
        return Error("tableExists failed: " . rc, -1, rc)
    }

    /**
     * Add record to db
     * @param {String} jsonString 
     * @param {String} date 
     * @returns {"added" | "put" | Error} 
     */
    add(data) {
        this.createTable()

        loop {
            stmt := this.prepare(
                Format(
                    "INSERT INTO clips ({1}) VALUES ({2})",
                    this.keys.join(", "),
                    this.keys.map(key => "?").join(", ")
                )
            )

            for (key, type in this.schemas["clip"]) {
                index := this.keyIndexes[key]

                if (key == "content") {
                    this.bindBlob(stmt, index, data.%key%)
                }
                else {
                    this.bindText(stmt, index, data.%key%)
                }

            }

            stepRc := this.step(stmt)
            finalizeRc := this.finalize(stmt)

            if (stepRc == SQLite.BUSY) {
                if (A_Index < 6) {
                    Sleep(100)
                    continue
                }

                return Error("Database remained busy after retry", -1, stepRc)
            }

            break
        }

        if (stepRc == SQLite.CONSTRAINT) {
            descriptor := OrderedMap()
            for (key, value in data.OwnProps()) {
                if (!this.schemas["clip"].has(key)) {
                    continue
                }
                descriptor[key] := value
            }

            return this.put(descriptor)
        }

        if (stepRc != SQLite.DONE) {
            return Error("Insert failed: " . stepRc, -1, stepRc)
        }

        if (finalizeRc != SQLite.OK) {
            return Error("Finalize failed: " . finalizeRc, -1, finalizeRc)
        }

        this.cleanup(this.retentionCount)

        return "added"
    }

    /**
     * Loads data from db.
     * @param {String} date date in "yyyyMMdd" format
     * @param {String} key search key
     * @param {String} value search value
     * @param {Integer | Number} range 
     * @returns {Array<Map> | Error} 
     */
    load() {
        if (!this.tableExists()) {
            return []
        }

        result := []

        stmt := this.prepare("SELECT * FROM clips ORDER BY createdAt DESC")

        while (true) {
            rc := this.step(stmt)

            if (rc == SQLite.ROW) {
                record := {}

                for (key, type in this.schemas["clip"]) {
                    index := this.keyIndexes[key] - 1
                    if (type.includes("TEXT")) {
                        record.%key% := this.columnText(stmt, index)
                    }
                    else {
                        record.%key% := this.columnBlob(stmt, index)
                    }
                }

                result.Push(record)
                continue
            }

            if (rc == SQLite.DONE) {
                break
            }

            this.finalize(stmt)
            return Error("Load failed: " . rc, -1, rc)
        }

        this.finalize(stmt)

        return result
    }

    /**
     * Updates data in db
     * @param {String} date date in "yyyyMMdd" format 
     * @param {Map} updateDescriptor 
     * @param {true | false} ignoreUnknownColumn ignores unknown column instead of returning error
     * @returns {"put" | Error}
     */
    put(updateDescriptor) {
        stmt := this.prepare(
            Format("
            (
                INSERT INTO clips
                    ({})
                VALUES
                    ({})
                ON CONFLICT(text)
                DO UPDATE SET
                    {}
            )",
                updateDescriptor.keys().join(", "),
                updateDescriptor.keys().map(key => "?").join(", "),
                updateDescriptor.keys().map(key => Format("{1} = excluded.{1}", key)).join(", ")
            )
        )

        for (key, newValue in updateDescriptor) {
            index := A_Index
            type := this.schemas["clip"][key]

            if (key == "content") {
                this.bindBlob(stmt, index, newValue)
            }
            else {
                this.bindText(stmt, index, newValue)
            }
        }

        rc := this.step(stmt)
        this.finalize(stmt)

        if (rc != SQLite.DONE) {
            return Error("Put failed: " . rc, -1, type)
        }

        return "put"
    }
}