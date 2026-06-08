UnifiedAgentModal(clickEvent) {
	MM := Gui("+AlwaysOnTop", "Unified Agent")
	MM.SetFont("s10", "微软雅黑")
	MM.BackColor := "White"

	msg := "Profile Modify 代行服务运行中...`n`n1.按下 Ctrl+Alt+Del 解锁键鼠`n2.点击确定停止服务"

	onClick(*) {
		clickEvent()
		MM.Destroy()
	}

	render() {
		MM.AddText("x20 yp+20 w280 h100", msg)
		MM.AddText("x20 y+0 w320 h5 0x10", "")
		MM.AddButton("x230 y+10 w100 h35 Default", "确 定").OnEvent("Click", onClick)
		MM.AddText("x10 y+10 w300 h5 ", "")

		MM.Show()
	}

	return render()
}