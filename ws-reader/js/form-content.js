const passportPhotoImg = document.querySelector('.passport-photo');

const fullName = document.getElementById('fullname');
fullName.addEventListener(
	'change',
	(e) => (currentData.data.name = e.target.value),
);

const lastName = document.getElementById('lastname');
lastName.addEventListener(
	'change',
	(e) => (currentData.lastName = e.target.value),
);

const firstName = document.getElementById('firstname');
firstName.addEventListener(
	'change',
	(e) => (currentData.firstName = e.target.value),
);

const roomNum = document.getElementById('room-num');
const tel = document.getElementById('tel');

const guestType = document.getElementById('guest-type');
guestType.addEventListener(
	'change',
	(e) => (currentData.guestType = e.target.value),
);

const regionList = document.getElementById('region-list');
const region = document.getElementById('region');
region.addEventListener('change', (e) => {
	currentData.nationalityArea =
		currentData.guestType === '内地旅客' ? 'CHN' : e.target.value;
});

const address = document.getElementById('address');
address.addEventListener(
	'change',
	(e) => (currentData.address = e.target.value),
);

const idNum = document.getElementById('id-num');
idNum.addEventListener('change', (e) => (currentData.cardNo = e.target.value));

const idType = document.getElementById('id-type');
idType.addEventListener(
	'change',
	(e) => (currentData.cardType = e.target.value),
);

const gender = document.getElementById('gender');
gender.addEventListener('change', (e) => (currentData.sex = e.target.value));

const birthday = document.getElementById('birthday');
birthday.addEventListener(
	'change',
	(e) => (currentData.birthday = e.target.value),
);

const validDate = document.getElementById('valid-date');
validDate.addEventListener(
	'change',
	(e) => (currentData.validDate = e.target.value),
);

// ui functions
function createOption(select, textContent, value = null) {
	const option = document.createElement('option');

	if (value !== null) option.value = value;
	option.textContent = textContent;

	select.appendChild(option);
}

function handleMessageDisplay(data) {
	if (data.code === 1) {
		alert(data.message);
		return;
	}

	currentData = data.data;

	// updated inputs & non-dynamic selects
	passportPhotoImg.src = `data:image/jpeg;base64,${currentData.curPhoto.replace('data:image/jpeg;base64,', '')}`;
	fullName.value = currentData.name ?? '';
	lastName.value = currentData.lastName ?? '';
	firstName.value = currentData.firstName ?? '';
	address.value = currentData.address ?? '';
	idNum.value = currentData.cardNo;
	birthday.value = currentData.birthday;
	validDate.value = currentData.validDate;

	// update selects
	gender.selectedIndex = currentData.sex;
	idType.value = currentData.cardType;
	region.value = nationalityAreas[currentData.nationalityArea] ?? '中国';

	const curGuestType = getGuestType(
		currentData.guestType,
		currentData.hasOwnProperty('nationalityArea')
			? currentData.nationalityArea
			: '',
	);
	switch (curGuestType) {
		case '内地旅客':
			guestType.selectedIndex = 1;
			break;
		case '港澳台旅客':
			guestType.selectedIndex = 2;
			break;
		case '国外旅客':
			guestType.selectedIndex = 3;
			break;
	}
}
