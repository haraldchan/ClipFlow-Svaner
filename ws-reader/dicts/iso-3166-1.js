const nations = [
  {
    "alpha2":"AF",
    "alpha3":"AFG",
    "nameCN":" 阿富汗",
    "nameEN":"Afghanistan",
    "numeric":"004"
  },
  {
    "alpha2":"AX",
    "alpha3":"ALA",
    "nameCN":" 奥兰",
    "nameEN":"Åland Islands",
    "numeric":"248"
  },
  {
    "alpha2":"AL",
    "alpha3":"ALB",
    "nameCN":" 阿尔巴尼亚",
    "nameEN":"Albania",
    "numeric":"008"
  },
  {
    "alpha2":"DZ",
    "alpha3":"DZA",
    "nameCN":" 阿尔及利亚",
    "nameEN":"Algeria",
    "numeric":"012"
  },
  {
    "alpha2":"AS",
    "alpha3":"ASM",
    "nameCN":" 美属萨摩亚",
    "nameEN":"American Samoa",
    "numeric":"016"
  },
  {
    "alpha2":"AD",
    "alpha3":"AND",
    "nameCN":" 安道尔",
    "nameEN":"Andorra",
    "numeric":"020"
  },
  {
    "alpha2":"AO",
    "alpha3":"AGO",
    "nameCN":" 安哥拉",
    "nameEN":"Angola",
    "numeric":"024"
  },
  {
    "alpha2":"AI",
    "alpha3":"AIA",
    "nameCN":" 安圭拉",
    "nameEN":"Anguilla",
    "numeric":"660"
  },
  {
    "alpha2":"AQ",
    "alpha3":"ATA",
    "nameCN":"南极洲",
    "nameEN":"Antarctica",
    "numeric":"010"
  },
  {
    "alpha2":"AG",
    "alpha3":"ATG",
    "nameCN":" 安提瓜和巴布达",
    "nameEN":"Antigua and Barbuda",
    "numeric":"028"
  },
  {
    "alpha2":"AR",
    "alpha3":"ARG",
    "nameCN":" 阿根廷",
    "nameEN":"Argentina",
    "numeric":"032"
  },
  {
    "alpha2":"AM",
    "alpha3":"ARM",
    "nameCN":" 亚美尼亚",
    "nameEN":"Armenia",
    "numeric":"051"
  },
  {
    "alpha2":"AW",
    "alpha3":"ABW",
    "nameCN":" 阿鲁巴",
    "nameEN":"Aruba",
    "numeric":"533"
  },
  {
    "alpha2":"AU",
    "alpha3":"AUS",
    "nameCN":" 澳大利亚",
    "nameEN":"Australia",
    "numeric":"036"
  },
  {
    "alpha2":"AT",
    "alpha3":"AUT",
    "nameCN":" 奥地利",
    "nameEN":"Austria",
    "numeric":"040"
  },
  {
    "alpha2":"AZ",
    "alpha3":"AZE",
    "nameCN":" 阿塞拜疆",
    "nameEN":"Azerbaijan",
    "numeric":"031"
  },
  {
    "alpha2":"BS",
    "alpha3":"BHS",
    "nameCN":" 巴哈马",
    "nameEN":"Bahamas",
    "numeric":"044"
  },
  {
    "alpha2":"BH",
    "alpha3":"BHR",
    "nameCN":" 巴林",
    "nameEN":"Bahrain",
    "numeric":"048"
  },
  {
    "alpha2":"BD",
    "alpha3":"BGD",
    "nameCN":" 孟加拉国",
    "nameEN":"Bangladesh",
    "numeric":"050"
  },
  {
    "alpha2":"BB",
    "alpha3":"BRB",
    "nameCN":" 巴巴多斯",
    "nameEN":"Barbados",
    "numeric":"052"
  },
  {
    "alpha2":"BY",
    "alpha3":"BLR",
    "nameCN":" 白俄罗斯",
    "nameEN":"Belarus",
    "numeric":"112"
  },
  {
    "alpha2":"BE",
    "alpha3":"BEL",
    "nameCN":" 比利时",
    "nameEN":"Belgium",
    "numeric":"056"
  },
  {
    "alpha2":"BZ",
    "alpha3":"BLZ",
    "nameCN":" 伯利兹",
    "nameEN":"Belize",
    "numeric":"084"
  },
  {
    "alpha2":"BJ",
    "alpha3":"BEN",
    "nameCN":" 贝宁",
    "nameEN":"Benin",
    "numeric":"204"
  },
  {
    "alpha2":"BM",
    "alpha3":"BMU",
    "nameCN":" 百慕大",
    "nameEN":"Bermuda",
    "numeric":"060"
  },
  {
    "alpha2":"BT",
    "alpha3":"BTN",
    "nameCN":" 不丹",
    "nameEN":"Bhutan",
    "numeric":"064"
  },
  {
    "alpha2":"BO",
    "alpha3":"BOL",
    "nameCN":" 玻利维亚",
    "nameEN":"Bolivia (Plurinational State of)",
    "numeric":"068"
  },
  {
    "alpha2":"BQ",
    "alpha3":"BES",
    "nameCN":" 荷兰加勒比区",
    "nameEN":"Bonaire, Sint Eustatius and Saba",
    "numeric":"535"
  },
  {
    "alpha2":"BA",
    "alpha3":"BIH",
    "nameCN":" 波黑",
    "nameEN":"Bosnia and Herzegovina",
    "numeric":"070"
  },
  {
    "alpha2":"BW",
    "alpha3":"BWA",
    "nameCN":" 博茨瓦纳",
    "nameEN":"Botswana",
    "numeric":"072"
  },
  {
    "alpha2":"BV",
    "alpha3":"BVT",
    "nameCN":" 布韦岛",
    "nameEN":"Bouvet Island",
    "numeric":"074"
  },
  {
    "alpha2":"BR",
    "alpha3":"BRA",
    "nameCN":" 巴西",
    "nameEN":"Brazil",
    "numeric":"076"
  },
  {
    "alpha2":"IO",
    "alpha3":"IOT",
    "nameCN":" 英属印度洋领地",
    "nameEN":"British Indian Ocean Territory",
    "numeric":"086"
  },
  {
    "alpha2":"BN",
    "alpha3":"BRN",
    "nameCN":" 文莱",
    "nameEN":"Brunei Darussalam",
    "numeric":"096"
  },
  {
    "alpha2":"BG",
    "alpha3":"BGR",
    "nameCN":" 保加利亚",
    "nameEN":"Bulgaria",
    "numeric":"100"
  },
  {
    "alpha2":"BF",
    "alpha3":"BFA",
    "nameCN":" 布基纳法索",
    "nameEN":"Burkina Faso",
    "numeric":"854"
  },
  {
    "alpha2":"BI",
    "alpha3":"BDI",
    "nameCN":" 布隆迪",
    "nameEN":"Burundi",
    "numeric":"108"
  },
  {
    "alpha2":"CV",
    "alpha3":"CPV",
    "nameCN":" 佛得角",
    "nameEN":"Cabo Verde",
    "numeric":"132"
  },
  {
    "alpha2":"KH",
    "alpha3":"KHM",
    "nameCN":" 柬埔寨",
    "nameEN":"Cambodia",
    "numeric":"116"
  },
  {
    "alpha2":"CM",
    "alpha3":"CMR",
    "nameCN":" 喀麦隆",
    "nameEN":"Cameroon",
    "numeric":"120"
  },
  {
    "alpha2":"CA",
    "alpha3":"CAN",
    "nameCN":" 加拿大",
    "nameEN":"Canada",
    "numeric":"124"
  },
  {
    "alpha2":"KY",
    "alpha3":"CYM",
    "nameCN":" 开曼群岛",
    "nameEN":"Cayman Islands",
    "numeric":"136"
  },
  {
    "alpha2":"CF",
    "alpha3":"CAF",
    "nameCN":" 中非",
    "nameEN":"Central African Republic",
    "numeric":"140"
  },
  {
    "alpha2":"TD",
    "alpha3":"TCD",
    "nameCN":" 乍得",
    "nameEN":"Chad",
    "numeric":"148"
  },
  {
    "alpha2":"CL",
    "alpha3":"CHL",
    "nameCN":" 智利",
    "nameEN":"Chile",
    "numeric":"152"
  },
  {
    "alpha2":"CN",
    "alpha3":"CHN",
    "nameCN":" 中国",
    "nameEN":"China",
    "numeric":"156"
  },
  {
    "alpha2":"CX",
    "alpha3":"CXR",
    "nameCN":" 圣诞岛",
    "nameEN":"Christmas Island",
    "numeric":"162"
  },
  {
    "alpha2":"CC",
    "alpha3":"CCK",
    "nameCN":" 科科斯（基林）群岛",
    "nameEN":"Cocos (Keeling) Islands",
    "numeric":"166"
  },
  {
    "alpha2":"CO",
    "alpha3":"COL",
    "nameCN":" 哥伦比亚",
    "nameEN":"Colombia",
    "numeric":"170"
  },
  {
    "alpha2":"KM",
    "alpha3":"COM",
    "nameCN":" 科摩罗",
    "nameEN":"Comoros",
    "numeric":"174"
  },
  {
    "alpha2":"CG",
    "alpha3":"COG",
    "nameCN":" 刚果共和国",
    "nameEN":"Congo",
    "numeric":"178"
  },
  {
    "alpha2":"CD",
    "alpha3":"COD",
    "nameCN":" 刚果民主共和国",
    "nameEN":"Congo (Democratic Republic of the)",
    "numeric":"180"
  },
  {
    "alpha2":"CK",
    "alpha3":"COK",
    "nameCN":" 库克群岛",
    "nameEN":"Cook Islands",
    "numeric":"184"
  },
  {
    "alpha2":"CR",
    "alpha3":"CRI",
    "nameCN":" 哥斯达黎加",
    "nameEN":"Costa Rica",
    "numeric":"188"
  },
  {
    "alpha2":"CI",
    "alpha3":"CIV",
    "nameCN":" 科特迪瓦",
    "nameEN":"Côte d'Ivoire",
    "numeric":"384"
  },
  {
    "alpha2":"HR",
    "alpha3":"HRV",
    "nameCN":" 克罗地亚",
    "nameEN":"Croatia",
    "numeric":"191"
  },
  {
    "alpha2":"CU",
    "alpha3":"CUB",
    "nameCN":" 古巴",
    "nameEN":"Cuba",
    "numeric":"192"
  },
  {
    "alpha2":"CW",
    "alpha3":"CUW",
    "nameCN":" 库拉索",
    "nameEN":"Curaçao",
    "numeric":"531"
  },
  {
    "alpha2":"CY",
    "alpha3":"CYP",
    "nameCN":" 塞浦路斯",
    "nameEN":"Cyprus",
    "numeric":"196"
  },
  {
    "alpha2":"CZ",
    "alpha3":"CZE",
    "nameCN":" 捷克",
    "nameEN":"Czechia",
    "numeric":"203"
  },
  {
    "alpha2":"DK",
    "alpha3":"DNK",
    "nameCN":" 丹麦",
    "nameEN":"Denmark",
    "numeric":"208"
  },
  {
    "alpha2":"DJ",
    "alpha3":"DJI",
    "nameCN":" 吉布提",
    "nameEN":"Djibouti",
    "numeric":"262"
  },
  {
    "alpha2":"DM",
    "alpha3":"DMA",
    "nameCN":" 多米尼克",
    "nameEN":"Dominica",
    "numeric":"212"
  },
  {
    "alpha2":"DO",
    "alpha3":"DOM",
    "nameCN":" 多米尼加",
    "nameEN":"Dominican Republic",
    "numeric":"214"
  },
  {
    "alpha2":"EC",
    "alpha3":"ECU",
    "nameCN":" 厄瓜多尔",
    "nameEN":"Ecuador",
    "numeric":"218"
  },
  {
    "alpha2":"EG",
    "alpha3":"EGY",
    "nameCN":" 埃及",
    "nameEN":"Egypt",
    "numeric":"818"
  },
  {
    "alpha2":"SV",
    "alpha3":"SLV",
    "nameCN":" 萨尔瓦多",
    "nameEN":"El Salvador",
    "numeric":"222"
  },
  {
    "alpha2":"GQ",
    "alpha3":"GNQ",
    "nameCN":" 赤道几内亚",
    "nameEN":"Equatorial Guinea",
    "numeric":"226"
  },
  {
    "alpha2":"ER",
    "alpha3":"ERI",
    "nameCN":" 厄立特里亚",
    "nameEN":"Eritrea",
    "numeric":"232"
  },
  {
    "alpha2":"EE",
    "alpha3":"EST",
    "nameCN":" 爱沙尼亚",
    "nameEN":"Estonia",
    "numeric":"233"
  },
  {
    "alpha2":"SZ",
    "alpha3":"SWZ",
    "nameCN":" 斯威士兰",
    "nameEN":"Eswatini",
    "numeric":"748"
  },
  {
    "alpha2":"ET",
    "alpha3":"ETH",
    "nameCN":" 埃塞俄比亚",
    "nameEN":"Ethiopia",
    "numeric":"231"
  },
  {
    "alpha2":"FK",
    "alpha3":"FLK",
    "nameCN":" 福克兰群岛",
    "nameEN":"Falkland Islands (Malvinas)",
    "numeric":"238"
  },
  {
    "alpha2":"FO",
    "alpha3":"FRO",
    "nameCN":" 法罗群岛",
    "nameEN":"Faroe Islands",
    "numeric":"234"
  },
  {
    "alpha2":"FJ",
    "alpha3":"FJI",
    "nameCN":" 斐济",
    "nameEN":"Fiji",
    "numeric":"242"
  },
  {
    "alpha2":"FI",
    "alpha3":"FIN",
    "nameCN":" 芬兰",
    "nameEN":"Finland",
    "numeric":"246"
  },
  {
    "alpha2":"FR",
    "alpha3":"FRA",
    "nameCN":" 法国",
    "nameEN":"France",
    "numeric":"250"
  },
  {
    "alpha2":"GF",
    "alpha3":"GUF",
    "nameCN":" 法属圭亚那",
    "nameEN":"French Guiana",
    "numeric":"254"
  },
  {
    "alpha2":"PF",
    "alpha3":"PYF",
    "nameCN":" 法属波利尼西亚",
    "nameEN":"French Polynesia",
    "numeric":"258"
  },
  {
    "alpha2":"TF",
    "alpha3":"ATF",
    "nameCN":" 法属南部和南极领地",
    "nameEN":"French Southern Territories",
    "numeric":"260"
  },
  {
    "alpha2":"GA",
    "alpha3":"GAB",
    "nameCN":" 加蓬",
    "nameEN":"Gabon",
    "numeric":"266"
  },
  {
    "alpha2":"GM",
    "alpha3":"GMB",
    "nameCN":" 冈比亚",
    "nameEN":"Gambia",
    "numeric":"270"
  },
  {
    "alpha2":"GE",
    "alpha3":"GEO",
    "nameCN":" 格鲁吉亚",
    "nameEN":"Georgia",
    "numeric":"268"
  },
  {
    "alpha2":"DE",
    "alpha3":"DEU",
    "nameCN":" 德国",
    "nameEN":"Germany",
    "numeric":"276"
  },
  {
    "alpha2":"GH",
    "alpha3":"GHA",
    "nameCN":" 加纳",
    "nameEN":"Ghana",
    "numeric":"288"
  },
  {
    "alpha2":"GI",
    "alpha3":"GIB",
    "nameCN":" 直布罗陀",
    "nameEN":"Gibraltar",
    "numeric":"292"
  },
  {
    "alpha2":"GR",
    "alpha3":"GRC",
    "nameCN":" 希腊",
    "nameEN":"Greece",
    "numeric":"300"
  },
  {
    "alpha2":"GL",
    "alpha3":"GRL",
    "nameCN":" 格陵兰",
    "nameEN":"Greenland",
    "numeric":"304"
  },
  {
    "alpha2":"GD",
    "alpha3":"GRD",
    "nameCN":" 格林纳达",
    "nameEN":"Grenada",
    "numeric":"308"
  },
  {
    "alpha2":"GP",
    "alpha3":"GLP",
    "nameCN":" 瓜德罗普",
    "nameEN":"Guadeloupe",
    "numeric":"312"
  },
  {
    "alpha2":"GU",
    "alpha3":"GUM",
    "nameCN":" 关岛",
    "nameEN":"Guam",
    "numeric":"316"
  },
  {
    "alpha2":"GT",
    "alpha3":"GTM",
    "nameCN":" 危地马拉",
    "nameEN":"Guatemala",
    "numeric":"320"
  },
  {
    "alpha2":"GG",
    "alpha3":"GGY",
    "nameCN":" 根西",
    "nameEN":"Guernsey",
    "numeric":"831"
  },
  {
    "alpha2":"GN",
    "alpha3":"GIN",
    "nameCN":" 几内亚",
    "nameEN":"Guinea",
    "numeric":"324"
  },
  {
    "alpha2":"GW",
    "alpha3":"GNB",
    "nameCN":" 几内亚比绍",
    "nameEN":"Guinea-Bissau",
    "numeric":"624"
  },
  {
    "alpha2":"GY",
    "alpha3":"GUY",
    "nameCN":" 圭亚那",
    "nameEN":"Guyana",
    "numeric":"328"
  },
  {
    "alpha2":"HT",
    "alpha3":"HTI",
    "nameCN":" 海地",
    "nameEN":"Haiti",
    "numeric":"332"
  },
  {
    "alpha2":"HM",
    "alpha3":"HMD",
    "nameCN":" 赫德岛和麦克唐纳群岛",
    "nameEN":"Heard Island and McDonald Islands",
    "numeric":"334"
  },
  {
    "alpha2":"VA",
    "alpha3":"VAT",
    "nameCN":" 梵蒂冈",
    "nameEN":"Holy See",
    "numeric":"336"
  },
  {
    "alpha2":"HN",
    "alpha3":"HND",
    "nameCN":" 洪都拉斯",
    "nameEN":"Honduras",
    "numeric":"340"
  },
  {
    "alpha2":"HK",
    "alpha3":"HKG",
    "nameCN":" 香港",
    "nameEN":"Hong Kong",
    "numeric":"344"
  },
  {
    "alpha2":"HU",
    "alpha3":"HUN",
    "nameCN":" 匈牙利",
    "nameEN":"Hungary",
    "numeric":"348"
  },
  {
    "alpha2":"IS",
    "alpha3":"ISL",
    "nameCN":" 冰岛",
    "nameEN":"Iceland",
    "numeric":"352"
  },
  {
    "alpha2":"IN",
    "alpha3":"IND",
    "nameCN":" 印度",
    "nameEN":"India",
    "numeric":"356"
  },
  {
    "alpha2":"ID",
    "alpha3":"IDN",
    "nameCN":" 印度尼西亚",
    "nameEN":"Indonesia",
    "numeric":"360"
  },
  {
    "alpha2":"IR",
    "alpha3":"IRN",
    "nameCN":" 伊朗",
    "nameEN":"Iran (Islamic Republic of)",
    "numeric":"364"
  },
  {
    "alpha2":"IQ",
    "alpha3":"IRQ",
    "nameCN":" 伊拉克",
    "nameEN":"Iraq",
    "numeric":"368"
  },
  {
    "alpha2":"IE",
    "alpha3":"IRL",
    "nameCN":" 爱尔兰",
    "nameEN":"Ireland",
    "numeric":"372"
  },
  {
    "alpha2":"IM",
    "alpha3":"IMN",
    "nameCN":" 马恩岛",
    "nameEN":"Isle of Man",
    "numeric":"833"
  },
  {
    "alpha2":"IL",
    "alpha3":"ISR",
    "nameCN":" 以色列",
    "nameEN":"Israel",
    "numeric":"376"
  },
  {
    "alpha2":"IT",
    "alpha3":"ITA",
    "nameCN":" 意大利",
    "nameEN":"Italy",
    "numeric":"380"
  },
  {
    "alpha2":"JM",
    "alpha3":"JAM",
    "nameCN":" 牙买加",
    "nameEN":"Jamaica",
    "numeric":"388"
  },
  {
    "alpha2":"JP",
    "alpha3":"JPN",
    "nameCN":" 日本",
    "nameEN":"Japan",
    "numeric":"392"
  },
  {
    "alpha2":"JE",
    "alpha3":"JEY",
    "nameCN":" 泽西",
    "nameEN":"Jersey",
    "numeric":"832"
  },
  {
    "alpha2":"JO",
    "alpha3":"JOR",
    "nameCN":" 约旦",
    "nameEN":"Jordan",
    "numeric":"400"
  },
  {
    "alpha2":"KZ",
    "alpha3":"KAZ",
    "nameCN":" 哈萨克斯坦",
    "nameEN":"Kazakhstan",
    "numeric":"398"
  },
  {
    "alpha2":"KE",
    "alpha3":"KEN",
    "nameCN":" 肯尼亚",
    "nameEN":"Kenya",
    "numeric":"404"
  },
  {
    "alpha2":"KI",
    "alpha3":"KIR",
    "nameCN":" 基里巴斯",
    "nameEN":"Kiribati",
    "numeric":"296"
  },
  {
    "alpha2":"KP",
    "alpha3":"PRK",
    "nameCN":" 朝鲜",
    "nameEN":"Korea (Democratic People's Republic of)",
    "numeric":"408"
  },
  {
    "alpha2":"KR",
    "alpha3":"KOR",
    "nameCN":" 韩国",
    "nameEN":"Korea (Republic of)",
    "numeric":"410"
  },
  {
    "alpha2":"KW",
    "alpha3":"KWT",
    "nameCN":" 科威特",
    "nameEN":"Kuwait",
    "numeric":"414"
  },
  {
    "alpha2":"KG",
    "alpha3":"KGZ",
    "nameCN":" 吉尔吉斯斯坦",
    "nameEN":"Kyrgyzstan",
    "numeric":"417"
  },
  {
    "alpha2":"LA",
    "alpha3":"LAO",
    "nameCN":" 老挝",
    "nameEN":"Lao People's Democratic Republic",
    "numeric":"418"
  },
  {
    "alpha2":"LV",
    "alpha3":"LVA",
    "nameCN":" 拉脱维亚",
    "nameEN":"Latvia",
    "numeric":"428"
  },
  {
    "alpha2":"LB",
    "alpha3":"LBN",
    "nameCN":" 黎巴嫩",
    "nameEN":"Lebanon",
    "numeric":"422"
  },
  {
    "alpha2":"LS",
    "alpha3":"LSO",
    "nameCN":" 莱索托",
    "nameEN":"Lesotho",
    "numeric":"426"
  },
  {
    "alpha2":"LR",
    "alpha3":"LBR",
    "nameCN":" 利比里亚",
    "nameEN":"Liberia",
    "numeric":"430"
  },
  {
    "alpha2":"LY",
    "alpha3":"LBY",
    "nameCN":" 利比亚",
    "nameEN":"Libya",
    "numeric":"434"
  },
  {
    "alpha2":"LI",
    "alpha3":"LIE",
    "nameCN":" 列支敦士登",
    "nameEN":"Liechtenstein",
    "numeric":"438"
  },
  {
    "alpha2":"LT",
    "alpha3":"LTU",
    "nameCN":" 立陶宛",
    "nameEN":"Lithuania",
    "numeric":"440"
  },
  {
    "alpha2":"LU",
    "alpha3":"LUX",
    "nameCN":" 卢森堡",
    "nameEN":"Luxembourg",
    "numeric":"442"
  },
  {
    "alpha2":"MO",
    "alpha3":"MAC",
    "nameCN":" 澳门",
    "nameEN":"Macao",
    "numeric":"446"
  },
  {
    "alpha2":"MG",
    "alpha3":"MDG",
    "nameCN":" 马达加斯加",
    "nameEN":"Madagascar",
    "numeric":"450"
  },
  {
    "alpha2":"MW",
    "alpha3":"MWI",
    "nameCN":" 马拉维",
    "nameEN":"Malawi",
    "numeric":"454"
  },
  {
    "alpha2":"MY",
    "alpha3":"MYS",
    "nameCN":" 马来西亚",
    "nameEN":"Malaysia",
    "numeric":"458"
  },
  {
    "alpha2":"MV",
    "alpha3":"MDV",
    "nameCN":" 马尔代夫",
    "nameEN":"Maldives",
    "numeric":"462"
  },
  {
    "alpha2":"ML",
    "alpha3":"MLI",
    "nameCN":" 马里",
    "nameEN":"Mali",
    "numeric":"466"
  },
  {
    "alpha2":"MT",
    "alpha3":"MLT",
    "nameCN":" 马耳他",
    "nameEN":"Malta",
    "numeric":"470"
  },
  {
    "alpha2":"MH",
    "alpha3":"MHL",
    "nameCN":" 马绍尔群岛",
    "nameEN":"Marshall Islands",
    "numeric":"584"
  },
  {
    "alpha2":"MQ",
    "alpha3":"MTQ",
    "nameCN":" 马提尼克",
    "nameEN":"Martinique",
    "numeric":"474"
  },
  {
    "alpha2":"MR",
    "alpha3":"MRT",
    "nameCN":" 毛里塔尼亚",
    "nameEN":"Mauritania",
    "numeric":"478"
  },
  {
    "alpha2":"MU",
    "alpha3":"MUS",
    "nameCN":" 毛里求斯",
    "nameEN":"Mauritius",
    "numeric":"480"
  },
  {
    "alpha2":"YT",
    "alpha3":"MYT",
    "nameCN":" 马约特",
    "nameEN":"Mayotte",
    "numeric":"175"
  },
  {
    "alpha2":"MX",
    "alpha3":"MEX",
    "nameCN":" 墨西哥",
    "nameEN":"Mexico",
    "numeric":"484"
  },
  {
    "alpha2":"FM",
    "alpha3":"FSM",
    "nameCN":" 密克罗尼西亚联邦",
    "nameEN":"Micronesia (Federated States of)",
    "numeric":"583"
  },
  {
    "alpha2":"MD",
    "alpha3":"MDA",
    "nameCN":" 摩尔多瓦",
    "nameEN":"Moldova (Republic of)",
    "numeric":"498"
  },
  {
    "alpha2":"MC",
    "alpha3":"MCO",
    "nameCN":" 摩纳哥",
    "nameEN":"Monaco",
    "numeric":"492"
  },
  {
    "alpha2":"MN",
    "alpha3":"MNG",
    "nameCN":" 蒙古国",
    "nameEN":"Mongolia",
    "numeric":"496"
  },
  {
    "alpha2":"ME",
    "alpha3":"MNE",
    "nameCN":" 黑山",
    "nameEN":"Montenegro",
    "numeric":"499"
  },
  {
    "alpha2":"MS",
    "alpha3":"MSR",
    "nameCN":" 蒙特塞拉特",
    "nameEN":"Montserrat",
    "numeric":"500"
  },
  {
    "alpha2":"MA",
    "alpha3":"MAR",
    "nameCN":" 摩洛哥",
    "nameEN":"Morocco",
    "numeric":"504"
  },
  {
    "alpha2":"MZ",
    "alpha3":"MOZ",
    "nameCN":" 莫桑比克",
    "nameEN":"Mozambique",
    "numeric":"508"
  },
  {
    "alpha2":"MM",
    "alpha3":"MMR",
    "nameCN":" 缅甸",
    "nameEN":"Myanmar",
    "numeric":"104"
  },
  {
    "alpha2":"NA",
    "alpha3":"NAM",
    "nameCN":" 纳米比亚",
    "nameEN":"Namibia",
    "numeric":"516"
  },
  {
    "alpha2":"NR",
    "alpha3":"NRU",
    "nameCN":" 瑙鲁",
    "nameEN":"Nauru",
    "numeric":"520"
  },
  {
    "alpha2":"NP",
    "alpha3":"NPL",
    "nameCN":" 尼泊尔",
    "nameEN":"Nepal",
    "numeric":"524"
  },
  {
    "alpha2":"NL",
    "alpha3":"NLD",
    "nameCN":" 荷兰",
    "nameEN":"Netherlands",
    "numeric":"528"
  },
  {
    "alpha2":"NC",
    "alpha3":"NCL",
    "nameCN":" 新喀里多尼亚",
    "nameEN":"New Caledonia",
    "numeric":"540"
  },
  {
    "alpha2":"NZ",
    "alpha3":"NZL",
    "nameCN":" 新西兰",
    "nameEN":"New Zealand",
    "numeric":"554"
  },
  {
    "alpha2":"NI",
    "alpha3":"NIC",
    "nameCN":" 尼加拉瓜",
    "nameEN":"Nicaragua",
    "numeric":"558"
  },
  {
    "alpha2":"NE",
    "alpha3":"NER",
    "nameCN":" 尼日尔",
    "nameEN":"Niger",
    "numeric":"562"
  },
  {
    "alpha2":"NG",
    "alpha3":"NGA",
    "nameCN":" 尼日利亚",
    "nameEN":"Nigeria",
    "numeric":"566"
  },
  {
    "alpha2":"NU",
    "alpha3":"NIU",
    "nameCN":" 纽埃",
    "nameEN":"Niue",
    "numeric":"570"
  },
  {
    "alpha2":"NF",
    "alpha3":"NFK",
    "nameCN":" 诺福克岛",
    "nameEN":"Norfolk Island",
    "numeric":"574"
  },
  {
    "alpha2":"MK",
    "alpha3":"MKD",
    "nameCN":" 北马其顿",
    "nameEN":"North Macedonia",
    "numeric":"807"
  },
  {
    "alpha2":"MP",
    "alpha3":"MNP",
    "nameCN":" 北马里亚纳群岛",
    "nameEN":"Northern Mariana Islands",
    "numeric":"580"
  },
  {
    "alpha2":"NO",
    "alpha3":"NOR",
    "nameCN":" 挪威",
    "nameEN":"Norway",
    "numeric":"578"
  },
  {
    "alpha2":"OM",
    "alpha3":"OMN",
    "nameCN":" 阿曼",
    "nameEN":"Oman",
    "numeric":"512"
  },
  {
    "alpha2":"PK",
    "alpha3":"PAK",
    "nameCN":" 巴基斯坦",
    "nameEN":"Pakistan",
    "numeric":"586"
  },
  {
    "alpha2":"PW",
    "alpha3":"PLW",
    "nameCN":" 帕劳",
    "nameEN":"Palau",
    "numeric":"585"
  },
  {
    "alpha2":"PS",
    "alpha3":"PSE",
    "nameCN":" 巴勒斯坦",
    "nameEN":"Palestine, State of",
    "numeric":"275"
  },
  {
    "alpha2":"PA",
    "alpha3":"PAN",
    "nameCN":" 巴拿马",
    "nameEN":"Panama",
    "numeric":"591"
  },
  {
    "alpha2":"PG",
    "alpha3":"PNG",
    "nameCN":" 巴布亚新几内亚",
    "nameEN":"Papua New Guinea",
    "numeric":"598"
  },
  {
    "alpha2":"PY",
    "alpha3":"PRY",
    "nameCN":" 巴拉圭",
    "nameEN":"Paraguay",
    "numeric":"600"
  },
  {
    "alpha2":"PE",
    "alpha3":"PER",
    "nameCN":" 秘鲁",
    "nameEN":"Peru",
    "numeric":"604"
  },
  {
    "alpha2":"PH",
    "alpha3":"PHL",
    "nameCN":" 菲律宾",
    "nameEN":"Philippines",
    "numeric":"608"
  },
  {
    "alpha2":"PN",
    "alpha3":"PCN",
    "nameCN":" 皮特凯恩群岛",
    "nameEN":"Pitcairn",
    "numeric":"612"
  },
  {
    "alpha2":"PL",
    "alpha3":"POL",
    "nameCN":" 波兰",
    "nameEN":"Poland",
    "numeric":"616"
  },
  {
    "alpha2":"PT",
    "alpha3":"PRT",
    "nameCN":" 葡萄牙",
    "nameEN":"Portugal",
    "numeric":"620"
  },
  {
    "alpha2":"PR",
    "alpha3":"PRI",
    "nameCN":" 波多黎各",
    "nameEN":"Puerto Rico",
    "numeric":"630"
  },
  {
    "alpha2":"QA",
    "alpha3":"QAT",
    "nameCN":" 卡塔尔",
    "nameEN":"Qatar",
    "numeric":"634"
  },
  {
    "alpha2":"RE",
    "alpha3":"REU",
    "nameCN":" 留尼汪",
    "nameEN":"Réunion",
    "numeric":"638"
  },
  {
    "alpha2":"RO",
    "alpha3":"ROU",
    "nameCN":" 罗马尼亚",
    "nameEN":"Romania",
    "numeric":"642"
  },
  {
    "alpha2":"RU",
    "alpha3":"RUS",
    "nameCN":" 俄罗斯",
    "nameEN":"Russian Federation",
    "numeric":"643"
  },
  {
    "alpha2":"RW",
    "alpha3":"RWA",
    "nameCN":" 卢旺达",
    "nameEN":"Rwanda",
    "numeric":"646"
  },
  {
    "alpha2":"BL",
    "alpha3":"BLM",
    "nameCN":" 圣巴泰勒米",
    "nameEN":"Saint Barthélemy",
    "numeric":"652"
  },
  {
    "alpha2":"SH",
    "alpha3":"SHN",
    "nameCN":" 圣赫勒拿、阿森松和特里斯坦-达库尼亚",
    "nameEN":"Saint Helena, Ascension and Tristan da Cunha",
    "numeric":"654"
  },
  {
    "alpha2":"KN",
    "alpha3":"KNA",
    "nameCN":" 圣基茨和尼维斯",
    "nameEN":"Saint Kitts and Nevis",
    "numeric":"659"
  },
  {
    "alpha2":"LC",
    "alpha3":"LCA",
    "nameCN":" 圣卢西亚",
    "nameEN":"Saint Lucia",
    "numeric":"662"
  },
  {
    "alpha2":"MF",
    "alpha3":"MAF",
    "nameCN":" 法属圣马丁",
    "nameEN":"Saint Martin (French part)",
    "numeric":"663"
  },
  {
    "alpha2":"PM",
    "alpha3":"SPM",
    "nameCN":" 圣皮埃尔和密克隆",
    "nameEN":"Saint Pierre and Miquelon",
    "numeric":"666"
  },
  {
    "alpha2":"VC",
    "alpha3":"VCT",
    "nameCN":" 圣文森特和格林纳丁斯",
    "nameEN":"Saint Vincent and the Grenadines",
    "numeric":"670"
  },
  {
    "alpha2":"WS",
    "alpha3":"WSM",
    "nameCN":" 萨摩亚",
    "nameEN":"Samoa",
    "numeric":"882"
  },
  {
    "alpha2":"SM",
    "alpha3":"SMR",
    "nameCN":" 圣马力诺",
    "nameEN":"San Marino",
    "numeric":"674"
  },
  {
    "alpha2":"ST",
    "alpha3":"STP",
    "nameCN":" 圣多美和普林西比",
    "nameEN":"Sao Tome and Principe",
    "numeric":"678"
  },
  {
    "alpha2":"SA",
    "alpha3":"SAU",
    "nameCN":" 沙特阿拉伯",
    "nameEN":"Saudi Arabia",
    "numeric":"682"
  },
  {
    "alpha2":"SN",
    "alpha3":"SEN",
    "nameCN":" 塞内加尔",
    "nameEN":"Senegal",
    "numeric":"686"
  },
  {
    "alpha2":"RS",
    "alpha3":"SRB",
    "nameCN":" 塞尔维亚[note 1]",
    "nameEN":"Serbia",
    "numeric":"688"
  },
  {
    "alpha2":"SC",
    "alpha3":"SYC",
    "nameCN":" 塞舌尔",
    "nameEN":"Seychelles",
    "numeric":"690"
  },
  {
    "alpha2":"SL",
    "alpha3":"SLE",
    "nameCN":" 塞拉利昂",
    "nameEN":"Sierra Leone",
    "numeric":"694"
  },
  {
    "alpha2":"SG",
    "alpha3":"SGP",
    "nameCN":" 新加坡",
    "nameEN":"Singapore",
    "numeric":"702"
  },
  {
    "alpha2":"SX",
    "alpha3":"SXM",
    "nameCN":" 荷属圣马丁",
    "nameEN":"Sint Maarten (Dutch part)",
    "numeric":"534"
  },
  {
    "alpha2":"SK",
    "alpha3":"SVK",
    "nameCN":" 斯洛伐克",
    "nameEN":"Slovakia",
    "numeric":"703"
  },
  {
    "alpha2":"SI",
    "alpha3":"SVN",
    "nameCN":" 斯洛文尼亚",
    "nameEN":"Slovenia",
    "numeric":"705"
  },
  {
    "alpha2":"SB",
    "alpha3":"SLB",
    "nameCN":" 所罗门群岛",
    "nameEN":"Solomon Islands",
    "numeric":"090"
  },
  {
    "alpha2":"SO",
    "alpha3":"SOM",
    "nameCN":" 索马里",
    "nameEN":"Somalia",
    "numeric":"706"
  },
  {
    "alpha2":"ZA",
    "alpha3":"ZAF",
    "nameCN":" 南非",
    "nameEN":"South Africa",
    "numeric":"710"
  },
  {
    "alpha2":"GS",
    "alpha3":"SGS",
    "nameCN":" 南乔治亚和南桑威奇群岛",
    "nameEN":"South Georgia and the South Sandwich Islands",
    "numeric":"239"
  },
  {
    "alpha2":"SS",
    "alpha3":"SSD",
    "nameCN":" 南苏丹",
    "nameEN":"South Sudan",
    "numeric":"728"
  },
  {
    "alpha2":"ES",
    "alpha3":"ESP",
    "nameCN":" 西班牙",
    "nameEN":"Spain",
    "numeric":"724"
  },
  {
    "alpha2":"LK",
    "alpha3":"LKA",
    "nameCN":" 斯里兰卡",
    "nameEN":"Sri Lanka",
    "numeric":"144"
  },
  {
    "alpha2":"SD",
    "alpha3":"SDN",
    "nameCN":" 苏丹",
    "nameEN":"Sudan",
    "numeric":"729"
  },
  {
    "alpha2":"SR",
    "alpha3":"SUR",
    "nameCN":" 苏里南",
    "nameEN":"Suriname",
    "numeric":"740"
  },
  {
    "alpha2":"SJ",
    "alpha3":"SJM",
    "nameCN":" 斯瓦尔巴和扬马延",
    "nameEN":"Svalbard and Jan Mayen",
    "numeric":"744"
  },
  {
    "alpha2":"SE",
    "alpha3":"SWE",
    "nameCN":" 瑞典",
    "nameEN":"Sweden",
    "numeric":"752"
  },
  {
    "alpha2":"CH",
    "alpha3":"CHE",
    "nameCN":" 瑞士",
    "nameEN":"Switzerland",
    "numeric":"756"
  },
  {
    "alpha2":"SY",
    "alpha3":"SYR",
    "nameCN":" 叙利亚",
    "nameEN":"Syrian Arab Republic",
    "numeric":"760"
  },
  {
    "alpha2":"TW",
    "alpha3":"TWN",
    "nameCN":"中国台湾省[note 2]",
    "nameEN":"Taiwan, Province of China",
    "numeric":"158"
  },
  {
    "alpha2":"TJ",
    "alpha3":"TJK",
    "nameCN":" 塔吉克斯坦",
    "nameEN":"Tajikistan",
    "numeric":"762"
  },
  {
    "alpha2":"TZ",
    "alpha3":"TZA",
    "nameCN":" 坦桑尼亚",
    "nameEN":"Tanzania, United Republic of",
    "numeric":"834"
  },
  {
    "alpha2":"TH",
    "alpha3":"THA",
    "nameCN":" 泰国",
    "nameEN":"Thailand",
    "numeric":"764"
  },
  {
    "alpha2":"TL",
    "alpha3":"TLS",
    "nameCN":" 东帝汶",
    "nameEN":"Timor-Leste",
    "numeric":"626"
  },
  {
    "alpha2":"TG",
    "alpha3":"TGO",
    "nameCN":" 多哥",
    "nameEN":"Togo",
    "numeric":"768"
  },
  {
    "alpha2":"TK",
    "alpha3":"TKL",
    "nameCN":" 托克劳",
    "nameEN":"Tokelau",
    "numeric":"772"
  },
  {
    "alpha2":"TO",
    "alpha3":"TON",
    "nameCN":" 汤加",
    "nameEN":"Tonga",
    "numeric":"776"
  },
  {
    "alpha2":"TT",
    "alpha3":"TTO",
    "nameCN":" 特立尼达和多巴哥",
    "nameEN":"Trinidad and Tobago",
    "numeric":"780"
  },
  {
    "alpha2":"TN",
    "alpha3":"TUN",
    "nameCN":" 突尼斯",
    "nameEN":"Tunisia",
    "numeric":"788"
  },
  {
    "alpha2":"TR",
    "alpha3":"TUR",
    "nameCN":" 土耳其",
    "nameEN":"Türkiye",
    "numeric":"792"
  },
  {
    "alpha2":"TM",
    "alpha3":"TKM",
    "nameCN":" 土库曼斯坦",
    "nameEN":"Turkmenistan",
    "numeric":"795"
  },
  {
    "alpha2":"TC",
    "alpha3":"TCA",
    "nameCN":" 特克斯和凯科斯群岛",
    "nameEN":"Turks and Caicos Islands",
    "numeric":"796"
  },
  {
    "alpha2":"TV",
    "alpha3":"TUV",
    "nameCN":" 图瓦卢",
    "nameEN":"Tuvalu",
    "numeric":"798"
  },
  {
    "alpha2":"UG",
    "alpha3":"UGA",
    "nameCN":" 乌干达",
    "nameEN":"Uganda",
    "numeric":"800"
  },
  {
    "alpha2":"UA",
    "alpha3":"UKR",
    "nameCN":" 乌克兰",
    "nameEN":"Ukraine",
    "numeric":"804"
  },
  {
    "alpha2":"AE",
    "alpha3":"ARE",
    "nameCN":" 阿联酋",
    "nameEN":"United Arab Emirates",
    "numeric":"784"
  },
  {
    "alpha2":"GB",
    "alpha3":"GBR",
    "nameCN":" 英国",
    "nameEN":"United Kingdom of Great Britain and Northern Ireland",
    "numeric":"826"
  },
  {
    "alpha2":"US",
    "alpha3":"USA",
    "nameCN":" 美国",
    "nameEN":"United States of America",
    "numeric":"840"
  },
  {
    "alpha2":"UM",
    "alpha3":"UMI",
    "nameCN":" 美国本土外小岛屿",
    "nameEN":"United States Minor Outlying Islands",
    "numeric":"581"
  },
  {
    "alpha2":"UY",
    "alpha3":"URY",
    "nameCN":" 乌拉圭",
    "nameEN":"Uruguay",
    "numeric":"858"
  },
  {
    "alpha2":"UZ",
    "alpha3":"UZB",
    "nameCN":" 乌兹别克斯坦",
    "nameEN":"Uzbekistan",
    "numeric":"860"
  },
  {
    "alpha2":"VU",
    "alpha3":"VUT",
    "nameCN":" 瓦努阿图",
    "nameEN":"Vanuatu",
    "numeric":"548"
  },
  {
    "alpha2":"VE",
    "alpha3":"VEN",
    "nameCN":" 委内瑞拉",
    "nameEN":"Venezuela (Bolivarian Republic of)",
    "numeric":"862"
  },
  {
    "alpha2":"VN",
    "alpha3":"VNM",
    "nameCN":" 越南",
    "nameEN":"Viet Nam",
    "numeric":"704"
  },
  {
    "alpha2":"VG",
    "alpha3":"VGB",
    "nameCN":" 英属维尔京群岛",
    "nameEN":"Virgin Islands (British)",
    "numeric":"092"
  },
  {
    "alpha2":"VI",
    "alpha3":"VIR",
    "nameCN":" 美属维尔京群岛",
    "nameEN":"Virgin Islands (U.S.)",
    "numeric":"850"
  },
  {
    "alpha2":"WF",
    "alpha3":"WLF",
    "nameCN":" 瓦利斯和富图纳",
    "nameEN":"Wallis and Futuna",
    "numeric":"876"
  },
  {
    "alpha2":"EH",
    "alpha3":"ESH",
    "nameCN":" 西撒哈拉[note 3]",
    "nameEN":"Western Sahara",
    "numeric":"732"
  },
  {
    "alpha2":"YE",
    "alpha3":"YEM",
    "nameCN":" 也门",
    "nameEN":"Yemen",
    "numeric":"887"
  },
  {
    "alpha2":"ZM",
    "alpha3":"ZMB",
    "nameCN":" 赞比亚",
    "nameEN":"Zambia",
    "numeric":"894"
  },
  {
    "alpha2":"ZW",
    "alpha3":"ZWE",
    "nameCN":" 津巴布韦",
    "nameEN":"Zimbabwe",
    "numeric":"716"
  }
]