#Requires AutoHotkey v2.0
#SingleInstance Force
; includes
#Include lib\index.ahk
#Include src\App.ahk

; global consts
VERSION := "1.8.5"
POPUP_TITLE := "ClipFlow " . VERSION
WIN_GROUP := ["ahk_class SunAwtFrame"]
IMAGES := useImages(A_ScriptDir . "\assets")
APP_DATA_DIR := A_AppData . "\ClipFlow"
CONFIG := useJsonConfig("./clipflow.config.json", "clipflow.config.json", APP_DATA_DIR)
SUSPEND_CONTROLLER := SuspendController(0x0401)

; init config
CoordMode("Mouse", "Screen")
TraySetIcon(IMAGES["CFTray.ico"])

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

; error logger
OnError(logError)
logError(err, *) {
	if (!DirExist(A_ScriptDir . "\error-log")) {
		DirCreate(A_ScriptDir . "\error-log")
	}

	errTxt := A_ScriptDir . "\error-log\" . FormatTime(A_Now, "yyyyMMdd") . "txt"
	errLog := Format("
		(
			{1} line: {2}
			message: {3}
			error:   {4}`n`n
		)", 
		FormatTime(A_Now, "yyyy/MM/dd HH:mm"),
		err.Line,
		err.Message,
		err.Extra
	)

	FileAppend(errLog, errTxt, "utf-8")

	if (DirExist(APP_DATA_DIR . "\clipflow-clips")) {
		DirDelete(APP_DATA_DIR . "\clipflow-clips", true)
	}

	if (FileExist(CONFIG.path)) {
		FileDelete(CONFIG.path)
	}
	CONFIG.createLocal()
	
	utils.cleanReload(WIN_GROUP)
}

; hotkeys setup
Pause:: {
	ClipFlowApp.Show()
}
F11:: {
	utils.cleanReload(WIN_GROUP)
}
^F11:: {
	if (DirExist(APP_DATA_DIR . "\clipflow-clips")) {
		DirDelete(APP_DATA_DIR . "\clipflow-clips", true)
	}

	if (FileExist(CONFIG.path)) {
		FileDelete(CONFIG.path)
	}
	CONFIG.createLocal()
	
	utils.cleanReload(WIN_GROUP)
}
#Hotif WinActive(POPUP_TITLE)
Esc:: {
	ClipFlowApp.Hide()
}