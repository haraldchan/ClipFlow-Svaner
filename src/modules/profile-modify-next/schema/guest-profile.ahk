/**
 * @typedef {Object} ProfileMainland
 * @property {String}  addr
 * @property {String}  birthday
 * @property {String}  fileName
 * @property {"男" | "女"}  gender
 * @property {"内地旅客"}  guestType
 * @property {String}  idNum
 * @property {String}  idType
 * @property {String}  identifier
 * @property {true | false}  isMod
 * @property {String}  name
 * @property {String}  regTime
 * @property {String}  roomNu
 * @property {String}  tel
 * @property {String}  tsId 
 */

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

/**
 * @typedef {Object} ProfileHkMoTw
 * @property {String} birthday
 * @property {String} fileName
 * @property {} gender
 * @property {} guestType
 * @property {String} idNum
 * @property {String} idType
 * @property {String} identifier
 * @property {true | false} isMod
 * @property {String} name
 * @property {String} nameFirst
 * @property {String} nameLast
 * @property {String} regTime 
 * @property {"香港" | "澳门" | "台湾"} region
 * @property {String} roomNum
 * @property {String} tel
 * @property {String} tsId
 */

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

/**
 * @typedef {Object} ProfileAbroad
 * @property {String} addr
 * @property {String} birthday
 * @property {String} country
 * @property {String} fileName
 * @property {"男" | "女"} gender
 * @property {"国外旅客"} guestType
 * @property {String} idNum
 * @property {String} idType
 * @property {String} identifier
 * @property {true | false} isMod
 * @property {String} name
 * @property {String} nameFirst
 * @property {String} nameLast
 * @property {String} regTime
 * @property {String} roomNum
 * @property {String} tel
 * @property {String} tsId
 */

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