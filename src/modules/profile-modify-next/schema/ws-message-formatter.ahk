class WSMessageParser {
    static dict := useDict()
    static identifier := "3ed542123e774d45203ff60175cb614e" ; MD5 hash: ProfileModifyNextLocal

    static guestTypes := Map(
        "100", "内地旅客",
        "200", "港澳台旅客",
        "300", "国外旅客",
    )

    static parseIdType(code) {
        return match(code, Map(
            "11", "身份证",
            "14", "普通护照",
        ))
    }

    static capture(identifier) {
        if (!InStr(A_Clipboard, identifier)) {
            return
        }

        incoming := JSON.parse(A_Clipboard, , false)
        if (incoming is Error) {
            msgbox incoming.Message
        }

        switch incoming.data.guestType {
            case "100":
                msgbox this.parseMainlander(incoming)
            case "300":
                msgbox this.parseForeignTraveler(incoming)
        }
    }

    static parseMainlander(incoming) {
        guestProfile := {
            idendifier: ProfileModifyNext.identifier,
            addr: incoming.data.address,
            birthday: incoming.data.birthday,
            gender: incoming.data.sex == "1" ? "男" : "女",
            guestType: this.guestTypes[incoming.data.guestType],
            idNum: incoming.data.cardNo,
            idType: this.parseIdType(incoming.data.cardType) || "IDC",
            isMod: false,
            name: incoming.data.name,
            roomNum: incoming.roomNum,
            tel: incoming.tel,
            tsId: incoming.tsId,
            wsData: incoming.data
        }

        return JSON.stringify(guestProfile)
    }

    static parseForeignTraveler(incoming) {
        guestProfile := {
            idendifier: ProfileModifyNext.identifier,
            addr: this.dict.getCountryCodeAlpha3(incoming.data.nationalityArea),
            birthday: incoming.data.birthday,
            gender: incoming.data.sex == "1" ? "男" : "女",
            guestType: this.guestTypes[incoming.data.guestType],
            idNum: incoming.data.cardNo,
            idType: this.parseIdType(incoming.data.cardType) || "NOP",
            isMod: false,
            name: Format("{1}, {2}", incoming.data.lastName, incoming.data.firstName),
            nameFirst: incoming.data.firstName,
            nameLast: incoming.data.lastName,
            roomNum: incoming.roomNum,
            tel: incoming.tel,
            tsId: incoming.tsId,
            wsData: incoming.data
        }

        return JSON.stringify(guestProfile)
    }
}