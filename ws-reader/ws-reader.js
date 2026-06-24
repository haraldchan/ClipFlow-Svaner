// globals
let socket = null;
let currentData = {};
const identifier = '3ed542123e774d45203ff60175cb614e'; //MD5 hash: ProfileModifyNextLocal
const ports = ['17181', '17182', '8010', '90'];

// WebSocket handlers
async function findService() {
	const connBtn = document.querySelector('.connection-btn');
	connBtn.textContent = '● 连接中...';
	connBtn.classList.replace('status-disconnected', 'status-connecting');

	for (const port of ports) {
		try {
			const ws = await ((url, timeout = 1000) => {
				return new Promise((resolve, reject) => {
					const ws = new WebSocket(url);

					const timer = setTimeout(() => {
						ws.close();
						reject(new Error('timeout'));
					}, timeout);

					ws.onopen = () => {
						clearTimeout(timer);
						resolve(ws);
					};

					ws.onerror = () => {
						clearTimeout(timer);
						reject(new Error('failed'));
					};
				});
			})(`ws://127.0.0.1:${port}`);

			console.log(`Found service on ${port}`);
			return { port, ws };
		} catch {
			// try next port
		}
	}

	throw new Error('No websocket service found');
}

async function connectOrDisconnect() {
	if (socket === null || socket.readyState === WebSocket.CLOSED) {
		try {
			const { port, ws } = await findService();
			socket = ws;
			connBtn.textContent = '● 已连接';
			connBtn.classList.replace('status-connecting', 'status-connected');
		} catch (error) {
			if (error) {
				connBtn.textContent = '无服务在线';
				connBtn.classList.replace('status-connecting', 'status-disconnected');
				return;
			}
		}

		socket.onopen = function (event) {
			console.log('已连接到端口: ' + port);
		};

		socket.onmessage = function (event) {
			console.log(JSON.parse(event.data));
			handleMessageDisplay(JSON.parse(event.data));
		};

		socket.onclose = function (event) {
			console.log('连接已关闭');
		};
	} else if (socket.readyState === WebSocket.OPEN) {
		socket.close();
		connBtn.textContent = '已断开连接';
		connBtn.classList.replace('status-connected', 'status-disconnected');
	}
}

// form elements
const form = document.querySelector('.passport-card');
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
// handleMessageDisplay({
// 	code: 0, // if success
// 	command: 'scan', // can only use "scan"
// 	data: {
// 		address: '',
// 		adminDivision: '',
// 		birthday: '1990-03-30', // yyyy-MM-dd,
// 		cardNo: '235434534',
// 		cardType: '11', // 14=foreign passport
// 		curPhoto: 'awf', // base64 photo for passfoto
// 		firstName: 'mookie',
// 		lastName: 'bets',
// 		nationalityArea: 'HKG', // iso-3166-1 alpha3
// 		photo: '',
// 		guestType: '100', // numbered key
// 		name: '姆基贝茨', // full hanzi name
// 		nation: '',
// 		sex: '2', // 1=male, 2=female
// 		signDate: '--',
// 		signOrg: '',
// 		signPlace: 'string',
// 		validDate: '1999-12-12',
// 	},
// 	message: '',
// });

// btns & events
function sendCommand(e) {
	const option = e.target.id.replace('-btn', '');

	if (socket === null || socket.readyState !== WebSocket.OPEN) {
		alert('尚未连接到WebSocket服务器');
		return;
	}

	const message = `{"command":"${option}"}`;

	console.log(message);
	socket.send(message);
}

const connBtn = document.querySelector('.connection-btn');
connBtn.addEventListener('click', async () => connectOrDisconnect());

const readBtn = document.getElementById('read-btn');
readBtn.addEventListener('click', sendCommand);

const scanBtn = document.getElementById('scan-btn');
scanBtn.addEventListener('click', sendCommand);

const sendBtn = document.getElementById('send-btn');
sendBtn.addEventListener('click', async () => {
	if (!form.reportValidity()) return;

	const sendClip = {
		identifier: '3ed542123e774d45203ff60175cb614e',
		tsId: Date.now(),
		roomNum: roomNum.value,
		tel: tel.value,
		guestType: guestType.value,
		idType: idType.value,
		region: region.value,
		data: currentData,
	};

	await navigator.clipboard.writeText(JSON.stringify(sendClip));
});

// init
function onLaunch() {
	for (const code in nationalityAreas) {
		createOption(regionList, code, nationalityAreas[code]);
	}

	connectOrDisconnect();
}
onLaunch();
