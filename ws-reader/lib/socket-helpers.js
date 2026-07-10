const connStatusClasses = [
	'status-connecting',
	'status-disconnected',
	'status-connected',
]

async function connect(port) {
	const ws = await ((url, timeout = 1000) => {
		return new Promise((resolve, reject) => {
			const ws = new WebSocket(url)

			const timer = setTimeout(() => {
				ws.close()
				reject(new Error('timeout'))
			}, timeout)

			ws.onopen = () => {
				clearTimeout(timer)
				resolve(ws)
			}

			ws.onerror = () => {
				clearTimeout(timer)
				reject(new Error('failed'))
			}
		})
	})(`ws://127.0.0.1:${port}`)

	console.log(`Found service on ${port}`)
	return ws
}

async function findService(definedPort = null) {
	const connBtn = document.getElementById('card-header').connBtn
	const portSelect = document.getElementById('card-header').portSelect

	connBtn.textContent = '● 连接中...'
	connBtn.classList.remove(...connStatusClasses)
	connBtn.classList.add('status-connecting')

	if (definedPort) {
		const ws = await connect(definedPort)
		return { definedPort, ws }
	}

	for (const [port, maker] of portsWithMakers) {
		try {
			console.log(`connecting to:${port}...`)
			const ws = await connect(port)
			portSelect.value = port
			return { port, ws }
		} catch {
			// try next port
		}
	}

	throw new Error('No websocket service found')
}

async function connectOrDisconnect(definedPort = null) {
	const connBtn = document.getElementById('card-header').connBtn

	if (socket === null || socket.readyState === WebSocket.CLOSED) {
		try {
			const { port, ws } = await findService(definedPort)
			socket = ws
			connBtn.textContent = '● 已连接'
			connBtn.classList.remove(...connStatusClasses)
			connBtn.classList.add('status-connected')
		} catch (error) {
			console.log(error)
			if (error) {
				connBtn.textContent = '无服务在线'
				connBtn.classList.remove(...connStatusClasses)
				connBtn.classList.add('status-disconnected')
				return
			}
		}

		socket.onopen = (event) => console.log('已连接到端口: ' + port)

		socket.onmessage = (event) => {
			const data = JSON.parse(event.data)
			console.log(data)

			if (data.code === 1) {
				alert(data.message)
				return
			}

			handleMessageDisplay(data)
		}

		socket.onclose = (event) => console.log('连接已关闭')

	} else if (socket.readyState === WebSocket.OPEN) {
		socket.close()
		connBtn.textContent = '已断开连接'
		connBtn.classList.remove(...connStatusClasses)
		connBtn.classList.add('status-disconnected')
	}
}

function handleMessageDisplay(data) {
	currentData = data.data
	// this might be a bug of the scanner drivers, lastname/firstname are mostly swapped, so it has to be this way.
	const prevLast = currentData.lastName
	const prevFirst = currentData.firstName
	currentData.firstName = prevLast
	currentData.lastName = prevFirst

	const form = document.getElementById('form-content').shadowRoot.querySelector('.form-content')
	form.reset()

	for (const [name, value] of Object.entries(currentData)) {
		if (name.includes('nation')) {
			const region = form.elements.namedItem('region')
			currentData.guestType === '100' ? region.value = '中国' : region.value = nationalityAreas[currentData.nationalityArea]
			continue
		}

		const field = form.elements.namedItem(name)
		if (!field) continue

		switch (name) {
			case 'curPhoto':
				const photo = form.querySelector('.passport-photo')
				photo.src = `data:image/jpeg;base64,${currentData.curPhoto.replace('data:image/jpeg;base64,', '')}`
				break
			case 'sex':
				field.value = currentData.sex === '1' ? '男' : '女'
				break
			case 'guestType':
				field.value = getGuestType(
					currentData.guestType,
					currentData.hasOwnProperty('nationalityArea') ? currentData.nationalityArea : ''
				)
				break
			default:
				field.value = currentData[name] ?? ''
				break
		}
	}
}