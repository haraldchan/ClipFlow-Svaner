class useDict {
    __New() {
        this.DICT_PATH := InStr(A_ScriptName, "use-dict-test") ? "./dictionaries" : A_ScriptDir . "\lib\use-dict\dictionaries"

        this.pinyin := JSON.parse(FileRead(this.DICT_PATH . "\pinyin.json", "UTF-8"))

        this.pinyinWade := JSON.parse(FileRead(this.DICT_PATH . "\pinyin-wade.json", "UTF-8"))

        this.doubleLastName := JSON.parse(FileRead(this.DICT_PATH . "\double-last-name.json", "UTF-8"))

        this.phoneticMap := Map(
            "a", ["ā", "á", "ǎ", "à"],
            "e", ["ē", "é", "ě", "è"],
            "i", ["ī", "í", "ǐ", "ì"],
            "o", ["ō", "ó", "ǒ", "ò"],
            "u", ["ū", "ú", "ǔ", "ù"],
        )

        this.regionISO := JSON.parse(FileRead(this.DICT_PATH . "\region-iso.json", "UTF-8"))
        this.regionISO.Default := ""

        list := JSON.parse(FileRead(this.DICT_PATH . "\iso-3166-1.json", "UTF-8"))
        this.regionISOalpha3 := Map(list.map(region => [region["alpha3"], region["nameCN"]]).flat()*)
        this.regionISOalpha3.Default := ""

        this.provinces := JSON.parse(FileRead(this.DICT_PATH . "\provinces.json", "UTF-8"))
        this.provinces.Default := ""
        this.provincesById := JSON.parse(FileRead(this.DICT_PATH . "\province-by-id.json", "UTF-8"))
        this.provincesById.Default := ""

        this.provinceWithCities := JSON.parse(FileRead(this.DICT_PATH . "\province-with-cities.json", "UTF-8"))
        this.provinceWithCities.Default := ""

        this.idTypes := JSON.parse(FileRead(this.DICT_PATH . "\id-types.json", "UTF-8"))
        this.provinceWithCities.Default := ""
    }

    /**
     * Convert a Hanzi character to pinyin.
     * @param {String} hanzi A chinese character to convert.
     * @param {Boolean} useWG Uses Wade-Giles instead of Pinyin.
     * @returns {String} 
     */
    getPinyin(hanzi, useWG := false) {
        for pinyin, hanCharacters in this.pinyin {
            if (hanCharacters.includes(hanzi)) {
                return useWG ? this.pinyinWade[pinyin] : pinyin 
            }
        }
        ; if not found in Dict, fetch from baidu hanyu
        return this.fetchPinyin(hanzi, useWG)
    }


    URIEncode(Url, Flags := 0x000C3000) {
        Local CC := 4096, Esc := "", Result := ""
        Loop {
            VarSetStrCapacity(&Esc, CC), Result := DllCall("Shlwapi.dll\UrlEscapeW", "Str", Url, "Str", &Esc, "UIntP", &CC, "UInt", Flags, "UInt")
        } Until Result != 0x80004003 ; E_POINTER
        Return Esc
    }

    
    /**
     * Fetching pinyin of certain Hanzi from hanyu.baidu.com
     * @param {String} hanzi A chinese character to convert.
     * @param {Boolean} useWG Uses Wade-Giles instead of Pinyin.
     * @returns {String} 
     */
    fetchPinyin(hanzi, useWG := false) {
        ; 360国学 
        url := Format("https://guoxue.baike.so.com/query/view?type=word&title={1}", this.URIEncode(hanzi))
        
        whr := ComObject("WinHttp.WinHttpRequest.5.1")

        whr.Open("POST", url, false)
        whr.Send()
        whr.WaitForResponse()
        page := whr.ResponseText
        pinyinWithPhonetic := page.split('<span class="pinyin">')[2].split("</span>")[1].replaceThese(["[", "]"], "").trim()

        for char, charsWithPhonetic in this.phoneticMap {
            matchedPhoneticChar := charsWithPhonetic.find(c => pinyinWithPhonetic.includes(c))

            if (matchedPhoneticChar) {
                pinyinWithoutPhonetic := pinyinWithPhonetic.replace(matchedPhoneticChar, char)
            }
        }

        whr := ""

        ; update pinyin dictionary
        this.pinyin[pinyinWithoutPhonetic] := this.pinyin[pinyinWithoutPhonetic] . hanzi
        FileDelete(this.DICT_PATH . "\pinyin.json")
        FileAppend(JSON.stringify(this.pinyin), this.DICT_PATH . "\pinyin.json", "UTF-8")

        return useWG ? this.pinyinWade[pinyinWithoutPhonetic] : pinyinWithoutPhonetic
    }


    /**
     * Fetching Cantonese pinyin of certain Hanzi from NameChef.co
     * @param hanzi A chinese character to convert.
     * @returns {Array<String>}
     */
    fetchPinyinCantonese(hanzi) {
        ; NameChef
        url := Format("https://www.namechef.co/zh/hkid-english-name/result/?name={1}", this.URIEncode(hanzi))
        romanised := []
        
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        html := ComObject("HTMLFile")

        whr.Open("POST", url, false)
        whr.Send()
        whr.WaitForResponse()
        page := whr.ResponseText
        

        html.Write(page)        
        tds := html.GetElementsByTagName("td")
        loop tds.Length {
            if (Mod(A_Index, 2)) {
                continue
            }

            romanised.Push(tds.item(A_Index - 1).InnerText.split(" ")[1])
        }

        whr := ""
        html := ""

        return romanised
    }


    /**
     * Convert the pinyin of last name and first name.
     * @param {String} fullname The name to convert.
     * @param {Boolean} useWG Uses Wade-Giles instead of Pinyin.
     * @returns {Array} [last name, first name]
     */
    getFullnamePinyin(fullname, useWG := false) {
        if (this.doubleLastName.Has(fullname.substr(1, 2))) {
            lastname := this.doubleLastName[fullname.substr(1, 2)]
            if (useWG) {
                lastname := lastname.split(" ").map(pinyin => this.pinyinWade[pinyin]).join("-")
            }
            lastnameLength := 2
        } else {
            lastname := this.getPinyin(fullname.substr(1, 1), useWG)
            lastnameLength := 1
        }

        firstName := fullname.substr(lastnameLength + 1)
                             .split("")
                             .map(hanzi => this.getPinyin(hanzi, useWG))
                             .join(useWG ? "-" : " ")

        return [lastname.trim(), firstname.trim()]
    }


    /**
     * Convert the Cantonese romanised of last name and first name.
     * @param {String} fullname The name to convert.
     * @returns {Array<String>} [lastname, firstname]
     */
    getFullnamePinyinCantonese(fullname) {
        fullNameRonamized := this.fetchPinyinCantonese(fullname)
        if (fullNameRonamized.includes("無法翻譯")) {
            fullnamePinyin := this.getFullnamePinyin(fullname)
            return [fullnamePinyin[1].trim(), fullnamePinyin[2].trim()]
        }

        if (this.doubleLastName.Has(fullname.substr(1, 2))) {
            lastname := fullNameRonamized[1] . " " . fullNameRonamized[2]
            firstname := fullNameRonamized[3] . " " . fullNameRonamized[4]
        } else {
            lastname := fullNameRonamized[1]
            firstname := fullNameRonamized.slice(2).join(" ")
        }

        return [lastname.trim(), firstname.trim()]
    }

    
    /**
     * Gets the ISO 3166-1 alpha-2 regional code.
     * @param {String} country The chinese country name to convert.
     * @returns {String} 
     */
    getCountryCode(country) => this.regionISO[country]
    getCountryCodeAlpha3(country) => this.regionISOalpha3[country]
    

    /**
     * Gets the province name by first 6 digits of CHN id.
     * @param {String} idNum 
     * @returns {String}
     */
    getProvinceById(idNum) => this.provincesById[idNum.substr(1, 2)]
    

    /**
     * Gets the province name by address
     * @param {String} address 
     * @returns {String} 
     */
    getProvince(address) {
        for province, code in this.provinces {
            if (address.includes(province)) {
                if (code != "") {
                    return code
                }
            }
        }

        for code, cities in this.provinceWithCities {
            for city in cities {
                if (address.includes(city)) {
                    return code
                }
            }
        }

        return false
    }


    /**
     * Gets the id type code with a given id type.
     * @param {String} idType 
     * @returns {String} returns idType code
     */
    getIdTypeCode(idType) {
        for k, v in this.idTypes {
            if (k == idType) {
                return v
            }
        }

        return false
    }
}
