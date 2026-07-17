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
	const connBtn = document.querySelector('card-header').connBtn
	const portSelect = document.querySelector('card-header').portSelect

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
	const connBtn = document.querySelector('card-header').connBtn

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
			} else {
				handleMessageDisplay(data)
			}

			document.querySelector('action-bar').enable()
			document.querySelector('.loading-overlay').style.display = 'none'
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

	const guestType = Number.isInteger(parseInt(currentData.guestType))
		? getGuestType(currentData.guestType, currentData.hasOwnProperty('nationalityArea') ? currentData.nationalityArea : '')
		: currentData.guestType
	currentData.guestType = guestType

	currentData.checkinDate = (new Date())
		.toLocaleString(
			'cn-ZH', { 
				year: 'numeric', 
				month: '2-digit', 
				day: '2-digit', 
				hour: '2-digit', 
				minute: '2-digit', 
				hour12: false 
			}
		)
		.replaceAll('/', '-')

	/** @type {HTMLFormElement} */
	const form = document.querySelector('form-content').shadowRoot.querySelector('.form-content')

	for (const field of form.elements) {
		switch (field.name) {
			case 'curPhoto':
				const photo = form.querySelector('.passport-photo')
				photo.src = `data:image/jpeg;base64,${currentData.curPhoto.replace('data:image/jpeg;base64,', '')}`
				break

			case 'region':
				field.value = guestType === '内地旅客' ? '中国' : nationalityAreas[currentData.nationalityArea]
				currentData.region = field.value
				break

			case 'gender':
				field.value = currentData.sex === '1' ? '男' : '女'
				currentData.gender = field.value
				break

			default:
				field.value = currentData[field.name] ?? ''
				break
		}
	}

	const validateResult = FormValidator.handleFormValidate(form)
	if (!validateResult.isValid) {
		console.log([...validateResult.invalidFields])
	} else {
		PDB.add(currentData)
	}
}