class RH_Models {
    ; FedEx list fields for reservation details
    static fedexListFields := OrderedMap(
        "resvType", "订单类型",
        "crewNames", "机组姓名",
        "tripNum", "Trip No.",
        "roomQty", "订房数量",
        "ciDate", "入住日期",
        "flightIn", "预抵航班",
        "ETA", "入住时间",
        "coDate", "退房日期",
        "flightOut", "离开航班",
        "ETD", "退房时间",
        "stayHours", "在住时长",
        "daysActual", "计费天数",
        "tracking", "Tracking 单号",
    )
    
    ; OTA list fields for reservation details
    static otaListFields := OrderedMap(
        "agent", "来源 OTA",
        "orderId", "订单号",
        "payment", "支付方式",
        "packages", "包含套餐",
        "guestNames", "住客姓名",
        "roomType", "房间类型",
        "roomQty", "房间数量",
        "ciDate", "入住日期",
        "coDate", "退房日期",
        "roomRates", "房价构成",
        "bbf", "含早情况",
        "remarks", "其他备注",
    )
}