; components
#Include components\service-configs.ahk
#Include components\client-posts.ahk
#Include components\modal.ahk
#Include components\post-details-profile.ahk
#Include components\post-details-qm2.ahk
#Include components\qm2-panel.ahk
; server
#Include server\unified-agent.ahk

/**
 * @param {Svnaer} App 
 */
ServerAgentPanel(App) {
    isListening := signal("离线")

    serverConfig := CONFIG.read("serverConfig")
    global agent := UnifiedAgent({
        pool: serverConfig["host"] . serverConfig["pmnPool"],
        qmPool: serverConfig["host"] . serverConfig["qmPool"],
        interval: 3000,
        expiration: 480,
        collectRange: 15,
        safePost: true,
        isListening: isListening
    })

    onMount() {
        serverOnlineStatus := JSON.parse(FileRead(agent.onlineStatusIndicator, "utf-8"),, false)
        if (serverOnlineStatus.isRestart) {
            isListening.set("在线")
        }
    }

    render() {
        App.AddText("x30 y+10 h40 w580", "ProfileModifyNext Server").SetFont("s13 q5 Bold")
        
        ; server
        ServiceConfigs(App, CONFIG.read("serviceEnabled"), isListening)
        
        ; client
        ClientPosts(App, CONFIG.read("clientEnabled"))

        onMount()
    }

    return render()
}
