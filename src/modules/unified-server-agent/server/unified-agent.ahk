class UnifiedAgent extends useServerAgent {
    __New(serverSettings) {
        super.__New(serverSettings)
        this.qmPool := serverSettings.HasOwnProp("qmPool") ? serverSettings.qmPool : ""
        this.popupTitle := "Unified Agent"

        ; toggle listening status. this needs to be async due to blocking loop when listening is on.
        effect(this.isListening, cur => SetTimer(() => this.listen(cur), -100)) 

        ; ongoing post(fullpath of the post json file)
        this.currentHandlingPost := ""

        ; QM2 modules
        this.qmModules := Map(
            "BlankShare", BlankShare_Action,
            "PaymentRelation", PaymentRelation_Action,
            "TransactionEntry", TransactionEntry_Action
        )

        ; delete expired posts
        this.cleanup()
        this.cleanup(this.qmPool)
    }

    cleanup(pool := this.pool) {
        exp := this.expiration
        loop files (pool . "\*.json") {
            header := StrSplit(A_LoopFileName, "==")
            method := header[1]
            date := SubStr(header[3], 1, 14)
            if (DateDiff(A_Now, date, "Minutes") >= exp) {
                FileDelete(A_LoopFileFullPath)
            }
        }
    }

    abort() {
        serverComputerName := ""
        if (FileExist(this.pool . "\ONLINE.flag")) {
            try {
                serverComputerName := FileRead(this.pool . "\ONLINE.flag", "utf-8")
            }

            if (serverComputerName != A_ComputerName) {
                return
            }
        }

        this.setOnlineStatus(false)

        ; prep for restart
        try {
            FileMove(this.pool . "\OFFLINE.flag", this.pool . "\RESTART.flag", true)
        }

        ; change posts status
        this.updatePostStatus(this.currentHandlingPost, "ABORTED")
        this.resetPostsToPending()
        
        ; retart a PMS session
        this.restartPMS()
    }

    /**
     * <Agent>
     */
    blockInput() {
        if (!WinExist(this.popupTitle)) {
            UnifiedAgentModal(() => this.isListening.set("离线"))
        }

        BlockInput(true)
        if (this.isListening.value == "离线") {
            BlockInput(false)
        }
    }

    /**
     * <Agent>
     */
    keepAlive() {
        if (this.isListening.value == "在线") {
            try {
                WinActivate("ahk_class SunAwtFrame")
                Send("!r")
                utils.waitLoading()
            }
        }
    }

    /**
     * <Agent>
     * @param status 
     */
    listen(status) {
        if (status == "在线") {
            if (FileExist(this.pool . "\RESTART.flag")) {
                FileMove(this.pool . "\RESTART.flag", this.pool . "\OFFLINE.flag", true)
            }
            this.setOnlineStatus(true)
            this.spawnResponder(A_ScriptDir . "\lib\index.ahk", "ua-responder")
            loop {
                ; block input
                this.blockInput()

                ; handle post
                this.handlePosts()
                Sleep(this.interval)
            } until (this.isListening.value == "离线")
        }
        else {
            this.setOnlineStatus(false)
        }
    }


    /**
     * <Agent>
     */
    resetPostsToPending() {
        postsToReset := []

        postsToReset.Push(this.COLLECT("COLLECTED", this.qmPool)*)
        postsToReset.Push(this.COLLECT("RETRY", this.qmPool)*)
        postsToReset.Push(this.COLLECT("COLLECTED")*)
        postsToReset.Push(this.COLLECT("RETRY")*)

        for post in postsToReset {
            this.updatePostStatus(post.path, "PENDING")
        }
    }

    /**
     * <Agent>
     */
    restartPMS() {
        if (!WinExist("OPERA Full Service Edition")) {
            return
        }

        PMS_USERNAME := "FOHARALDC"
        PMS_PASSWORD := "sxzc123456"

        ; close all ie win
        loop {
            if (WinExist("OPERA Full Service Edition")) {
                WinKill("OPERA Full Service Edition")
            }
            Sleep(200)
        } until (!WinExist("OPERA Full Service Edition"))

        ie := ComObject("InternetExplorer.Application")
        ie.Visible := true

        ; log-in opera pms
        ie.Navigate("https://wsh-opr-app1")
        while (ie.Busy || ie.ReadyState != 4) {
            Sleep(200)
        }

        document := ie.document
        username := document.getElementsByName("username")[0]
        password := document.getElementsByName("password")[0]

        username.value := PMS_USERNAME
        username.fireEvent("onchange")
        password.value := PMS_PASSWORD
        password.fireEvent("onchange")
        Sleep(10)
        document.getElementsByTagName('button')[0].click()
        utils.waitLoading(500)

        ; update document after log-in
        document := ie.document
        document.getElementById("opera_pms").click()

        ; wait for PMS app
        WinWait("OPERA PMS")
        utils.waitLoading(500)

        WinMaximize("ahk_class SunAwtFrame")
        utils.waitLoading(1000)
        WinActivate("ahk_class SunAwtFrame")
        Sleep(100)
        Send("!f")
        Sleep(100)
        Send("{Down}")
        Sleep(100)
        Send("{Enter}")
        utils.waitLoading(1000)

        ie := ""
    }


    /**
     * <Agent>
     */
    handlePosts() {
        if (!WinExist("ahk_class SunAwtFrame")) {
            MsgBox("后台 Opera PMS 不在线。", POPUP_TITLE, "4096 T1")
            this.isListening.set("离线")
            return
        }

        this.keepAlive()
        ; this.resetPostsToPending()

        qmPosts := this.COLLECT("PENDING", this.qmPool)
        pmnPosts := this.COLLECT("PENDING", this.pool)
        retryPosts := this.COLLECT("RETRY", this.pool)

        if (pmnPosts.Length || qmPosts.Length || retryPosts.Length) {
            WinHide(this.popupTitle)
        }

        if (qmPosts.Length) {
            this.handlePostMacroExecute(qmPosts)
        }

        if (pmnPosts.Length) {
            this.handlePostMacroExecute(pmnPosts)
        }

        if (retryPosts.Length) {
            this.handlePostMacroExecute(retryPosts)
        }

        WinShow(this.popupTitle)
        this.isListening.set("在线")
    }


    /**
     * <Agent>
     * @param {Array<CollectedPost>} posts 
     */
    handlePostMacroExecute(posts) {
        /** @type {Array<CollectedPost>} */
        sortedPosts := posts.sort((a, b) => b.timeCreated - a.timeCreated)

        for post in sortedPosts {
            this.currentHandlingPost := post.path

            read := FileRead(post.path, "utf-8")
            if (!read) {
                this.updatePostStatus(post.path, "ABORTED")
                continue
            }

            unboxedPost := JSON.parse(read)
            if (unboxedPost is Error) {
                this.updatePostStatus(post.path, "ABORTED")
                continue
            }

            content := unboxedPost["content"]
            ; QM2 post
            if (content.Has("module")) {
                res := ObjBindMethod(this.qmModules[content["module"]], "USE", content["form"]).Call()
                if (res is Error) {
                    this.updatePostStatus(post.path, "NOTFOUND")
                    continue
                }
            }
            ; PMN post
            else {
                res := PMN_Waterfall.cascade(content["profiles"], content["overwrite"], content["party"])
                if (res is Error) {
                    switch res.Message {
                        case "Ended Unexpectedly":
                            this.updatePostStatus(post.path, "RETRY")
                        case "Room not found":
                            this.updatePostStatus(post.path, "NOTFOUND")
                    }
                    continue
                }
            }

            this.updatePostStatus(post.path, "MODIFIED")
        }

        this.currentHandlingPost := ""

    }

    /**
     * <Client> Send post to pool
     * @param content post content to send
     */
    delegate(content) {
        c := useProps(content,
            content.HasOwnProp("form")
                ? { ; QM post
                    module: content.module, ; QM2 module name
                    form: content.form,     ; form data from module component
                    profiles: Map()         ; profiles from QM2 Panel
                } : { ; PMN post
                    mode: "waterfall",      ; single/waterfall/group
                    overwrite: false,       ; isOverwrite value
                    rooms: [],              ; waterfall/group room numbers
                    party: "",              ; optional party number for confinement
                    profiles: Map(),        ; json object in single, array in waterfall/group
                }
        )

        return this.POST(c.toObject(), content.HasOwnProp("form") ? this.qmPool : this.pool)
    }
}
