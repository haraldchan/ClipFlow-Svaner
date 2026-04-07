class useServerAgent {
    __New(serverSettings) {
        s := useProps(serverSettings, {
            pool: "",
            interval: 3000,
            expiration: 480,
            collectRange: 15,
            safePost: false,
            isListening: "",
        })

        /** @type {String} post pool dir */
        this.pool := s.pool

        /** @type {Integer} collect interval in ms */
        this.interval := s.interval
        
        /** @type {Integer} post deletion period in min */
        this.expiration := s.expiration
        
        /** @type {Integer} collect post range in min */
        this.collectRange := s.collectRange
        
        /** @type {true | false} whether ping before sending a post */
        this.safePost := s.safePost

        /** @type {signal | ""} isListening depend signal */
        this.isListening := s.isListening

        /** @type {String} reponder script filename */
        this.responder := ""

        if (!DirExist(this.pool)) {
            DirCreate(this.pool)
        }
    }

    /**
     * Updates post status
     * @param {String} postPath full post json file path
     * @param {String} newStatus updated status
     * @returns {{ header: { status: String, sender: String, id: String }, err: 0 | Error }} 
     */
    updatePostStatus(postPath, newStatus) {
        curHeader := postPath.split("\").at(-1).replace(".json", "").split("==")
        updatedPostHeader := 0
        err := 0

        try {
            FileMove(postPath, postPath.replace(curHeader[1], newStatus), true)
            updatedPostHeader := {
                status: newStatus,
                sender: curHeader[2],
                id: curHeader[3]
            }
        } 
        catch Error as err {
            ; if (USE_ERROR_LOG) {
            ;     logError(err)
            ; }
        }

        return {
            header: updatedPostHeader, 
            err: err
        }
    }

    /**
     * Creates/changes service status
     * @param {true | false} on on/off flag
     */
    setOnlineStatus(on) {
        if (!FileExist(this.pool . "\OFFLINE.flag")) {
            FileAppend(A_ComputerName, this.pool . "\OFFLINE.flag", "utf-8")
        }

        if (on) {
            if (FileExist(this.pool . "\ONLINE.flag")) {
                return
            }
            FileMove(this.pool . "\OFFLINE.flag", this.pool . "\ONLINE.flag", true)
        }
        else {
            FileMove(this.pool . "\ONLINE.flag", this.pool . "\OFFLINE.flag", true)
                
            DetectHiddenWindows(true)
            if (WinExist(this.responder . ".ahk")) {
                WinKill(this.responder . ".ahk")
            }
        }
    }

    /**
     * Creates a responder script and runs it
     * @param {String} selfIncludePath filepath of lib
     * @param {String} scriptName filename of responder script
     */
    spawnResponder(selfIncludePath, scriptName) {
        this.responder := scriptName
        responderFilePath := this.pool . "\" . scriptName . ".ahk"
        scriptContent := Format("
            (
                #Requires AutoHotkey v2.0
                #SingleInstance Force
                #Include {1}

                responder := useServerAgent({ pool: "{2}" })
                SetTimer(ObjBindMethod(responder, "RESPONSE"), 3000)
            )", 
            selfIncludePath,
            this.pool
        )
        if (!FileExist(responderFilePath)) {
            FileAppend(scriptContent, responderFilePath, "utf-8")
        }

        Run(responderFilePath)
    }

    PING() {
        ; send
        message := { method: "PING", sender: A_ComputerName, id: A_Now . A_MSec . Random(1, 100) }
        filename := Format("{1}\{2}=={3}=={4}.json", this.pool, message.method, message.sender, message.id)
        resMatcher := this.pool . "\*" . message.id . "*.json"
        FileAppend(JSON.stringify(message), filename, "UTF-8")
        
        ; wait for response
        loop {
            loop files, this.pool . "\*.json" {
                if (InStr(A_LoopFileName, message.id) && InStr(A_LoopFileName, "ONLINE")) {
                    responsedHeader := StrSplit(A_LoopFileName, "==")
                    FileDelete(A_LoopFileFullPath)
                    return {
                        method: responsedHeader[1],
                        sender: responsedHeader[2],
                        id: responsedHeader[3]
                    }
                } 
            }

            Sleep(1000)
            ; response timeout
            if(A_Index > (this.interval / 1000 * 3 * 3)) {
                try {
                    FileDelete(filename)
                }
                return false
            }
        }
    }

    /**
     * 
     * @returns {String} 
     */
    RESPONSE() {
        loop files, this.pool . "\*.json" {
            if (InStr(A_LoopFileName, "PING")) {
                header := StrSplit(A_LoopFileName, "==")
                responseHeader := Format("{}=={}=={}", "ONLINE", A_ComputerName, header[3])
                try {
                    FileMove(
                        A_LoopFileFullPath, 
                        StrReplace(A_LoopFileFullPath, A_LoopFileName, responseHeader),
                        true
                    )
                }

                return responseHeader
            }
        }
    }

    /**
     * <Client> Post to pool
     * @param {Object} content 
     */
    POST(content, pool := this.pool) {
        if (this.safePost) {
            if (!FileExist(this.pool . "\ONLINE.flag")) {
                MsgBox("Service offline.",, "4096 T2")
                return false
            }
        }

        message := {
            id: A_Now . A_MSec . Random(100, 999),
            method: "POST",
            sender: A_ComputerName,
            content: content
        }

        filename := Format("{1}\{2}=={3}=={4}.json", pool, "PENDING", A_ComputerName, message.id)
        FileAppend(JSON.stringify(message), filename, "UTF-8")

        return message
    }

    /**
     * @typedef {Object} CollectedPost
     * @property {String} name file name
     * @property {String} path file fullpath
     * @property {String} timeCreated file created time in YYYYMMDDHH24MISS
     */
    /**
     * <Server> Collect posts
     * @param {String} method 
     * @returns {Array<CollectedPost>}
     */
    COLLECT(status, pool := this.pool) {
        posts := []
        loop files (pool . "\*.json") {
            postTimestamp := A_LoopFileName.split("==")[3].substr(1, 14)
            if (DateDiff(A_Now, postTimestamp, "Minutes") >= this.collectRange && A_LoopFileName.includes(status)) {
                this.updatePostStatus(A_LoopFileFullPath, "ABANDONED")
                continue
            }

            if (InStr(A_LoopFileFullPath, status)) {
                this.updatePostStatus(A_LoopFileFullPath, "COLLECTED")
                posts.Push({
                    name: A_LoopFileName,
                    path: StrReplace(A_LoopFileFullPath, status, "COLLECTED"),
                    timeCreated: A_LoopFileTimeCreated
                })
            }
        }

        return posts
    }
}
