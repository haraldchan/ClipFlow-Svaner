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
	const connBtn = document.querySelector('.connection-btn');
	connBtn.textContent = '● 连接中...';
	connBtn.classList.remove(...connStatusClasses);
	connBtn.classList.add('status-connecting');

	if (definedPort) {
		const ws = await connect(definedPort);
		return { definedPort, ws };
	}

	for (const port of ports) {
		try {
			const ws = await connect(port);
			return { port, ws };
		} catch {
			// try next port
		}
	}

	throw new Error('No websocket service found');
}

async function connectOrDisconnect(definedPort = null) {
	const connBtn = document.querySelector('.connection-btn');
	
	if (socket === null || socket.readyState === WebSocket.CLOSED) {
		try {
			const { port, ws } = await findService(definedPort);
			socket = ws;
			connBtn.textContent = '● 已连接';
			connBtn.classList.remove(...connStatusClasses);
			connBtn.classList.add('status-connected');
		} catch (error) {
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
