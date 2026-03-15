class useServerAgent {
    __New(serverSettings) {
        s := useProps(serverSettings, {
            pool: "",         ; post pool dir path
            interval: 3000,   ; post checking interval MILLISECONDS
            expiration: 480,  ; delete posts after (exp) MINUTES
            collectRange: 15, ; collect post from recent MINUTES
            safePost: false,  ; whether ping before sending a post
            isListening: ""   ; isListening depend signal
        })

        this.pool := s.pool
        this.interval := s.interval
        this.expiration := s.expiration
        this.collectRange := s.collectRange
        this.safePost := s.safePost
        this.isListening := s.isListening
        this.respondentFileName := ""

        if (!DirExist(this.pool)) {
            DirCreate(this.pool)
        }
    }

    updatePostStatus(postPath, newStatus) {
        curHeader := postPath.split("\").at(-1).replace(".json", "").split("==")
        updatedPostHeader := 0
        err := 0

        try {
            FileMove(postPath, postPath.replace(curHeader[1], newStatus))
            updatedPostHeader := {
                status: newStatus,
                sender: curHeader[2],
                id: curHeader[3]
            }
        } catch Error as e {
            err := e

            errLogLine := Format("Time:{1} PostHeader:{2} Error:{3}`r`n", A_Now, curHeader.join("=="), e)

            FileAppend(errLogLine, A_ScriptDir . "\src\Servers\error-log.txt", "UTF-8")
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
        if (!FileExist(this.pool . "\OFFLINE")) {
            FileAppend("OFFLINE", this.pool . "\OFFLINE")
        }

        if (on) {
            if (FileExist(this.pool . "\ONLINE")) {
                return
            }
            FileMove(this.pool . "\OFFLINE", this.pool . "\ONLINE", true)
        }
        else {
            FileMove(this.pool . "\ONLINE", this.pool . "\OFFLINE", true)
                
            DetectHiddenWindows(true)
            if (WinExist(this.respondent . ".ahk")) {
                WinKill(this.respondent . ".ahk")
            }
            FileDelete(this.pool . "\" . this.respondent . ".ahk")
        }
    }

    /**
     * Creates a respondent script and runs it
     * @param {String} selfIncludePath filepath of lib
     * @param {String} scriptName filename of respondent script
     */
    spawnRespondent(selfIncludePath, scriptName) {
        this.respondent := scriptName
        respondentFilePath := this.pool . "\" . scriptName . ".ahk"
        scriptContent := Format("
            (
                #Requires AutoHotkey v2.0
                #SingleInstance Force
                #Include {1}

                respondent := useServerAgent({ pool: "{2}" })
                SetTimer(ObjBindMethod(respondent, "RESPONSE"), 3000)
            )", 
            selfIncludePath,
            this.pool
        )
        if (FileExist(respondentFilePath)) {
            FileDelete(respondentFilePath)
        }

        FileAppend(scriptContent, respondentFilePath, "utf-8")
        Run(respondentFilePath)
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

            Sleep 1000
            ; response timeout
            if(A_Index > (this.interval / 1000 * 3 * 3)) {
                try {
                    FileDelete(filename)
                }
                return false
            }
        }
    }

    RESPONSE() {
        loop files, this.pool . "\*.json" {
            if (InStr(A_LoopFileName, "PING")) {
                header := StrSplit(A_LoopFileName, "==")
                responseHeader := Format("{}=={}=={}", "ONLINE", A_ComputerName, header[3])
                try {
                    FileMove(
                        A_LoopFileFullPath, 
                        StrReplace(A_LoopFileFullPath, A_LoopFileName, responseHeader)
                    )
                }

                return responseHeader
            }
        }
    }

    /**
     * <client> Post to pool
     * @param {Object} content 
     */
    POST(content, pool := this.pool) {
        if (this.safePost) {
            if (!this.PING()) {
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
     * <server> Collect posts
     * @param {String} method 
     * @returns {string[]} post filepaths array
     */
    COLLECT(status, pool := this.pool) {
        posts := []
        loop files (pool . "\*.json") {
            ; postTimestamp := SubStr(StrSplit(A_LoopFileName, "==")[3], 1, 14)
            postTimestamp := A_LoopFileName.split("==")[3].substr(1, 14)
            if (DateDiff(A_Now, postTimestamp, "Minutes") >= this.collectRange && A_LoopFileName.includes(status)) {
                this.updatePostStatus(A_LoopFileFullPath, "ABANDONED")
                continue
            }

            if (InStr(A_LoopFileFullPath, status)) {
                this.updatePostStatus(A_LoopFileFullPath, "COLLECTED")
                posts.Push(StrReplace(A_LoopFileFullPath, status, "COLLECTED"))
            }
        }

        return posts
    }
}