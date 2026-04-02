class UnifiedAgent extends useServerAgent {
    __New(serverSettings) {
        super.__New(serverSettings)
        this.qmPool := serverSettings.HasOwnProp("qmPool") ? serverSettings.qmPool : ""
        this.popupTitle := "Unified Agent"

        effect(this.isListening, cur => SetTimer(() => this.listen(cur), -100))

        ; ongoing post
        this.currentHandlingPost := ""

        ; QM2 modules
        this.qmModules := Map(
            "BlankShare", BlankShare_Action,
            "PaymentRelation", PaymentRelation_Action,
            "DepositEntry", DepositEntry_Action
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

    abort(pool := this.pool) {
        if (!this.currentHandlingPost) {
            return
        }

        loop files (pool . "\*.json") {
            if (InStr(A_LoopFileName, this.currentHandlingPost["id"])) {
                this.updatePostStatus(A_LoopFileFullPath, "ABORTED")
            }
        }

        this.setOnlineStatus(false)
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
            this.setOnlineStatus(true)
            this.spawnRespondent(A_ScriptDir . "\lib\index.ahk", "ua-respondent")
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
                            this.updatePostStatus(posts[A_Index], "RETRY")
                        case "Room not found":
                            this.updatePostStatus(posts[A_Index], "NOTFOUND")
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