; components
#Include components\rh-app.ahk
#Include components\entry-btns.ahk
#Include components\reservation-details.ahk
#Include components\settings.ahk
#Include components\settings-ctrip.ahk
#Include components\settings-settings-wholesale.ahk
#Include components\settings-workflow-ota.ahk
; data
#Include data\rh-models.ahk
#Include data\rh-formatter.ahk
; macros
#Include macros\entry-ota.ahk
#Include macros\entry-fedex.ahk


class ReservationHandler {
    static name := "Reservation Handler"
    static title := "Flow Mode - " . this.name
    static popupTitle := "ClipFlow - " . this.name
    static identifier := "031709eafc20ab898d6b9e9860d31966" ; MD5 hash: ReservationHandler

    static USE(App) {
        RH_App(App, this.title, this.identifier)
    }
}