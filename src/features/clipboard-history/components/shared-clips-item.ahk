/**
 * @param {Svaner} App 
 * @param {signal} sharedClipHistory 
 * @param {Integer} index 
 */
ShareClipsItem(App, sharedClipHistory, index) {    
    curIcon := 0
    i := SystemIcons.iconRef

    effect(sharedClipHistory, handleCtrlVisibility)
    handleCtrlVisibility(curHistory) {
        copyBtn := App["sci-copy-btn" . index]
        openBtn := App["sci-open-btn" . index]
        pic := App["sci-pic" . index]

        pic.Visible := false
        openBtn.setIcon(i.ICON_FOLDER_LINK)

        if (!curHistory[index].type) {
            copyBtn.removeIcon()
            openBtn.removeIcon()
            return
        }
        else if (curHistory[index].type == "Image") {
            copyBtn.Visible := false
            pic.Visible := true
            
            pic.Value := FileExist(curHistory[index].text)
                ? curHistory[index].text
                : IMAGES["ImageNotFound.png"]
            return
        }
        else if (curHistory[index].type == "Text") {
            curIcon := i.ICON_TEXT
            openBtn.removeIcon()
        }
        else {
            iconIndex := match(curHistory[index].type, Map(
                t => t.startsWith(".7z") || t.startsWith(".zip"), i.ICON_ZIP,
                t => t.startsWith(".doc"), i.ICON_WORD,
                t => t.startsWith(".xls"), i.ICON_EXCEL,
                t => t.startsWith(".ppt"), i.ICON_PPT,
                t => t.endsWith("file"), i.ICON_FILE,
                "Folder", i.ICON_FOLDER,
                "URL", i.ICON_URL,
            ))

            curIcon := iconIndex
        }


        copyBtn.setIcon(curIcon)
        copyBtn.Visible := true
    }


    handleHistoryContentCopy(ctrl, _) {     
        Sleep 200

        if (!sharedClipHistory.value[index].text) {
            return
        }

        A_Clipboard := sharedClipHistory.value[index].text
        copyBtn := App["sci-copy-btn" . index]
        pic := App["sci-pic" . index]
        isPic := ctrl is Gui.Pic

        pic.Visible := false
        copyBtn.Visible := true
        copyBtn.setIcon(i.ICON_COPIED)
        copyBtn.Enabled := false

		SetTimer(() => (
            copyBtn.Enabled := true,
            pic.Visible := isPic,
            copyBtn.Visible := !isPic,
            copyBtn.setIcon(curIcon)
		), -1000)
    }

    handleOpenFromPath(ctrl, _) {
        if (!sharedClipHistory.value[index].text) {
            return
        }

        try {
            if (sharedClipHistory.value[index].type == "Text") {
                return
            }
            
            Run(sharedClipHistory.value[index].text)
        } catch Error as e {
            MsgBox("无法找到指定文件（它可能已被移动、重命名或删除）", POPUP_TITLE, "4096 T2")
        }
    }

    handleOpenDirMeta(*) {
        if (!sharedClipHistory.value[index].text || sharedClipHistory.value[index].type == "Text") {
            return
        }

        Run Format('explorer /select, "{1}"', sharedClipHistory.value[index].contentPath)
    }

    onMount() {
        App["sci-pic" . index].onDoubleClick(handleOpenFromPath)
        handleCtrlVisibility(sharedClipHistory.value)
    }

    return (
        App.AddGroupBox(
            "Section w350 r2 x340" . (index == 1 ? " y+9 " : " y+15 "), 
            "{1}", sharedClipHistory, 
            { index: index, keys: ["type"] }
        ).SetFont("bold"),
        
        ; clipboard text
        App.AddEdit("ReadOnly xs10 yp+20 w230 r2", "{1}", sharedClipHistory, { index: index, keys: ["text"] }),

        ; copy btns
        App.AddButton(("vsci-copy-btn" . index) . " x+0 @use:ch-btn @button:icon-only", "")
           .onClick(handleHistoryContentCopy)
           .onDoubleClick(handleOpenFromPath),

        ; pic preview
        App.AddPic(("vsci-pic" . index) . " xp+0 yp+0 @pic:real-size @use:ch-btn Hidden", "")
           .onClick(handleHistoryContentCopy),

        ; open btn
        App.AddButton(("vsci-open-btn" . index) . " x+0 @use:ch-btn @button:icon-only", "")
           .onClick(handleOpenDirMeta),

        onMount()
    )
}
