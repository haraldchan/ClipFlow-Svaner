/**
 * @param {Svaner} App
 * @param {signal} isDelegate
 * @param {signal} listContent
 */
SentPosts(App, isDelegate, listContent) {
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

    effect([isDelegate, listContent], handlePostListUpdate)
    handlePostListUpdate(curIsDelegate, curListContent) {
        if (!curIsDelegate) {
            return
        }

        if (curListContent.Length && curListContent[1]["roomNum"] == "Loading...") {
            return
        }

        posts := []
        showMyOwnPosts := App["sent-posts-show-my-own-posts"].Value
        
        ; check pmn posts
        loop files (agent.pool . "\*.json") {
            if (A_LoopFileName.includes("PING") || A_LoopFileName.includes("ONLINE")) {
                continue
            }

            if (showMyOwnPosts && !A_LoopFileName.includes(A_ComputerName)) {
                continue
            }

            status := StrSplit(A_LoopFileName, "==")[1]
            try {
                post := JSON.parse(FileRead(A_LoopFileFullPath, "UTF-8"))
            }
            catch {
                continue
            }

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
            try {
                post := JSON.parse(FileRead(A_LoopFileFullPath, "UTF-8"))
            }
            catch {
                continue
            }

            post["status"] := postStatus[status]
            post["time"] := FormatTime(post["id"].substr(1, 14), "yyyy/MM/dd HH:mm")
            post["action"] := match(post["content"]["module"], Map(
                "BlankShare", "Share",
                "PaymentRelation", "PayBy PayFor",
                "DepositEntry", "Auth"
            ))
            posts.InsertAt(1, post)
        }     

        if (posts.Length) {
            postQueue.set(posts)
            App["sent-post-list"].ModifyCol(3, "SortDesc")
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
                    form: {
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
                    form: {
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
        App.AddText("vsent-posts-title x530 @align[y]:guest-profile-list h20 0x200", "已发送代行")
           .SetFont("bold"),
        App.AddCheckBox("vsent-posts-show-my-own-posts Checked xp+120 h20 w60", "本机"),
        App.AddListView(
            {
                lvOptions: "vsent-post-list Grid -Multi LV0x4000 @align[x]:sent-posts-title yp+25 w170 h295"
            },
            {
                keys: ["status", "action", "time", "id"],
                titles: ["当前状态", "代行类型", "发送时间", "POST ID"],
                widths: [60, 100, 150, 170]
            }, 
            postQueue
        ).onContextMenu(showPostDetails)
    )

    return comp.render()
}
