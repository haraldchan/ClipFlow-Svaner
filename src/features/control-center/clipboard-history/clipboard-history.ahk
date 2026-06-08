#Include components\clip-history-item.ahk

/**
 * @param {Svaner} App 
 */
ClipboardHistory(App) {
    IMG_EXTS := ["jpg", "jpeg", "gif", "png", "tiff", "bmp", "ico"]
    CLIP_HISTORY_LENGTH := 20
    CLIP_HISTORY_PAGE_LENGTH := 5
    CLIP_HISTORY_DIR := APP_DATA_DIR . "\clipflow-clips"
    if (!DirExist(CLIP_HISTORY_DIR)) {
        DirCreate(CLIP_HISTORY_DIR)
    }
    
    clipTemplate := { type: "", text: "", content: "" }
    clipHistoryContent := []

    loop files, CLIP_HISTORY_DIR . "\*.clip" {
        A_Clipboard := ClipboardAll(FileRead(A_LoopFileFullPath, "RAW"))
        clipHistoryContent.InsertAt(1, handleContentSplit())
    } until (A_Index > CLIP_HISTORY_LENGTH)

    loop CLIP_HISTORY_PAGE_LENGTH - Mod(clipHistoryContent.Length, CLIP_HISTORY_PAGE_LENGTH) {
        clipHistoryContent.Push(clipTemplate)
    }
    clipHistory := signal(clipHistoryContent, { forceUpdagte: true })
    clipHistoryPage := signal(1)
    clipHistoryDisplay := computed([clipHistory, clipHistoryPage], (curHistory, curPage) => curHistory.slice(curPage * CLIP_HISTORY_PAGE_LENGTH - (CLIP_HISTORY_PAGE_LENGTH - 1), curPage * CLIP_HISTORY_PAGE_LENGTH + 1))
    
    handleClipHistoryUpdate() {
        newHistory := [clipHistory.value*]
        if (index := newHistory.findIndex(c => c.text == A_Clipboard)) {
            newHistory.InsertAt(1, newHistory.RemoveAt(index))
        }
        else {
            newHistory.InsertAt(1, handleContentSplit(true))
        }

        if (newHistory.Length > CLIP_HISTORY_LENGTH) {
            newHistory.Pop()
        } 

        clipHistory.set(newHistory)
    }

    handleContentSplit(saveClip := false) {
        SplitPath(StrLower(A_Clipboard), &fileName, &dir, &ext, &fileNameNoExt, &drive)

        capturedType := match(dir, OrderedMap(
            (*) => dir.startsWith("http://") || dir.startsWith("https://"), "Link",
            (*) => drive && IMG_EXTS.find(e => e == ext), "Image",
            (*) => !drive, "Text",
            (*) => drive && !ext, "Folder"
        ), Format(".{1} file", ext))

        timeStamp := A_Now . A_MSec
        rand := Random(100, 999)
        clipName := Format("{1}\{2}={3}.clip", CLIP_HISTORY_DIR, timeStamp, rand)

        if (saveClip) {
            FileAppend(ClipboardAll(), clipName)
        }

        return {
            type: capturedType,
            text: A_Clipboard,
            content: ClipboardAll()
        }
    }

    handleHistoryPageFlip(ctrl, _) {
        if ((ctrl.Text == "上一页" && clipHistoryPage.value == 1) 
           || (ctrl.Text == "下一页" && clipHistoryPage.value == clipHistory.value.Length / CLIP_HISTORY_PAGE_LENGTH)
        ) {
            return
        }

        clipHistoryPage.set(page => page := ctrl.Text == "上一页" ? page - 1 : page + 1)
    }

    handleLocalClipsCleaning() {
        clipList := []
        loop files, CLIP_HISTORY_DIR . "\*.clip" {
            SplitPath(A_LoopFileFullPath,,,,&filename)
            clipList.Push({
                timeStamp: Integer(filename.split("=")[1]),
                fullpath: A_LoopFileFullPath
            })
        }

        sortedClipList := clipList.sort((a, b) => b.timeStamp - a.timeStamp)
        for clip in sortedClipList {
            if (A_Index <= CLIP_HISTORY_LENGTH) {
                continue
            }

            FileDelete(clip.fullpath)
        }
    }

    App.defineDirectives(
        "@use:chi-gb", "@align[x]:chi-first-gb y+15",
        "@use:ch-btn", "w40 h40"
    )

    onMount() {
        clbListeners.addListener({
            description: "剪贴板历史追踪",
            isOn: true,
            type: "persist",
            callback: (*) => (handleClipHistoryUpdate(), handleLocalClipsCleaning())
        })
    }

    render() {
        App.AddText("vclb-his-title @align[y]:persist-listeners-gb @relative[x+20]:persist-listeners-gb w100 h20", "剪贴板历史")
           .SetFont("bold s10")
        App.AddButton("x+10 w70 h20", "上一页").onClick(handleHistoryPageFlip)
        App.AddEdit("x+10 w30 h20", "{1}", clipHistoryPage)
        App.AddButton("x+10 w70 h20", "下一页").onClick(handleHistoryPageFlip)
        CLIP_HISTORY_PAGE_LENGTH.times(() => ClipHistoryItem(App, clipHistoryDisplay, A_Index))
        onMount()
    }

    return render()
}
