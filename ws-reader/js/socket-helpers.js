const connStatusClasses = [
	'status-connecting',
	'status-disconnected',
	'status-connected',
];

async function connect(port) {
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
	return ws;
}

async function findService(definedPort = null) {
	const connBtn = document.getElementById('card-header').connBtn;
	connBtn.textContent = '● 连接中...';
	connBtn.classList.remove(...connStatusClasses);
	connBtn.classList.add('status-connecting');

	if (definedPort) {
		const ws = await connect(definedPort);
		return { definedPort, ws };
	}

	for (const [port, maker] of portsWithMakers) {
		try {
			console.log(`connecting to:${port}...`)
			const ws = await connect(port);
			return { port, ws };
		} catch {
			// try next port
		}
	}

	throw new Error('No websocket service found');
}

async function connectOrDisconnect(definedPort = null) {
	const connBtn = document.getElementById('card-header').connBtn;
	
	if (socket === null || socket.readyState === WebSocket.CLOSED) {
		try {
			const { port, ws } = await findService(definedPort);
			socket = ws;
			connBtn.textContent = '● 已连接';
			connBtn.classList.remove(...connStatusClasses);
			connBtn.classList.add('status-connected');
		} catch (error) {
			console.log(error)
			if (error) {
				connBtn.textContent = '无服务在线';
				connBtn.classList.remove(...connStatusClasses);
				connBtn.classList.add('status-disconnected');
				return;
			}
		}

		socket.onopen = (event) => console.log('已连接到端口: ' + port);

		socket.onmessage = (event) => {
			const data = JSON.parse(event.data);
			console.log(data);

			if (data.code === 1) {
				alert(data.message);
				return;
			}

			handleMessageDisplay(data);
		};

		socket.onclose = (event) => console.log('连接已关闭');

	} else if (socket.readyState === WebSocket.OPEN) {
		socket.close();
		connBtn.textContent = '已断开连接';
		connBtn.classList.remove(...connStatusClasses);
		connBtn.classList.add('status-disconnected');
	}
}

function handleMessageDisplay(data) {
	currentData = data.data;
	const FormContent = document.getElementById('form-content')

	// updated inputs & non-dynamic selects
	FormContent.passportPhotoImg.src = `data:image/jpeg;base64,${currentData.curPhoto.replace('data:image/jpeg;base64,', '')}`;
	FormContent.fullName.value = currentData.name ?? '';
	FormContent.lastName.value = currentData.lastName ?? '';
	FormContent.firstName.value = currentData.firstName ?? '';
	FormContent.address.value = currentData.address ?? '';
	FormContent.idNum.value = currentData.cardNo;
	FormContent.birthday.value = currentData.birthday;
	FormContent.validDate.value = currentData.validDate;

	// update selects
	FormContent.gender.selectedIndex = currentData.sex;
	FormContent.idType.value = currentData.cardType;
	FormContent.region.value = nationalityAreas[currentData.nationalityArea] ?? '中国';

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

