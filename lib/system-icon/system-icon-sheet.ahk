#SingleInstance Force
#Include "./system-icon.ahk"
#Include "../Svaner/useSvaner.ahk"
oGui := Gui()
IconReference(oGui)
ogui.Show()

IconReference(App) {
    dll := "imageres.dll"
    ; dll := "shell32.dll"
    ; dll := "ddores.dll"
    size := 32

    onMount() {
        App.getCtrlByTypeAll("Button")
           .map(btn => btn.OnEvent("Click", (ctrl, _) => (
                MsgBox("Index: " . ctrl.Text,,"T1")
                A_Clipboard := ctrl.Text
            )))
    }

    return (
        20.times(idx => App.AddButton((idx == 1 ? "x10" : "x+10") . " w45 h45 0x40 0x300", idx).setIcon([idx, dll], size)),
        20.times(idx => App.AddButton((idx == 1 ? "x10" : "x+10") . " w45 h45 0x40 0x300", idx + 20).setIcon([idx + 20, dll], size)),
        20.times(idx => App.AddButton((idx == 1 ? "x10" : "x+10") . " w45 h45 0x40 0x300", idx + 40).setIcon([idx + 40, dll], size)),
        20.times(idx => App.AddButton((idx == 1 ? "x10" : "x+10") . " w45 h45 0x40 0x300", idx + 60).setIcon([idx + 60, dll], size)),
        20.times(idx => App.AddButton((idx == 1 ? "x10" : "x+10") . " w45 h45 0x40 0x300", idx + 80).setIcon([idx + 80, dll], size)),
        20.times(idx => App.AddButton((idx == 1 ? "x10" : "x+10") . " w45 h45 0x40 0x300", idx + 100).setIcon([idx + 100, dll], size)),
        20.times(idx => App.AddButton((idx == 1 ? "x10" : "x+10") . " w45 h45 0x40 0x300", idx + 120).setIcon([idx + 120, dll], size)),
        20.times(idx => App.AddButton((idx == 1 ? "x10" : "x+10") . " w45 h45 0x40 0x300", idx + 140).setIcon([idx + 140, dll], size)),
        20.times(idx => App.AddButton((idx == 1 ? "x10" : "x+10") . " w45 h45 0x40 0x300", idx + 160).setIcon([idx + 160, dll], size)),
        20.times(idx => App.AddButton((idx == 1 ? "x10" : "x+10") . " w45 h45 0x40 0x300", idx + 180).setIcon([idx + 180, dll], size)),
        20.times(idx => App.AddButton((idx == 1 ? "x10" : "x+10") . " w45 h45 0x40 0x300", idx + 200).setIcon([idx + 200, dll], size)),
        20.times(idx => App.AddButton((idx == 1 ? "x10" : "x+10") . " w45 h45 0x40 0x300", idx + 220).setIcon([idx + 220, dll], size)),
        20.times(idx => App.AddButton((idx == 1 ? "x10" : "x+10") . " w45 h45 0x40 0x300", idx + 240).setIcon([idx + 240, dll], size)),
        20.times(idx => App.AddButton((idx == 1 ? "x10" : "x+10") . " w45 h45 0x40 0x300", idx + 260).setIcon([idx + 260, dll], size)),
        20.times(idx => App.AddButton((idx == 1 ? "x10" : "x+10") . " w45 h45 0x40 0x300", idx + 280).setIcon([idx + 280, dll], size)),
        20.times(idx => App.AddButton((idx == 1 ? "x10" : "x+10") . " w45 h45 0x40 0x300", idx + 300).setIcon([idx + 300, dll], size)),
        20.times(idx => App.AddButton((idx == 1 ? "x10" : "x+10") . " w45 h45 0x40 0x300", idx + 320).setIcon([idx + 320, dll], size)),
        20.times(idx => App.AddButton((idx == 1 ? "x10" : "x+10") . " w45 h45 0x40 0x300", idx + 340).setIcon([idx + 340, dll], size)),
        20.times(idx => App.AddButton((idx == 1 ? "x10" : "x+10") . " w45 h45 0x40 0x300", idx + 360).setIcon([idx + 360, dll], size)),
        ; App.AddButton("x+10 w45 h45 0x40 0x300").setKeyIcon(".json"),

        onMount()
    )   
}