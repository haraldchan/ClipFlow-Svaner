#Include "./shared-clips-item.ahk"

/**
 * @param {Svaner} App 
 * @param {signal} sendToSharedClips 
 */
SharedClips(App, sendToSharedClips) {
    SHARED_CLIPS_DIR := CONFIG.read("sharedClipsDir")
    PAGE_LENGTH := 5
    SHARED_CLIPS_KEEP_HOURS := 8

    clipTemplate := { type: "", text: "", contentPath: "" }
    
    pageIndex := 1
    sharedClipHistoryAll := []
    initSharedClipHistory()
    sharedClipHistory := signal(sharedClipHistoryAll.slice(pageIndex, PAGE_LENGTH + 1))

    App["tabs"].onChange((ctrl, _) => ctrl.Text == "剪贴板历史" && handleRefresh())
    initSharedClipHistory(*) {
        sharedClipHistoryAll := []
        pageIndex := 1

        loop files, SHARED_CLIPS_DIR . "\*.json", "R" {
            if (A_LoopFileTimeCreated.hoursBetween(A_Now) > SHARED_CLIPS_KEEP_HOURS) {
                FileDelete(A_LoopFileFullPath)
                continue
            }

            sharedClipHistoryAll.InsertAt(1, JSON.parse(FileRead(A_LoopFileFullPath, "UTF-8")))
        }

        if (Mod(sharedClipHistoryAll.Length, PAGE_LENGTH) || sharedClipHistoryAll.Length == 0) {
            loop 5 - Mod(sharedClipHistoryAll.Length, PAGE_LENGTH) {
                sharedClipHistoryAll.Push(clipTemplate)
            }
        }
    }

    handleRefresh(*) {
        initSharedClipHistory()
        App["flip-prev"].Enabled := false
        App["flip-next"].Enabled := true
        sharedClipHistory.set(sharedClipHistoryAll.slice(pageIndex, pageIndex + PAGE_LENGTH))
    }

    handlePageFlip(ctrl, _) {
        if (ctrl.Text == "下一页") {
            pageIndex := pageIndex + 5 > sharedClipHistoryAll.Length 
                ? sharedClipHistoryAll.Length - PAGE_LENGTH + 1
                : pageIndex + 5
        } else if (ctrl.Text == "上一页") {
            pageIndex := pageIndex - 5 < 0 
                ? 1
                : pageIndex - 5
        }
    
        App["flip-prev"].Enabled := pageIndex > 1
        App["flip-next"].Enabled := !(pageIndex == sharedClipHistoryAll.Length - PAGE_LENGTH + 1)

        sharedClipHistory.set(sharedClipHistoryAll.slice(pageIndex, pageIndex + PAGE_LENGTH))
    }


    return (
        App.AddGroupBox("Section x330 y70 w380 r19", "Shared Clips - 共享剪贴板").SetFont("s9 bold"),
        
        ; sync clips to SHARED_CLIPS_DIR
        App.AddCheckbox("xs15 yp+25 h20", "同步到共享剪贴板", { check: sendToSharedClips }).bind(),
        
        ; flip btns
        App.AddButton("x+35 w20 h20", "↻").OnEvent("Click", handleRefresh),
        App.AddButton("vflip-prev x+10 w80 h20 Disabled", "上一页").onClick(handlePageFlip),
        App.AddButton("vflip-next x+10 w80 h20", "下一页").onClick(handlePageFlip),

        ; shared clip items
        PAGE_LENGTH.times(() => ShareClipsItem(App, sharedClipHistory, A_Index))
    )
}
