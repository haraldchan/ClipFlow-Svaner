#Requires AutoHotkey v2.0
#SingleInstance Force
; includes
#Include lib\index.ahk
#Include src\App.ahk

; global consts
VERSION := "1.7.1"
POPUP_TITLE := "ClipFlow " . VERSION
WIN_GROUP := ["ahk_class SunAwtFrame"]
IMAGES := useImages(A_ScriptDir . "\assets")
CONFIG := useJsonConfig(
	"./clipflow.config.json",
	"clipflow.config.json",
)

; init config
CoordMode "Mouse", "Screen"
TraySetIcon IMAGES["CFTray.ico"]

; Svaner App
ClipFlowApp := Svaner({
	gui: {
		title: POPUP_TITLE
	},
	font: {
		name: "微软雅黑"
	},
	events: {
		close: (*) => utils.quitApp("ClipFlow", POPUP_TITLE, WIN_GROUP)
	}
})

App(ClipFlowApp)
ClipFlowApp.Show()

; hotkeys setup
Pause:: ClipFlowApp.Show()
F11:: utils.cleanReload(WIN_GROUP)
^F11:: {
	if (DirExist(A_MyDocuments . "\clipflow-clips")) {
		DirDelete(A_MyDocuments . "\clipflow-clips", true)
	}

	if (FileExist(CONFIG.path)) {
		FileDelete(CONFIG.path)
	}
	CONFIG.createLocal()
	
	utils.cleanReload(WIN_GROUP)
}
#Hotif WinActive(POPUP_TITLE)
Esc:: ClipFlowApp.Hide()