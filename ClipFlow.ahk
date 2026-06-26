#Requires AutoHotkey v2.0
#SingleInstance Force
; includes
#Include lib\index.ahk
#Include src\App.ahk

; acquire admin
if (!A_IsAdmin) {
	try {
		Run("*RunAs " . A_ScriptFullPath)
	}
	catch {
		ExitApp()
	}
}

; version checking
VERSION := "1.10.2"
UNC_PATH := "\\10.0.2.13\fd"

; uncClipFlowPath := UNC_PATH . "\19-个人文件夹\HC\Software - 软件及脚本\AHK_Scripts\ClipFlow-SvanerTest-main\"
; SplitPath(A_ScriptDir, , , , , &OutDrive)
; if (OutDrive == "C:" && DirExist("\\10.0.2.13\fd")) {
; 	uncCF := FileRead(uncClipFlowPath . "\ClipFlow.ahk", "utf-8")

; 	splitted := StrSplit(uncCF, "`n")
; 	for line in splitted {
; 		if (InStr(line, "VERSION := ")) {
; 			uncVersion := StrReplace(line, "VERSION := ", "")
; 		}
; 	}

; 	if (uncVersion != VERSION) {
; 		if (!DirExist("C:\ClipFlow\")) {
; 			DirCopy(uncClipFlowPath, "C:\ClipFlow\app", true)
; 			Reload()
; 		}
; 	}
; }

; global consts
POPUP_TITLE := "ClipFlow " . VERSION
WIN_GROUP := ["ahk_class SunAwtFrame"]
IMAGES := useImages(A_ScriptDir . "\assets")
APP_DATA_DIR := A_AppData . "\ClipFlow"
CONFIG := useJsonConfig("./clipflow.config.json", "clipflow.config.json", APP_DATA_DIR)
USE_ERROR_LOG := CONFIG.read(["app", "errorLogging"])
FORCE_SUSPEND_MESSAGE := 0x2042
SUSPEND_CONTROLLER := SuspendController(FORCE_SUSPEND_MESSAGE)

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
		close: (*) => utils.quitApp("ClipFlow", POPUP_TITLE, WIN_GROUP),
		escape: app => app.Hide()
	}
})

App(ClipFlowApp)
ClipFlowApp.Show()

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