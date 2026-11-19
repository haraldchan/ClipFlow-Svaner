#Include components\clip-history-item.ahk
#Include clip-db.ahk

/**
 * @param {Svaner} App 
 */
ClipboardHistory(App) {
    IMG_EXTS := ["jpg", "jpeg", "gif", "png", "tiff", "bmp", "ico"]
    CLIP_HISTORY_LENGTH := 20
    CLIP_HISTORY_PAGE_LENGTH := 5

    clips := ClipDB({
        dbPath: APP_DATA_DIR "\clips.sqlite",
        retentionCount: CLIP_HISTORY_LENGTH
    })

    clipTemplate := { type: "", text: "", content: "" }
    clipHistoryContent := clips.load()

    fillerLength := Mod(clipHistoryContent.Length, CLIP_HISTORY_PAGE_LENGTH)
    fillerTimes := !clipHistoryContent.Length
        ? 5
        : CLIP_HISTORY_PAGE_LENGTH - (!fillerLength ? 5 : fillerLength)
    loop fillerTimes {
        clipHistoryContent.Push(clipTemplate)
    }
    msgbox clipHistoryContent.length

    clipHistory := signal(clipHistoryContent, { forceUpdagte: true })
    clipHistoryPage := signal(1)
    clipHistoryDisplay := computed([clipHistory, clipHistoryPage], handleShowClipHistory)
    handleShowClipHistory(curHistory, curPage) {
        startIndex := curPage * 5 - 4
        res := []
        loop 5 {
            res.Push(curHistory[startIndex - 1 + A_Index])
        }
        return res
    }

    handleClipHistoryUpdate() {
        newHistory := clips.load()

        fillerLength := Mod(newHistory.Length, CLIP_HISTORY_PAGE_LENGTH)
        loop CLIP_HISTORY_PAGE_LENGTH - (!fillerLength ? 5 : fillerLength) {
            newHistory.Push(clipTemplate)
        }

        clipHistory.set(newHistory)
        clipHistoryPage.set(1)
    }

    handleAddClip() {
        SplitPath(StrLower(A_Clipboard), &fileName, &dir, &ext, &fileNameNoExt, &drive)

        capturedType := match(dir, OrderedMap(
            (*) => dir.startsWith("http://") || dir.startsWith("https://"), "Link",
            (*) => drive && IMG_EXTS.find(e => e == ext), "Image",
            (*) => !drive, "Text",
            (*) => drive && !ext, "Folder"
        ), Format(".{1} file", ext))

        data := {
            type: capturedType,
            text: A_Clipboard,
            content: ClipboardAll(),
            createdAt: A_Now . A_MSec
        }
        
        clips.add(data)

        handleClipHistoryUpdate()
    }

    handleHistoryPageFlip(ctrl, _) {
        if ((ctrl.Text == "上一页" && clipHistoryPage.value == 1)
            || (ctrl.Text == "下一页" && clipHistoryPage.value == clipHistory.value.Length / CLIP_HISTORY_PAGE_LENGTH)

        ) {
            return
        }

        clipHistoryPage.set(page => page := ctrl.Text == "上一页" ? page - 1 : page + 1)
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
            callback: handleAddClip
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