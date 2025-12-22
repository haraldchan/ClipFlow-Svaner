#SingleInstance Force
#Include "./use-dict.ahk"
#Include "../Svaner/useSvaner.ahk"

/**
 * @param {Svaner} App 
 */
UseDictTest(App) {
    dict := useDict()

    fullname := signal({ last: "", first: "" })
    handlePinyinConvert(*) {
        hanziName := App["hanzi-name"].Value.trim()
        if (!hanziName) {
            return
        }

        convertType := App["pinyin-type"].Text
        converted := match(convertType, Map(
            "汉语拼音", dict.getFullnamePinyin(hanziName),
            "威妥玛拼音（台）", dict.getFullnamePinyin(hanziName, true),
            "广东话拼音（港）", dict.getFullnamePinyinCantonese(hanziName)
        ))

        fullname.set({ last: converted[1], first: converted[2] })
    }

    region := signal("")
    handleRegionConvert(*) {
        regionName := App["region-name"].Value.trim()
        if (!regionName) {
            return
        }

        region.set(dict.getCountryCode(regionName))
    }

    province := signal("")
    handleProvinceConvert(*) {
        address := App["address"].Value.trim()
        if (!address) {
            return
        }

        converted := IsNumber(address) ? dict.getProvinceById(address) : dict.getProvince(address)
        province.set(converted)
    }

    idType := signal("")
    handleidTypeConvert(*) {
        idTypeInput := App["id-type"].Value.trim()
        if (!idTypeInput) {
            return
        }

        idType.set(dict.getIdTypeCode(idTypeInput))
    }


    return (
        StackBox(
            App, 
            {
                fontOptions: "bold",
                groupbox: {
                    title: "拼音转换",
                    options: "vpinyin-name Section w230 r6"
                },
            },
            () => [
                App.AddDDL("vpinyin-type xs10 yp+20 w210 Choose1", ["汉语拼音", "威妥玛拼音（台）", "广东话拼音（港）"]),
                App.AddText("xs10 y+5 w70 h25 0x200", "请输入全名："),
                App.AddEdit("vhanzi-name x+1 w140 h25", ""),
                App.AddText("xs10 y+5 w70 h25 0x200", "转换后拼音："),
                App.AddEdit("x+1 w140 h25 ReadOnly", "{1} {2}", fullname, ["last", "first"]),
                App.AddButton("xs10 y+10 w210 h25", "转换拼音").onClick(handlePinyinConvert)
            ]
        ),
        StackBox(
            App,
            {
                fontOptions: "bold",
                groupbox: {
                    title: "地区代码（ISO 3166-1 alpha-2）",
                    options: "vcountry-code Section @align[x]:pinyin-name y+5 w230 r4"
                },
            },
            () => [
                App.AddText("xs10 yp+20 w70 h25 0x200", "地区名称："),
                App.AddEdit("vregion-name x+1 w70 h25", ""),
                App.AddEdit("x+1 w70 h25 ReadOnly", "{1}", region),
                App.AddButton("xs10 y+10 w210 h25", "转换地区").onClick(handleRegionConvert)
            ]
        ),
        StackBox(
            App,
            {
                fontOptions: "bold",
                groupbox: {
                    title: "省份代码",
                    options: "vprovince-code Section @align[x]:pinyin-name y+5 w230 r4"
                },
            },
            () => [
                App.AddText("xs10 yp+20 w70 h25 0x200", "地址/身份证："),
                App.AddEdit("vaddress x+1 w70 h25", ""),
                App.AddEdit("x+1 w70 h25 ReadOnly", "{1}", province),
                App.AddButton("xs10 y+10 w210 h25", "转换地址").onClick(handleProvinceConvert)
            ]   
        ),
        StackBox(
            App,
            {
                fontOptions: "bold",
                groupbox: {
                    title: "证件类型",
                    options: "Section @align[x]:pinyin-name y+5 w230 r4"
                },
            },
            () => [
                App.AddText("xs10 yp+20 w70 h25 0x200", "证件类型："),
                App.AddEdit("vid-type x+1 w70 h25", ""),
                App.AddEdit("x+1 w70 h25 ReadOnly", "{1}", idType),
                App.AddButton("xs10 y+10 w210 h25", "获取证件类型").onClick(handleidTypeConvert)
            ]   
        ),
        App.Show()
    )
}


UseDictTest(Svaner({
    gui: {
        title: "use dict test"
    },
    font: {
        name: "微软雅黑",
    },
    events: {
        close: this => this.Destroy()
    }
}))