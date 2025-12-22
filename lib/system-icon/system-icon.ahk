class SystemIcons {
    static cache := Map()   ; ext → hIcon
    static SHGFI_ICON := 0x100
    static SHGFI_USEFILEATTRIBUTES := 0x10
    static FILE_ATTRIBUTE_NORMAL := 0x80
    static FILE_ATTRIBUTE_DIRECTORY := 0x10

    static iconRef := {
        ICON_BLANK: [1, "imageres.dll"],
        ICON_FILE: [2, "imageres.dll"],
        ICON_FOLDER: [3, "imageres.dll"],
        ICON_FOLDER_GOTO: [45, "shell32.dll"],
        ICON_FOLDER_LINK: [176, "imageres.dll"],
        ICON_TEXT: [118, "imageres.dll"],
        ICON_OK: [228, "imageres.dll"],
        ICON_URL: [257, "imageres.dll"],
        ICON_ZIP: [165, "imageres.dll"],
        ICON_WORD: [340, "imageres.dll"],
        ICON_EXCEL: [339, "imageres.dll"],
        ICON_PPT: [350, "imageres.dll"],
        ICON_CLIPBOARD: [242, "imageres.dll"],
        ICON_COPIED: [216, "shell32.dll"],
        ; ICON_: [, ""],
    }

    static setIcon(btn, ref, size := 32) {
        button := btn is SvanerButton ? btn.ctrl : btn
        ; return key is Number ? this.setIdxIcon(btn, key) : this.setExtIcon(btn, key)
        this.setIdxIcon(button, ref[1], ref[2], size)

        return btn
    }

    ;------------------------------
    ; Public — Use an icon on a button
    ; key can be:
    ;   ".txt"
    ;   "folder"
    ;   "C:\file.exe"
    ;------------------------------
    static setExtIcon(btn, ext) {
        hIcon := this.Get(ext)
        if !hIcon
            return false

        ; BM_SETIMAGE=0xF7, IMAGE_ICON=1
        DllCall("SendMessage"
            , "Ptr", btn.Hwnd
            , "UInt", 0xF7
            , "Ptr", 1
            , "Ptr", hIcon)

        return btn
    }

    ;------------------------------
    ; Public — Extract icon by shell index
    ;------------------------------
    static setIdxIcon(btn, idx, dll ,size := 32) {
        hIcon := this.GetFromDLL(idx, dll)
        if !hIcon
            return false

        DllCall("SendMessage"
            , "Ptr", btn.Hwnd
            , "UInt", 0xF7
            , "Ptr", 1
            , "Ptr", hIcon)

        return btn
    }

    static removeIcon(btn) {
        old := SendMessage(0xF7, 1, 0, btn.Hwnd)
        if old
            DllCall("DestroyIcon", "Ptr", old)
    }

    ;------------------------------
    ; Public — Get icon handle
    ;------------------------------
    static Get(key) {
        if this.cache.Has(key)
            return this.cache[key]

        ; directory keyword
        if (key = "folder")
            hIcon := this.FromSHGetFileInfo("C:\", this.FILE_ATTRIBUTE_DIRECTORY)
        else if RegExMatch(key, "^\..+")  ; extension
            hIcon := this.FromSHGetFileInfo(key, this.FILE_ATTRIBUTE_NORMAL)
        else if InStr(key, "\")          ; assume file path
            hIcon := this.FromSHGetFileInfo(key, 0)
        else
            return false

        return hIcon
    }

    ;------------------------------
    ; Core - via SHGetFileInfo
    ;------------------------------
    static FromSHGetFileInfo(str, attr) {
        sfi := Buffer(A_PtrSize + 16, 0)

        DllCall("shell32\SHGetFileInfoW"
            , "Str", str
            , "UInt", attr
            , "Ptr", sfi
            , "UInt", sfi.Size
            , "UInt", this.SHGFI_ICON | this.SHGFI_USEFILEATTRIBUTES
            , "Ptr")

        return NumGet(sfi, 0, "Ptr") ; HICON
    }

    ;------------------------------
    ; Load icon from shell32 index
    ;------------------------------
    static GetFromDLL(index, dll, size := 32) {
        ; hIcon := DllCall("shell32\ExtractIconW"
        ;     , "Ptr", 0
        ;     , "Str", A_WinDir "\System32\" dll
        ;     , "UInt", index
        ;     , "Ptr")

        ; return hIcon

        hBig := 0, hSmall := 0

        DllCall("shell32\ExtractIconExW"
            , "Str", A_WinDir "\System32\" dll
            , "Int", index
            , "Ptr*", &hBig
            , "Ptr*", &hSmall
            , "UInt", 1)

        if (size <= 16) {
            if (hBig) DllCall("DestroyIcon", "Ptr", hBig)
            return hSmall
        } else {
            if (hSmall) DllCall("DestroyIcon", "Ptr", hSmall)
            return hBig
        }
    }
}


Gui.Button.Prototype.cache := Map()
Gui.Button.Prototype.SHGFI_ICON := ObjBindMethod(SystemIcons, "SHGFI_ICON")
Gui.Button.Prototype.SHGFI_USEFILEATTRIBUTES := ObjBindMethod(SystemIcons, "SHGFI_USEFILEATTRIBUTES")
Gui.Button.Prototype.FILE_ATTRIBUTE_NORMAL := ObjBindMethod(SystemIcons, "FILE_ATTRIBUTE_NORMAL")
Gui.Button.Prototype.FILE_ATTRIBUTE_DIRECTORY := ObjBindMethod(SystemIcons, "FILE_ATTRIBUTE_DIRECTORY")
Gui.Button.Prototype.setIcon := ObjBindMethod(SystemIcons, "setIcon")
Gui.Button.Prototype.setExtIcon := ObjBindMethod(SystemIcons, "setExtIcon")
Gui.Button.Prototype.setIdxIcon := ObjBindMethod(SystemIcons, "setIdxIcon")
Gui.Button.Prototype.removeIcon := ObjBindMethod(SystemIcons, "removeIcon")
Gui.Button.Prototype.Get := ObjBindMethod(SystemIcons, "Get")
Gui.Button.Prototype.FromSHGetFileInfo := ObjBindMethod(SystemIcons, "FromSHGetFileInfo")
Gui.Button.Prototype.GetFromDLL := ObjBindMethod(SystemIcons, "GetFromDLL")

SvanerButton.Prototype.cache := Map()
SvanerButton.Prototype.SHGFI_ICON := ObjBindMethod(SystemIcons, "SHGFI_ICON")
SvanerButton.Prototype.SHGFI_USEFILEATTRIBUTES := ObjBindMethod(SystemIcons, "SHGFI_USEFILEATTRIBUTES")
SvanerButton.Prototype.FILE_ATTRIBUTE_NORMAL := ObjBindMethod(SystemIcons, "FILE_ATTRIBUTE_NORMAL")
SvanerButton.Prototype.FILE_ATTRIBUTE_DIRECTORY := ObjBindMethod(SystemIcons, "FILE_ATTRIBUTE_DIRECTORY")
SvanerButton.Prototype.setIcon := ObjBindMethod(SystemIcons, "setIcon")
SvanerButton.Prototype.setExtIcon := ObjBindMethod(SystemIcons, "setExtIcon")
SvanerButton.Prototype.setIdxIcon := ObjBindMethod(SystemIcons, "setIdxIcon")
SvanerButton.Prototype.removeIcon := ObjBindMethod(SystemIcons, "removeIcon")
SvanerButton.Prototype.Get := ObjBindMethod(SystemIcons, "Get")
SvanerButton.Prototype.FromSHGetFileInfo := ObjBindMethod(SystemIcons, "FromSHGetFileInfo")
SvanerButton.Prototype.GetFromDLL := ObjBindMethod(SystemIcons, "GetFromDLL")