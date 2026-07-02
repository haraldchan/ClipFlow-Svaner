class WSMessageParser {
    static dict := useDict()
    static identifier := "3ed542123e774d45203ff60175cb614e" ; MD5 hash: ProfileModifyNextLocal

    static idTypes := Map(
        "11", "身份证",
        "14", "普通护照",
        "93", "国内护照",
        "16", "台湾居民来往大陆通行证",
        "60", "港澳居民来往内地通行证",
        "56", "港澳居民来往内地通行证（非中国籍）"
    )

    static b64Prefix := "data:image/jpeg;base64,"
    static uncPicFolder := UNC_PATH . "\01 FO PASSPORT SCANNING"
    static localPicFolder := A_MyDocuments . "\01 FO PASSPORT SCANNING"

    static capture(identifier) {
        if (!InStr(A_Clipboard, identifier)) {
            return
        }

        incoming := JSON.parse(A_Clipboard, , false)
        if (incoming is Error) {
            msgbox incoming.Message
        }

        ; saves pic (async)
        SetTimer(() => this.savePics(incoming), -1)

        ; sends profiles to db
        switch incoming.guestType {
            case "内地旅客":
                A_Clipboard := this.parseMainlandTraveler(incoming)
            case "港澳台旅客":
                A_Clipboard := this.parseHkMoTwTraveler(incoming)
            case "国外旅客":
                A_Clipboard := this.parseForeignTraveler(incoming)
        }
    }

    static savePics(incoming) {
        if (!DirExist(this.localPicFolder)) {
            DirCreate(this.localPicFolder)
        }

        saveFolder := Format(
            "{1}\{2} {3}{4}",
            DirExist(this.uncPicFolder) ? this.uncPicFolder : this.localPicFolder,
            FormatTime(A_Now, "yyyy-MM-dd"),
            incoming.roomNum ? incoming.roomNum : " ",
            incoming.data.name ? incoming.data.name : ""
        )

        if (!DirExist(saveFolder)) {
            DirCreate(saveFolder)
        }

        ; save profile pic
        this.base64ToFile(
            StrReplace(incoming.data.curPhoto, this.b64Prefix, ""), 
            Format("{1}\{2}-{3}.jpg", saveFolder, incoming.roomNum . incoming.name, "head")
        )

        ; save scanned pic 
        passportImgKey := match(incoming.data, Map(
            i => i.HasOwnProp("photo"), incoming.data.photo,
            i => i.HasOwnProp("ocrPhoto"), incoming.data.ocrPhoto,
        ), "")
        ; only save when passport is available(scan mode)
        if (passportImgKey) {
            this.base64ToFile(
                StrReplace(incoming.data.%passportImgKey%, this.b64Prefix, ""),
                Format("{1}\{2}-{3}.jpg", saveFolder, incoming.roomNum . incoming.name, "scan")
            )
        }
    }

    static parseMainlandTraveler(incoming) {
        guestProfile := {
            idendifier: ProfileModifyNext.identifier,
            addr: incoming.data.address,
            birthday: incoming.data.birthday,
            gender: incoming.data.sex == "1" ? "男" : "女",
            guestType: "内地旅客",
            idNum: incoming.data.cardNo,
            idType: this.idTypes[incoming.idType],
            isMod: false,
            name: incoming.data.name,
            roomNum: incoming.roomNum,
            tel: incoming.tel,
            tsId: incoming.tsId,
            ; wsData: incoming.data
        }

        return JSON.stringify(guestProfile)
    }

    static parseHkMoTwTraveler(incoming) {
        guestProfile := {
            idendifier: ProfileModifyNext.identifier,
            addr: " ",
            birthday: incoming.data.birthday,
            gender: incoming.data.sex == "1" ? "男" : "女",
            guestType: "港澳台旅客",
            idNum: incoming.data.cardNo,
            idType: this.idTypes[incoming.idType],
            isMod: false,
            name: incoming.data.name,
            nameLast: incoming.data.lastName,
            nameFirst: incoming.data.firstName,
            region: incoming.region,
            roomNum: incoming.roomNum,
            tel: incoming.tel,
            tsId: incoming.tsId,
            ; wsData: incoming.data
        }

        return JSON.stringify(guestProfile)
    }

    static parseForeignTraveler(incoming) {
        guestProfile := {
            idendifier: ProfileModifyNext.identifier,
            addr: incoming.region,
            country: incoming.region,
            birthday: incoming.data.birthday,
            gender: incoming.data.sex == "1" ? "男" : "女",
            guestType: incoming.guestType,
            idNum: incoming.data.cardNo,
            idType: this.idTypes[incoming.idType],
            isMod: false,
            name: Format("{1}, {2}", incoming.data.lastName, incoming.data.firstName),
            nameFirst: incoming.data.firstName,
            nameLast: incoming.data.lastName,
            roomNum: incoming.roomNum,
            tel: incoming.tel,
            tsId: incoming.tsId,
            ; wsData: incoming.data
        }

        return JSON.stringify(guestProfile)
    }

    /**
     * Saves scanned images/passport photo
     * @param {String} base64String 
     * @param {String} outputPath 
     */
    static base64ToFile(base64, outputPath) {
        static CRYPT_STRING_BASE64 := 0x00000001
        static CRYPT_STRING_ANY := 0x00000007

        ; Ask Windows how many bytes are needed.
        cbBinary := 0
        if (!DllCall(
            "Crypt32\CryptStringToBinaryW",
            "Str", base64,
            "UInt", 0,                    ; auto length
            "UInt", CRYPT_STRING_ANY,     ; accept common Base64 formats
            "Ptr", 0,
            "UInt*", &cbBinary,
            "Ptr", 0,
            "Ptr", 0,
            "Int"
        )) {
            throw OSError(A_LastError)
        }

        ; Allocate buffer.
        buf := Buffer(cbBinary)

        ; Decode into the buffer.
        if (!DllCall(
            "Crypt32\CryptStringToBinaryW",
            "Str", base64,
            "UInt", 0,
            "UInt", CRYPT_STRING_ANY,
            "Ptr", buf,
            "UInt*", &cbBinary,
            "Ptr", 0,
            "Ptr", 0,
            "Int"
        )) {
            throw OSError(A_LastError)
        }

        ; Write to file.
        f := FileOpen(outputPath, "w")
        f.RawWrite(buf, cbBinary)
        f.Close()
    }
}