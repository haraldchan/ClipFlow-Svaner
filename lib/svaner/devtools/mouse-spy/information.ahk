/**
 * @param {Svaner }App 
 * @param {Map} config 
 * @param {String} AppWindowTitle 
 * @param {String} suspendText 
 */
MouseSpy_Information(App, config, AppWindowTitle, suspendText) {
    unpack(mouseStore, { 
        curMouseCoordMode: &curMouseCoordMode,
        curMouseInfo:      &curMouseInfo,
        anchorPos:         &anchorPos,
        followMouse:       &followMouse,
        methods: { 
            updater:       &updater,
            moveToAnchor:  &moveToAnchor
        }
    })

    effect(followMouse, isFollowing => 
        SetTimer(updater, isFollowing ? config["misc"]["updateInterval"] : 0)
        App["follow-status"].Value := isFollowing
    )

    SetTimer(updater, config["misc"]["updateInterval"])
    effect(curMouseInfo, cur => App["color-indicator"].SetFont(Format("s13 c{1}", StrReplace(cur.color, "0x", ""))))
    
    curWindowInfo := computed(curMouseInfo, updateWindowInfoUpdate, { name: "curWindowInfo" })
    updateWindowInfoUpdate(curMouseInfo) {
        w := curMouseInfo.window
        try {
            ahkExe := WinGetProcessName(w)
        } catch {
            ahkExe := ""
        }

        return {
            winTitle: WinGetTitle(w),
            ahkClass: WinGetClass(w),
            ahkExe:   ahkExe,
            ahkPid:   WinGetPID(w),
            ahkId:    w
        }
    }

    distance := computed( 
        [curMouseInfo, anchorPos], 
        (curMP, curAP) => (
            x := curMP.Screen.x - curAP.Screen.x,
            y := curMP.Screen.y - curAP.Screen.y,
            { 
                x: x < 0 ? " - " . Abs(x) : " + " . x, 
                y: y < 0 ? " - " . Abs(y) : " + " . y
            }
        )
    , { name: "distance" })

    handleAnchorTypeToggling(ctrl, _) {
        isUsingMousePosAnchor := InStr(ctrl.Text, "mouse") ? true : false

        App["use-mouse-pos-anchor"].Value := isUsingMousePosAnchor
        App["use-image-anchor"].Value := !isUsingMousePosAnchor

        App["image-anchor-filepath"].Enabled := !isUsingMousePosAnchor
        App["choose-image-anchor-btn"].Enabled := !isUsingMousePosAnchor
    }


    handleSelectImageAnchor(*) {
        imageExts := ["jpg", "jpeg", "gif", "png", "tiff", "bmp", "ico"]
        
        App.Opt("+OwnDialogs")
        selectedFile := FileSelect("3")
        SplitPath(selectedFile,,,&selectedExt)
        
        if (!selectedFile || !ArrayExt.find(imageExts, ext => ext == StrLower(selectedExt))) {
            MsgBox("Please choose a image file.")
            return
        }
        App["image-anchor-filepath"].Value := selectedFile

        CoordMode "Pixel", "Screen"
        foundScreen := ImageSearch(&foundXScreen, &foundYScreen, 0, 0, A_ScreenWidth, A_ScreenHeight , selectedFile)
        CoordMode "Pixel", "Client"
        ImageSearch(&foundXClient, &foundYClient, 0, 0, A_ScreenWidth, A_ScreenHeight, selectedFile)
        if (!foundScreen) {
            MsgBox("Image not found.", AppWindowTitle, "T1")
            anchorPos.set({ Screen: { x: 0, y: 0 }, Client: { x: 0, y: 0 } })
            return
        }

        anchorPos.set({ 
            Screen: { x: foundXScreen, y: foundYScreen }, 
            Client: { x: foundXClient, y: foundYClient } 
        })
    }

    App.defineDirectives(
        "@use:label-text", "xs10 yp+25 w60 h20 0x200",
        "@use:edit-long", "x+10 w250 h20 ReadOnly"
    )

    return (
        StackBox(App,
            {
                name: "window-info",
                fontOptions: "s10 bold",
                groupbox: {
                    title: "Window Info",
                    options: "vwindow-info-stackbox Section w345 h160"
                }
            },
            () => [
                App.AddText("@use:label-text", "Win Title:"),
                App.AddEdit("@use:edit-long",  "{1}", curWindowInfo, ["winTitle"]),
                App.AddText("@use:label-text", "Win Class:"),
                App.AddEdit("@use:edit-long",  "ahk_class {1}", curWindowInfo, ["ahkClass"]),
                App.AddText("@use:label-text", "Win Exe:"),
                App.AddEdit("@use:edit-long",  "ahk_exe {1}", curWindowInfo, ["ahkExe"]),
                App.AddText("@use:label-text", "Win PID:"),
                App.AddEdit("@use:edit-long",  "ahk_pid {1}", curWindowInfo, ["ahkPid"]),
                App.AddText("@use:label-text", "Win ID:"),
                App.AddEdit("@use:edit-long",  "ahk_id {1}", curWindowInfo, ["ahkId"]),
            ]
        ),

        StackBox(App,
            {
                name: "current-mouse-pos",
                fontOptions: "s10 bold",
                groupbox: {
                    title: "Mouse Position",
                    options: "Section @align[xw]:window-info-stackbox y+5 h110"
                }
            },
            () => [
                ; Screen
                App.AddText("xs10 yp+25 w60 h20 0x200", "Screen:"),
                App.AddEdit("@use:edit-long", "{1}, {2}", curMouseInfo, [v => v.Screen.x, v => v.Screen.y]),

                ; Client
                App.AddText("xs10 yp+25 w60 h20 0x200", "Client:"),
                App.AddEdit("@use:edit-long", "{1}, {2}", curMouseInfo, [v => v.Client.x, v => v.Client.y]),

                ; color
                App.AddText("xs10 yp+25 w50 h20 0x200", "Color: "),
                App.AddText("vcolor-indicator x+0 w20 h20 0x200", "■"),
                App.AddEdit("@use:edit-long x+0", "{1}", curMouseInfo, ["color"]),                
            ]
        ),

        StackBox(App,
            {
                name: "anchoring-distance",
                fontOptions: "s10 bold",
                groupbox: {
                    title: "Anchoring / Distance",
                    options: "Section @align[xw]:window-info-stackbox y+5 h250"
                }    
            },
            () => [
                App.AddText("@use:label-text", "Screen:"), 
                App.AddEdit("x+10 w80 ReadOnly", "{1}, {2}", anchorPos, [v => v.Screen.x, v => v.Screen.y]),
                App.AddText("x+30 w50 h20 0x200", "Client:"), 
                App.AddEdit("x+10 w80 ReadOnly", "{1}, {2}", anchorPos, [v => v.Client.x, v => v.Client.y]),

                ; relative distance
                App.AddText("@use:label-text" . " yp+30", "Distance:"),
                App.AddEdit("@use:edit-long", "x {1}, y {2}", distance, ["x", "y"]),

                ; anchor types
                App.AddText("xs10 yp+35 w150 h20 0x200", "Anchor Type").SetFont("s9 bold"),
                
                ; mouse pos anchor
                App.AddRadio("vuse-mouse-pos-anchor xs10 yp+30 w180 h20 Checked", "Use mouse position").onClick(handleAnchorTypeToggling),
                
                ; image anchor
                App.AddRadio("vuse-image-anchor xs10 yp+25 w80 h20", "Use image").onClick(handleAnchorTypeToggling),
                App.AddEdit("vimage-anchor-filepath x+10 h20 w145 Disabled", ""),
                App.AddButton("vchoose-image-anchor-btn x+10 h20 w80 Disabled", "Choose File").onClick(handleSelectImageAnchor),

                ; move to anchor
                App.AddText("xs10 yp+35 w150 h20 0x200", "Move to anchor").SetFont("s9 bold"),
                App.AddText("xs10 yp+25 w80 h20 0x200", "Coord Mode:"),
                App.AddRadio("x+10 w75 h20 Checked", "Screen").onClick((ctrl, _) => curMouseCoordMode.set(ctrl.Text)),
                App.AddRadio("x+0 w75 h20", "Client").onClick((ctrl, _) => curMouseCoordMode.set(ctrl.Text)),
                App.AddButton("x+5 h20 w80", "Move").onClick(moveToAnchor)
            ]
        )
    )
}