/**
 * @param {Svaner} App
 */
ClipboardListeners(App) {
    OnClipboardChange((*) => DepositEntry.copyFromMipay(App["deposit-entry-on"]), -1)
    OnClipboardChange((*) => App["hello-world"].Value && MsgBox("Hello World!"), -1)

    return (
        StackBox(
            App, 
            {
                name: "clipboard-listeners",
                groupbox: {
                    title: "监听器",
                    options: "vclipboard-listeners-gb Section @align[xw]:service-configs @relative[y+10]:service-configs h216"
                }
            },
            () => [
                App.AddCheckBox("vdeposit-entry-on xs20 yp+30 w180 Checked", "监听: 绿云复制卡号"),
                App.AddCheckBox("vhello-world xs20 yp+25 w180", "监听: hello world(测试用)"),
            ]
        )
    )
}