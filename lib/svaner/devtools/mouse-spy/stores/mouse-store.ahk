mouseStore := useStore("mouseStore", {
    states: {
        curMouseCoordMode: "Screen",
        curMouseInfo: {
            Screen: { x: 0, y: 0 },
            Client: { x: 0, y: 0 },
            window: WinExist("A"),
            control: 0,
            color: "0xFFFFFF"
        },
        followMouse: true,
        anchorPos: { Screen:{ x: 0, y: 0 }, Client: { x: 0, y: 0 } }
    },
    methods: {
        updater: (this) => this.curMouseInfo.set(this.useMethod("handleMousePosUpdate")()),
        handleMousePosUpdate: (this) => (
            CoordMode("Mouse", "Screen"),
            MouseGetPos(&initScreenX, &initScreenY, &window, &control),
            CoordMode("Pixel", "Screen"),
            CoordMode("Mouse", "Client"),
            MouseGetPos(&initClientX, &initClientY),
            ; return 
            WinGetTitle(window) == "MouseSpy" 
                ? this.curMouseInfo.value 
                : {
                    Screen: { x: Integer(initScreenX), y: Integer(initScreenY) },
                    Client: { x: Integer(initClientX), y: Integer(initClientY) },
                    window: window,
                    control: control,
                    color: PixelGetColor(initScreenX, initScreenY)
                }
        ),
        moveToAnchor: (this, params*) => (
            CoordMode("Mouse", this.curMouseCoordMode.value),
            MouseMove(this.anchorPos.value[A_CoordModeMouse]["x"], this.anchorPos.value[A_CoordModeMouse]["y"])
        )
    }
})