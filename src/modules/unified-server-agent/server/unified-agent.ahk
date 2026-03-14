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
    }

    /**
     * <Agent>
     */
    blockInput() {
        if (!WinExist(this.popupTitle)) {
            UnifiedAgentModal(() => this.isListening.set("离线"))
        }

        BlockInput true
        if (this.isListening.value == "离线") {
            BlockInput false
        }
    }

    /**
     * <Agent>
     */
    keepAlive() {
        if (this.isListening.value == "在线") {
            try {
                WinActivate("ahk_class SunAwtFrame")
                Send "!r"
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
                Sleep this.interval
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

        postsToReset.Push(this.COLLECT("COLLECTED", this.qmPool))
        postsToReset.Push(this.COLLECT("RETRY", this.qmPool))
        postsToReset.Push(this.COLLECT("COLLECTED"))
        postsToReset.Push(this.COLLECT("RETRY"))

        for post in postsToReset {
            this.updatePostStatus(post, "PENDING")
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
        pmnPosts := this.COLLECT("PENDING")

        if (pmnPosts.Length || qmPosts.Length) {
            WinHide(this.popupTitle)
        }
        
        if (qmPosts.Length) {
            this.executeQmPostedActions(qmPosts)
        }

        if (pmnPosts.Length) {
            this.modifyPostedProfiles(pmnPosts)
        }

        this.currentHandlingPost := ""
        WinShow(this.popupTitle)
        this.isListening.set("在线")
    }
    
    /**
     * <Agent>
     * @param {String[]} posts 
    */
   modifyPostedProfiles(posts) {
        unboxedPosts := posts.map(postPath => JSON.parse(FileRead(postPath, "UTF-8"))).reverse()

        for post in unboxedPosts {
            this.currentHandlingPost := post
            c := post["content"]
            res := PMN_Waterfall.cascade(c["profiles"], c["overwrite"], c["party"])
            if (res == "Ended Unexpectedly") {
                this.updatePostStatus(posts[A_Index], "RETRY")
            } else if (res == "Room not found") {
                this.updatePostStatus(posts[A_Index], "NOTFOUND")
            } else {
                this.updatePostStatus(posts[A_Index], "MODIFIED")
            }
        }
    }

    /**
     * <Agent>
     * @param {String[]} posts 
     */
    executeQmPostedActions(posts) {
        unboxedPosts := posts.map(postPath => JSON.parse(FileRead(postPath, "UTF-8"))).reverse()

        for post in unboxedPosts {
            this.currentHandlingPost := post
            ; call QM action module
            ObjBindMethod(this.qmModules[post["content"]["module"]], "USE", post["content"]["form"]).Call()

            this.updatePostStatus(posts[A_Index], "MODIFIED")
        }
    }

    /**
     * <Client> Send post to pool
     * @param content post content to send
     */
    delegate(content) {
        c := useProps(content, 
            content.HasOwnProp("form") 
                ? { ; QM post
                    module:   content.module, ; QM2 module name
                    form:     content.form,   ; form data from module component
                    profiles: []              ; profiles from QM2 Panel
                } : { ; PMN post
                    mode:      "waterfall", ; single/waterfall/group
                    overwrite: false,       ; isOverwrite value
                    rooms:     [],          ; waterfall/group room numbers
                    party:     "",          ; optional party number for confinement 
                    profiles:  [],          ; json object in single, array in waterfall/group
                }
        )

        return this.POST(c.toObject(), content.HasOwnProp("form") ? this.qmPool : this.pool)
    }
}