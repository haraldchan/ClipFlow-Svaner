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

const portSelect = document.querySelector('.port-select');
portSelect.addEventListener('change', async () => {
	if (socket) {
		socket.close();
		socket = null;
	}
	console.log(portSelect.value);
	await connectOrDisconnect(portSelect.value);
});

const connBtn = document.querySelector('.connection-btn');
connBtn.addEventListener('click', async () => connectOrDisconnect());

const readBtn = document.getElementById('read-btn');
readBtn.addEventListener('click', sendCommand);

const scanBtn = document.getElementById('scan-btn');
scanBtn.addEventListener('click', sendCommand);

const sendBtn = document.getElementById('send-btn');
sendBtn.addEventListener('click', async () => {
	const form = document.querySelector('.passport-card');
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
