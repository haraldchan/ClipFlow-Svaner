class WSMessageParser {
    static dict := useDict()
    static identifier := "3ed542123e774d45203ff60175cb614e" ; MD5 hash: ProfileModifyNextLocal

    static capture(identifier) {
        if (!InStr(A_Clipboard, identifier)) {
            return
        }

        incoming := JSON.parse(A_Clipboard, , false)
        if (incoming is Error) {
            msgbox incoming.Message
        }

        switch incoming.guestType {
            case "内地旅客":
                msgbox this.parseMainlandTraveler(incoming)
            case "港澳台旅客":
            case "国外旅客":
                msgbox this.parseForeignTraveler(incoming)
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
            idType: incoming.idType,
            isMod: false,
            name: incoming.data.name,
            roomNum: incoming.roomNum,
            tel: incoming.tel,
            tsId: incoming.tsId,
            wsData: incoming.wsData
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
            idType: incoming.idType,
            isMod: false,
            name: incoming.data.name,
            nameLast: incoming.data.lastName,
            nameFirst: incoming.data.firstName,
            region: incoming.region,
            roomNum: incoming.roomNum,
            tel: incoming.tel,
            tsId: incoming.tsId,
            wsData: incoming.wsData
        }

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
            idType: incoming.idType,
            isMod: false,
            name: Format("{1}, {2}", incoming.data.lastName, incoming.data.firstName),
            nameFirst: incoming.data.firstName,
            nameLast: incoming.data.lastName,
            roomNum: incoming.roomNum,
            tel: incoming.tel,
            tsId: incoming.tsId,
            wsData: incoming.wsData
        }

        return JSON.stringify(guestProfile)
    }
}