function getGuestType(typeCode, nationalityArea = '') {
	switch (typeCode) {
		case '100':
			return '内地旅客'
			break
		case '200':
			return nationalityArea === 'CHN' ? '内地旅客' : '港澳台旅客'
			break
		case '300':
			return '国外旅客'
		default:
			return ''
			break
	}
}

const groupedCardTypes = new Map([
	['内地旅客', new Map([
		['11', '身份证'],
		['93', '国内护照'],
		['95', '港澳通行证']
	])],
	['国外旅客', new Map([
		['14', '普通护照']
	])],
	['港澳台旅客', new Map([
		['60', '港澳居民来往内地通行证'],
		['16', '台湾居民来往大陆通行证'],
		['56', '港澳居民来往内地通行证（非中国籍）'],
		['55', '港澳台居民居住证']
	])]
])

const portsWithMakers = new Map([
	['8010', '雄帝'],
	['90', '文通'],
	['17181', '科蓝'],
	['17182', '科蓝'],
])