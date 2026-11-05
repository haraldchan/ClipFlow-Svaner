#Include socket.ahk

class useServerAgent {
    __New(serverSettings) {
        s := useProps(serverSettings, {
            role: "FD",
            pool: "",
            interval: 3000,
            expiration: 480,
            collectRange: 15,
            safePost: false,
            isListening: "",
            tcpPort: 5001,
            udpPort: 5002
        })

        this.role := s.role
        this.tcpPort := s.tcpPort
        this.udpPort := s.udpPort
        this.liveBO := signal("", { forceUpdate: true })
        this.broadcaster := ""
        this.broadcastListener := ""
        this.tcpServer := ""
        this.tcpClient := ""
        this.heartbeater := ""

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

        if (!DirExist(this.pool)) {
            DirCreate(this.pool)
        }

        this.startFD()
    }


    startFD() {
        onHeartbeat(message) {
            parts := StrSplit(message.text, '|')
            if (parts.Length < 3 || parts[1] != 'BO') {
                return
            }

            this.liveBO.set({
                name: parts[2],
                ip: message.ip,
                tcpPort: Integer(parts[3]),
                udpPort: message.port,
                lastHeartbeat: A_Now
            })
        }

        try {
            this.broadcastListener := Socket.BroadcastListener(
                this.udpPort,
                onHeartbeat
            )
        }
        catch as e {
            ; err
        }
    }

    stopFD() {
        this.broadcastListener.Close()
        this.broadcastListener := ""
    }

    pingBO() {
        if (!this.liveBO.value) {
            return
        }

        try {
            if (this.tcpClient) {
                this.tcpClient.Close()
                this.tcpClient := ""
            }

            this.tcpClient := useServerAgent.TcpClient(this.liveBO.value.ip, this.liveBO.value.tcpPort)
            this.tcpClient.SendText("PING")
            return true
        }
        catch Error as e {
            ; MsgBox("Ping failed", POPUP_TITLE, "icon! 4096 T2")
            this.liveBO.set("")
            return false
        }
    }


    startBO() {
        this.stopFD()

        try {
            ; Start TCP server.
            this.tcpServer := useServerAgent.TcpServer(this.tcpPort)

            ; Start UDP broadcaster.
            this.broadcaster := Socket.Broadcast(this.udpPort)

            this.role := "BO"

            ; Send the first heartbeat immediately.
            this.sendHeartbeat(this.broadcaster)

            ; Continue broadcasting every 3000ms.
            this.heartbeater := ObjBindMethod(this, "sendHeartbeat", this.broadcaster)
            SetTimer(this.heartbeater, 3000)
            this.role := "BO"
        }
        catch Error as e {
            this.stopBO()
        }
    }

    sendHeartbeat(broadcaster) {
        if (this.role != "BO") {
            return
        }
        ; Format: BO | ComputerName | TCP port
        message := 'BO|' A_ComputerName '|' this.tcpPort '|' A_Now

        try {
            broadcaster.SendMessage(message)
        }
        catch Error as e {
            msgbox('Heartbeat error: ' e.Message)
        }
    }

    stopBO() {
        SetTimer(this.heartbeater, 0)

        if (this.broadcaster) {
            this.broadcaster.Close()
            this.broadcaster := ""
        }

        if (this.tcpServer) {
            this.tcpServer.Close()
            this.tcpServer := ""
        }

        this.role := "FD"
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
            FileMove(postPath, postPath.replace(curHeader[1].split("$$")[1], newStatus), true)
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
     * <Client> Post to pool
     * @param {Object} content 
     */
    POST(content, pool := this.pool) {
        if (this.safePost) {
            isAlive := this.pingBO()
            if (!isAlive) {
                MsgBox("Service offline.", , "4096 T2 iconx")
                return false
            } 
        }

        message := {
            id: A_Now . A_MSec . Random(100, 999),
            method: "POST",
            sender: A_ComputerName,
            content: content
        }

        ; future test: add STATUS$$BO_NAME in the first section of header
        post := Format("{1}\{2}=={3}=={4}.json", pool, "PENDING", A_ComputerName, message.id)
        FileAppend(JSON.stringify(message), post, "UTF-8")

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
            postID := A_LoopFileName.split("==")[3]
            postTimestamp := postID.substr(1, 14)

            if (DateDiff(A_Now, postTimestamp, "Minutes") >= this.collectRange && A_LoopFileName.includes(status)) {
                this.updatePostStatus(A_LoopFileFullPath, "ABANDONED")
                continue
            }

            if (InStr(A_LoopFileFullPath, status)) {
                try {
                    this.updatePostStatus(A_LoopFileFullPath, "COLLECTED$$" A_ComputerName)
                }
                catch {
                    ; if post filename changed, just ignore it
                    continue
                }

                posts.Push({
                    id: postID,
                    path: StrReplace(A_LoopFileFullPath, status, "COLLECTED$$" A_ComputerName),
                    timeCreated: A_LoopFileTimeCreated
                })
            }
        }

        return posts
    }

    class TcpServer extends Socket.Server {
        __New(port) {
            this.clients := []
            super.__New(port)
        }

        OnAccept(err) {
            if (err) {
                return
            }

            try {
                client := this.AcceptAsClient(useServerAgent.TcpClient)
                this.clients.Push(client)
            }
            catch Error as e {
                OutputDebug("TCP accept error: " e.Message)
            }
        }
    }

    class TcpClient extends Socket.Client {
        OnRead(err) {
            if (err) {
                return
            }

            try {
                response := this.RecvText()

                if (response) {
                    OutputDebug("TCP response: " response)
                }
            }
            catch Error as e {
                OutputDebug('TCP read error: ' e.Message)
            }
        }
    }

}