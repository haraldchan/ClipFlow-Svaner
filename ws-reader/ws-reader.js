// globals
let socket = null;
let currentData = null;
const identifier = '3ed542123e774d45203ff60175cb614e'; //MD5 hash: ProfileModifyNextLocal
const ports = ['17181', '17182', '8080', '90'];

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
			return { port, socket: ws };
		} catch {
			// try next port
		}
	}

	throw new Error('No websocket service found');
}

async function connectOrDisconnect() {
	if (socket === null || socket.readyState === WebSocket.CLOSED) {
		try {
			const { port, socket } = await findService();
			connBtn.textContent = '● 已连接';
			connBtn.classList.replace('status-connecting', 'status-connected');
		} catch (error) {
			if (error) {
				connBtn.textContent = '✖ 无服务在线';
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
	}
}

// form elements
const passportPhotoImg = document.querySelector('.passport-photo');
const fullName = document.getElementById('fullname');
const lastName = document.getElementById('lastname');
const firstName = document.getElementById('firstname');
const roomNum = document.getElementById('room-num');
const tel = document.getElementById('tel');
const idNum = document.getElementById('id-num');
const idType = document.getElementById('id-type');
const gender = document.getElementById('gender');
const birthday = document.getElementById('birthday');
const guestType = document.getElementById('guest-type');
const region = document.getElementById('region');
const validDate = document.getElementById('valid-date');

// ui functions
function handleMessageDisplay(data) {
	currentData = data;

	passportPhotoImg.src = data.data.curPhoto
	fullName.value = data.data.name;
	lastName.value = data.data.lastName;
	firstName.value = data.data.firstName;
	idNum.value = data.data.cardNo;
	gender.selectedIndex = data.data.sex - 1;
	birthday.value = data.data.birthday
	validDate.value = data.data.validDate;
}
handleMessageDisplay({
    code: 0, // if success
    command: "scan",      // can only use "scan"
    data: {
        address:   "",
        adminDivision: "",
        birthday:  "1990-03-30", // yyyy-MM-dd,
        cardNo:    "235434534",
        cardType:  "14", // 14=foreign passport
        curPhoto:  "awf", // base64 photo for passfoto
        firstName: "mookie",
        lastName:  "bets",
        nationalityArea: "MYS", // iso-3166-1 alpha3
        photo:     "",
        guestType: "300", // numbered key
        name:      "bets mookie", // full hanzi name
        nation:    "",
        sex:       "2", // 1=male, 2=female
        signDate:  "--",
        signOrg:   "",
        signPlace: "string",
        validDate: "1999-12-12"
    },
    message: ""
})

/**
 *
 * @param {Event} e
 * @returns
 */
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
connBtn.addEventListener('click', async () => {
	connectOrDisconnect();
});
// connBtn.click();

const readBtn = document.getElementById('read-btn');
readBtn.addEventListener('click', sendCommand);

const scanBtn = document.getElementById('scan-btn');
scanBtn.addEventListener('click', sendCommand);
