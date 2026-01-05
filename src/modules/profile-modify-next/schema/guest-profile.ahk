ProfileMainland := Struct({
    addr:       String,
    birthday:   String,
    fileName:   String,
    gender:     ["男", "女"],
    guestType:  ["内地旅客"],
    idNum:      String,
    idType:     String,
    identifier: String,
    isMod:      [1, 0],
    name:       String,
    regTime:    String,
    roomNum:    String,
    tel:        String,
    tsId:       String
})

ProfileHkMoTw := Struct({
    birthday:   String,
    fileName:   String,
    gender:     ["男", "女"],
    guestType:  ["港澳台旅客"],
    idNum:      String,
    idType:     String,
    identifier: String,
    isMod:      [1, 0],
    name:       String,
    nameFirst:  String,
    nameLast:   String,
    regTime:    String,
    region:     ["香港", "澳门", "台湾"],
    roomNum:    String,
    tel:        String,
    tsId:       String
})

ProfileAbroad := Struct({
    addr:       String,
    birthday:   String,
    country:    String,
    fileName:   String,
    gender:     ["男", "女"],
    guestType:  ["国外旅客"],
    idNum:      String,
    idType:     String,
    identifier: String,
    isMod:      [1, 0],
    name:       String,
    nameFirst:  String,
    nameLast:   String,
    regTime:    String,
    roomNum:    String,
    tel:        String,
    tsId:       String
})