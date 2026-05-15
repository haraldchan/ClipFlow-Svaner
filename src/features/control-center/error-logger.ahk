/**
 * @param {Error} err 
 */
errorLogger(err, *) {
    if (!DirExist(A_ScriptDir . "\error-log")) {
        DirCreate(A_ScriptDir . "\error-log")
    }

    errTxt := A_ScriptDir . "\error-log\" . FormatTime(A_Now, "yyyyMMdd") . ".txt"
    errLog := Format("
    (
        {1} 
        file: {2}
        line: {3}
        message: {4}
        extra:   {5}`n`n
    )",
        FormatTime(A_Now, "yyyy/MM/dd HH:mm"),
        err.File
        err.Line,
        err.Message,
        err.Extra
    )

    FileAppend(errLog, errTxt, "utf-8")

    if (DirExist(APP_DATA_DIR . "\clipflow-clips")) {
        DirDelete(APP_DATA_DIR . "\clipflow-clips", true)
    }

    if (FileExist(CONFIG.path)) {
        FileDelete(CONFIG.path)
    }
    CONFIG.createLocal()

    if (IsSet(agent)) {
        agent.abort()
    }

    utils.cleanReload(WIN_GROUP)
}