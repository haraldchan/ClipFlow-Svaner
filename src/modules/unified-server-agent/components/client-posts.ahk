/**
 * @param {Svaner} App 
 * @param {Integer} enabled 
 */
ClientPosts(App, enabled) {
    comp := Component(App, A_ThisFunc)

    postQueue := signal([{ status: "", time: "", id: "" }])
    
    postStatus := Map(
        "PENDING", "已发送",
        "COLLECTED", "处理中",
        "MODIFIED", "已完成",
        "ABORTED", "错误终止",
        "RETRY", "重试中",
        "RESENT", "已重发",
        "ABANDONED", "超时弃用",
        "NOTFOUND", "无效房号",
        "PING", "连接中",
        "ONLINE", "在线"
    )

    connection := signal("未连接")
    statusTextStyle := Map(
        "未连接", "cBlack Norm",
        "连接中...", "cBlack Norm",
        "无响应", "cRed Bold",
        "default", "cGreen Bold"
    )

    ping(ctrl, _) {
        connection.set("连接中...")
        ctrl.Enabled := false
        
        res := agent.PING()
        connection.set(!res ? "无响应" : Format("在线 {1}", res.sender))
        
        ctrl.Enabled := true
    }

    handlePostUpdate(*) {
        posts := []
        showMyOwnPosts := App["show-my-own-posts"].Value
        
        ; check pmn posts
        loop files (agent.pool . "\*.json") {
            if (A_LoopFileName.includes("PING") || A_LoopFileName.includes("ONLINE")) {
                continue
            }

            if (showMyOwnPosts && !A_LoopFileName.includes(A_ComputerName)) {
                continue
            }

            status := StrSplit(A_LoopFileName, "==")[1]
            post := JSON.parse(FileRead(A_LoopFileFullPath, "UTF-8"))
            post["status"] := postStatus[status]
            post["time"] := FormatTime(post["id"].substr(1, 14), "yyyy/MM/dd HH:mm")
            post["action"] := "Profile"

            posts.InsertAt(1, post)
        }

        ; check qm posts
        loop files (agent.qmPool . "\*.json") {
            if (showMyOwnPosts && !A_LoopFileName.includes(A_ComputerName)) {
                continue
            }                

            status := StrSplit(A_LoopFileName, "==")[1]
            post := JSON.parse(FileRead(A_LoopFileFullPath, "UTF-8"))
            post["status"] := postStatus[status]
            post["time"] := FormatTime(post["id"].substr(1, 14), "yyyy/MM/dd HH:mm")
            post["action"] := match(post["content"]["module"], Map(
                "BlankShare", "Share",
                "PaymentRelation", "PayBy PayFor",
                "DepositEntry", "Auth"
            ))
            posts.InsertAt(1, post)
        }     

        if (posts.Length != 0) {
            postQueue.set(posts)
            App["post-list"].ModifyCol(3, "SortDesc")
        } else {
            postQueue.reset()
        }
    }
    
    showPostDetails(LV, row, *) {
        if (row == 0 || row > 10000 || LV.GetText(row, 1) == "连接中") {
            return
        }

        selectedPost := postQueue.value.find(post => post["id"] == LV.GetText(row, 4))
        
        switch selectedPost["action"] {
            case "Profile":
                PostDetails_Profile(selectedPost)
            case "PayBy PayFor":
                form := selectedPost["content"]["form"]
                PostDetails_QM2(selectedPost, "PaymentRelation", {
                    style: { xyPos: "xs10 y+10" },
                    form : {
                        pfRoom: form["pfRoom"],
                        pfName: form["pfName"],
                        party:  form["party"],
                        partyRoomQty: form["partyRoomQty"],
                        pbRoom: form["pbRoom"],
                        pbName: form["pbName"]
                    }
                })
            case "Share": 
                form := selectedPost["content"]["form"]
                PostDetails_QM2(selectedPost, "BlankShare", {
                    styles: {
                    },
                    form : {
                        shareRoomNums: form["shareRoomNums"],
                        shareQty: form["shareQty"],
                        checkIn: form["checkIn"]
                    }
                })
            case "Auth":
                form := JSON.parse(JSON.stringify(selectedPost["content"]["form"]),, false)
                PostDetails_QM2(selectedPost, "DepositEntry",{
                    depositInfo: form,
                    style: { xyPos: "xs10 y+10" },
                })
            default:
                return
        }
    }

    comp.render := this => this.Add(
        StackBox(
            App,
            {
                name: "client-posts-stackbox",
                groupbox: {
                    options: "vsap-agent-gb Section x350 @align[y]:service-configs w350 h400"
                },
                checkbox: {
                    title: "客户端（前台）选项",
                    options: (enabled ? "Checked" : "") . " xs10 yp",
                    events: {
                        click: (ctrl, _) => CONFIG.write("clientEnabled", ctrl.Value)
                    }
                }, 
            },
            () => [
                ; test connection
                App.AddButton("xs20 w60 h30 yp+30", "测试连接").onClick(ping),
                App.AddText("x+5 h30 0x200", "服务状态: "),
                App.AddText("vstatus-text w150 h30 x+1 0x200", "{1}", connection).SetFontStyles(statusTextStyle),

                ; post status list
                App.AddText("xs20 yp+50 h20 0x200", "已发送代行状态").SetFont("Bold"),
                App.AddButton("x+5 h20 w20 +Center", "↻")
                   .onClick(handlePostUpdate)
                   .SetFont("bold"),
                App.AddCheckBox("vshow-my-own-posts Checked x+140 h20", "本机发送"),
                App.AddListView(
                    { lvOptions: "vpost-list Grid -Multi LV0x4000 w320 h280 xs20 yp+25" }, 
                    {
                        keys: ["status", "action", "time", "id"],
                        titles: ["当前状态", "代行类型", "发送时间", "POST ID"],
                        widths: [60, 100, 150, 170]
                    }, 
                    postQueue
                ).onContextMenu(showPostDetails)
            ]
        )
    )

    return (
        comp.render(), 
        handlePostUpdate()
    )
}
