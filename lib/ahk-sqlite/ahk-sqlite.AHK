class SQLite {
    ; Result codes
    static OK := 0
    static ERROR := 1
    static ROW := 100
    static DONE := 101
    static CONSTRAINT := 19

    ; Special destructor argument
    static TRANSIENT := -1

    ; SQLite data types
    static INTEGER := 1
    static FLOAT := 2
    static TEXT := 3
    static BLOB := 4
    static NULL := 5

    ; Open flags
    static OPEN_READONLY := 0x00000001
    static OPEN_READWRITE := 0x00000002
    static OPEN_CREATE := 0x00000004

    /**
     * 
     * @param { {
     *  dll: String,
     *  dbPath: ":memory:" | String,
     *  retentionDays: Number
     * } } config 
     */
    __New(config) {
        this.DLL := config.dll
        this.dbPath := config.dbPath
        this.retentionDays := config.HasOwnProp("retentionDays") ? config.retentionDays : 180

        buf := Buffer(A_PtrSize, 0)

        ; Create UTF-8 null-terminated string
        pathBuf := Buffer(StrPut(this.dbPath, "UTF-8"))
        StrPut(this.dbPath, pathBuf, "UTF-8")

        rc := DllCall(
            this.DLL . "\sqlite3_open",
            "Ptr", pathBuf.Ptr,
            "Ptr", buf.Ptr,
            "CDecl Int"
        )

        this.db := NumGet(buf, 0, "Ptr")

        if (rc != 0) {
            throw Error("sqlite3_open failed: " . rc)
        }

        if (!this.db) {
            throw Error("sqlite3_open returned a NULL database handle.")
        }
    }

    close() {
        if (!this.db) {
            return
        }

        rc := DllCall(
            this.DLL . "\sqlite3_close",
            "Ptr", this.db,
            "Int"
        )

        if (rc != 0) {
            throw Error("sqlite3_close failed: " . rc)
        }

        this.db := 0
    }

    errMsg() {
        return DllCall(
            this.DLL . "\sqlite3_errmsg",
            "Ptr", this.db,
            "AStr"
        )
    }

    exec(sql) {
        errorMessage := 0

        rc := DllCall(
            this.DLL . "\sqlite3_exec",
            "Ptr", this.db,
            "AStr", sql,
            "Ptr", 0,
            "Ptr", 0,
            "Ptr*", &errorMessage,
            "CDecl Int"
        )

        if (rc != 0) {
            message := errorMessage
                ? StrGet(errorMessage, "UTF-8")
                : this.errMsg()

            if (errorMessage) {
                DllCall(
                    this.DLL . "\sqlite3_free",
                    "Ptr", errorMessage
                )
            }

            throw Error("SQLite exec failed (" . rc . "): " . message)
        }

        return rc
    }

    prepare(sql) {
        buf := Buffer(A_PtrSize, 0)

        rc := DllCall(
            this.DLL . "\sqlite3_prepare_v2",
            "Ptr", this.db,
            "AStr", sql,
            "Int", -1,
            "Ptr", buf.Ptr,
            "Ptr", 0,
            "CDecl Int"
        )

        stmt := NumGet(buf, 0, "Ptr")

        if (rc != 0) {
            throw Error("sqlite3_prepare_v2 failed (" . rc . "): " . this.errMsg())
        }

        if (!stmt) {
            throw Error("sqlite3_prepare_v2 returned a NULL statement.")
        }

        return stmt
    }

    finalize(stmt) {
        if (!stmt) {
            return
        }

        rc := DllCall(
            this.DLL . "\sqlite3_finalize",
            "Ptr", stmt,
            "CDecl Int"
        )

        return rc
    }


    step(stmt) {
        rc := DllCall(
            this.DLL . "\sqlite3_step",
            "Ptr", stmt,
            "CDecl Int"
        )

        return rc
    }

    bindText(stmt, index, value) {
        buf := Buffer(StrPut(value, "UTF-8"), 0)

        StrPut(value, buf, "UTF-8")

        rc := DllCall(
            this.DLL . "\sqlite3_bind_text",
            "Ptr", stmt,
            "Int", index,
            "Ptr", buf.Ptr,
            "Int", -1,
            "Ptr", -1,
            "CDecl Int"
        )

        if (rc != SQLite.OK) {
            throw Error("sqlite3_bind_text failed: " . rc)
        }
    }

    bindInt(stmt, index, value) {
        rc := DllCall(
            this.DLL . "\sqlite3_bind_int",
            "Ptr", stmt,
            "Int", index,
            "Int", value,
            "CDecl Int"
        )

        if (rc != 0) {
            throw Error("sqlite3_bind_int failed: " . rc)
        }
    }

    bindInt64(stmt, index, value) {
        rc := DllCall(
            this.DLL . "\sqlite3_bind_int64",
            "Ptr", stmt,
            "Int", index,
            "Int64", value,
            "CDecl Int"
        )

        if (rc != 0) {
            throw Error("sqlite3_bind_int64 failed: " . rc)
        }
    }

    bindNull(stmt, index) {
        rc := DllCall(
            this.DLL . "\sqlite3_bind_null",
            "Ptr", stmt,
            "Int", index,
            "CDecl Int"
        )

        if (rc != 0) {
            throw Error("sqlite3_bind_null failed: " . rc)
        }
    }

    reset(stmt) {
        rc := DllCall(
            this.DLL . "\sqlite3_reset",
            "Ptr", stmt,
            "CDecl Int"
        )

        if (rc != 0) {
            throw Error("sqlite3_reset failed: " . rc)
        }
    }

    columnType(stmt, index) {
        return DllCall(
            this.DLL . "\sqlite3_column_type",
            "Ptr", stmt,
            "Int", index,
            "CDecl Int"
        )
    }

    columnText(stmt, index) {
        ptr := DllCall(
            this.DLL . "\sqlite3_column_text",
            "Ptr", stmt,
            "Int", index,
            "CDecl Ptr"
        )

        if (!ptr) {
            return ""
        }

        return StrGet(ptr, "UTF-8")
    }

    columnInt(stmt, index) {
        return DllCall(
            this.DLL . "\sqlite3_column_int",
            "Ptr", stmt,
            "Int", index,
            "CDecl Int"
        )
    }

    columnInt64(stmt, index) {
        return DllCall(
            this.DLL . "\sqlite3_column_int64",
            "Ptr", stmt,
            "Int", index,
            "CDecl Int64"
        )
    }
}