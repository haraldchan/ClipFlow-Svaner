function getGuestType(typeCode, nationalityArea = '') {
	switch (typeCode) {
		case '100':
			return '内地旅客';
			break;
		case '200':
			return nationalityArea === 'CHN' ? '内地旅客' : '港澳台旅客';
			break;
		case '300':
			return '国外旅客';
		default:
			return '';
			break;
	}
}

const cardTypes = new Map([
	['11', '身份证'],
	['14', '普通护照'],
	['93', '国内护照'],
	['60', '港澳居民来往内地通行证'],
	['16', '台湾居民来往大陆通行证'],
	['56', '港澳居民来往内地通行证（非中国籍）'],
]);
