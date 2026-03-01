; components
#Include components\service-configs.ahk
#Include components\client-posts.ahk
#Include components\modal.ahk
#Include components\post-details-profile.ahk
#Include components\post-details-qm2.ahk
#Include components\qm2-panel.ahk
; qm2 moduels
#Include qm2-modules\blank-share\blank-share.ahk
#Include qm2-modules\payment-relation\payment-relation.ahk
; server
#Include server\unified-agent.ahk


/**
 * @param {Svnaer} App 
 */
ServerAgentPanel(App) {
    isListening := signal("离线")

    global agent := UnifiedAgent({
        pool: A_ScriptDir . "\src\Servers\pmn-pool",
        qmPool: A_ScriptDir . "\src\Servers\qm-pool",
        interval: 3000,
        expiration: 480,
        collectRange: 15,
        safePost: false,
        isListening: isListening
    })

    return (
        App.AddText("x30 y+10 h40 w580", "ProfileModifyNext Server").SetFont("s13 q5 Bold"),
        
        ; server
        ServiceConfigs(App, CONFIG.read("agentEnabled"), isListening),
        
        ; client
        ClientPosts(App, CONFIG.read("clientEnabled")) 
    )
}