const historyCardStyle = html`
	<style>
		.history-card {
			display: flex;
			flex-direction: column;
			min-height: 0;
		}

		.history-body {
			display: grid;
			grid-template-columns: 280px 1fr;
			gap: 18px;
		}

		.card-head {
			margin-bottom: 10px;
			display: flex;
			align-items: center;
			padding: 12px 16px;
			background: #F7F9FC;
			border-bottom: 1px solid #E6EEF5;
		}

		.search-group {
			display: flex;
			width: 100%;
			height: 40px;
			background: white;
			border: 1px solid #D6DEE8;
			border-radius: 10px;
			overflow: hidden;
			transition:
				border-color .2s,
				box-shadow .2s;
		}

		.search-group:focus-within {
			border-color: var(--primary);
			box-shadow:
				0 0 0 3px rgba(99,193,246,.15);
		}

		.search-key {
			width: 130px;
			padding: 0 12px;
			border: none;
			background: #F7F9FC;
			color: #34495E;
			font: inherit;
			cursor: pointer;
		}

		.search-key:focus {
			outline: none;
		}

		.search-input {
			flex: 1;
			padding: 0 14px;
			border: none;
			background: transparent;
			font: inherit;
		}

		.search-input::placeholder {
			color: #9AA5B1;
		}

		.search-input:focus {
			outline: none;
		}

		.history-list {
			height: 490px;
			background: #F7F9FC;
			border: 1px solid #E6EEF5;
			border-radius: 12px;
			padding: 8px;
			overflow-y: auto;
			display: flex;
			flex-direction: column;
			gap: 2px;
			scrollbar-gutter: stable;
			scrollbar-width: thin;
			scrollbar-color: #BFD8F4 transparent;
		}
		.history-list::-webkit-scrollbar {
			width: 8px;
		}
		.history-list::-webkit-scrollbar-track {
			background: transparent;
		}
		.history-list::-webkit-scrollbar-thumb {
			background: #BFD8F4;
			border-radius: 999px;
			border: 2px solid transparent;
			background-clip: content-box;
		}
		.history-list::-webkit-scrollbar-thumb {
			background: #BFD8F4;
			border-radius: 999px;
			border: 2px solid transparent;
			background-clip: content-box;
		}
		.history-list::-webkit-scrollbar-thumb:hover {
			background: var(--primary);
			background-clip: content-box;
		}
		

		.history-item {
			position: relative;
			display: flex;
			gap: 12px;
			align-items: center;
			padding: 10px;
			border: none;
			border-radius: 8px;
			background: transparent;
			cursor: pointer;
			transition:
				background .15s,
				transform .15s;
		}

		.history-item:hover {
			background: rgba(99,193,246,.08);

			transform: none;
		}

		.history-item.active {
			background: white;
			box-shadow:
				0 1px 4px rgba(0,0,0,.08);
			color: inherit;
		}


		.history-item.active::before {
			content: "";
			position: absolute;
			left: -8px;
			top: 8px;
			bottom: 8px;
			width: 4px;
			border-radius: 99px;
			background: var(--primary);
		}

		.history-photo {
			width: 42px;
			height: 56px;
			flex-shrink: 0;
			border-radius: 4px;
			object-fit: cover;
			background: #e6eef5;
		}

		.history-info {
			min-width: 0;
			display: flex;
			flex-direction: column;
			gap: 8px;
		}

		.history-name {
			font-size: 15px;
			font-weight: 600;
			white-space: nowrap;
			overflow: hidden;
			text-overflow: ellipsis;
			text-align: left;
		}

		.history-meta {
			font-size: 12px;
			color: #7b8794;
			white-space: nowrap;
			overflow: hidden;
			text-overflow: ellipsis;
			text-align: left;
		}

		.history-detail {
			height: 490px;
			overflow-y: auto;
			padding-top: 20px;
			display: flex;
			flex-direction: column;
			gap: 10px;
			padding-right: 8px;
			-ms-overflow-style: none;
			scrollbar-width: none; 
		}
		.history-detail::-webkit-scrollbar {
			display: none;
		}

		.detail-row {
			display: flex;
			flex-direction: column;
			gap: 3px;
			padding-bottom: 10px;
			border-bottom: 1px solid #edf2f7;
		}

		.detail-row label {
			font-size: 12px;
			color: #7b8794;
			font-weight: 600;
		}

		.detail-row span {
			height: 15px;
			font-size: 15px;
			color: #233445;
		}

		.history-actions {
			display: flex;
			justify-content: flex-end;
			padding-top: 14px;
			margin-top: 10px;
			border-top: 1px solid #E6EEF5;
			gap: 12px;
		}

	    .btn {
	        height: 38px;
	        min-width: 100px;
	        padding: 0 18px;
	        border-radius: 8px;
	        font-size: 14px;
	        font-weight: 600;
	        cursor: pointer;

	        transition:
	            transform 0.18s ease,
	            border-color 0.18s ease,
	            color 0.18s ease,
	            background-color 0.18s ease,
	            box-shadow 0.18s ease;

	        position: relative;
	    }

	    .btn:hover {
	        transform: translateY(-2px);
	    }

	    .btn:active {
	        transform: translateY(0);
	    }

	    .btn-primary {
	        border: 1px solid var(--primary-dark);
	        background: linear-gradient(135deg,
	                var(--primary),
	                var(--primary-dark));
	        color: white;
	    }

	    .btn-primary:hover {
	        box-shadow: 0 6px 18px rgba(69, 146, 216, 0.25);
	    }

	    .btn-secondary {
	        border: 1px solid var(--border);
	        background: white;
	        color: var(--text);
	    }

	    .btn-secondary:hover {
	        color: var(--primary-dark);
	        border-color: var(--primary-dark);
	        box-shadow: 0 4px 12px rgba(69, 146, 216, 0.12);
	    }

	    .btn:focus-visible {
	        outline: none;
	        box-shadow: 0 0 0 3px rgba(99, 193, 246, 0.25);
	    }

	    .btn-disabled {
	        border: 1px solid var(--muted);
	        color: var(--muted);
	    }
	</style>
`

const historyCardTemplate = document.createElement('template')
historyCardTemplate.innerHTML = html`
	${historyCardStyle}
	<section class="history-card" style="display: none;">
		<header class="card-head">
			<div class="search-group">
				<select class="search-key" name="searchKey">
					<option value="name">住客姓名</option>
					<option value="roomNum">入住房号</option>
					<option value="tel">联系电话</option>
					<option value="address">证件地址</option>
					<option value="cardNo">证件号码</option>
					<option value="regTime">登记日期</option>
				</select>

				<input
					class="search-input"
					type="search"
					placeholder="Search..."
					autocomplete="off"
				/>
			</div>
		</header>

		<div class="history-body">
			<aside class="history-list">
			</aside>

			<section class="history-detail">
				<div class="detail-row">
					<label>姓名</label>
					<span></span>
				</div>

				<div class="detail-row">
					<label>房号</label>
					<span></span>
				</div>

				<div class="detail-row">
					<label>联系电话</label>
					<span></span>
				</div>

				<div class="detail-row">
					<label>旅客类型</label>
					<span></span>
				</div>
				
				<div class="detail-row">
					<label>国籍/地区</label>
					<span></span>
				</div>

				<div class="detail-row">
					<label>证件地址</label>
					<span></span>
				</div>

				<div class="detail-row">
					<label>证件号码</label>
					<span></span>
				</div>

				<div class="detail-row">
					<label>证件类型</label>
					<span></span>
				</div>

				<div class="detail-row">
					<label>性别</label>
					<span></span>
				</div>

				<div class="detail-row">
					<label>生日</label>
					<span></span>
				</div>

				<div class="detail-row">
					<label>证件有效期</label>
					<span></span>
				</div>

				<div class="detail-row">
					<label>登记时间</label>
					<span></span>
				</div>
			</section>

		</div>
		<div class="history-actions">
			<button id="edit-btn" class="btn btn-secondary">编 辑</button>
			<button id="send-btn" class="btn btn-primary">重新发送</button>
		</div>
	</section>
`

class HistoryCard extends HTMLElement {
	static selectedHistoryData = {}

	constructor() {
		super()
		const shadow = this.attachShadow({ mode: 'open' })
	}

	connectedCallback() {
		const shadow = this.shadowRoot
		shadow.appendChild(historyCardTemplate.content.cloneNode(true))

		this.searchInput = shadow.querySelector('.search-input')
		this.searchInput.addEventListener('change', e => {
			PDB.getAll(this.searchKey.value, e.target.value)
		})

		this.searchKey = shadow.querySelector('.search-key')
		this.searchKey.addEventListener('change', e => {
			switch (e.target.value) {
				case 'regTime':
					const dateFormat = new Date().toLocaleDateString('cn-ZH', { year: 'numeric', month: '2-digit', day: '2-digit' }).replaceAll('/', '-')
					const timeFormat = new Date().toLocaleTimeString('cn-ZH', { hour: '2-digit', minute: '2-digit', hour12: false })
					this.searchInput.placeholder = `如：${dateFormat} 或 ${timeFormat}`
					break
				default:
					this.searchInput.placeholder = 'Search...'
					break
			}

			PDB.getAll(e.target.value, this.searchInput.value)
		})

		this.editBtn = shadow.getElementById('edit-btn')
		this.editBtn.addEventListener('click', () => {
			currentData = HistoryCard.selectedHistoryData.data

			const form = document.querySelector('form-content').form
			for (const field of form.elements) {
				switch (field.name) {
					case 'curPhoto':
						const photo = form.querySelector('.passport-photo')
						photo.src = `data:image/jpeg;base64,${currentData.curPhoto.replace('data:image/jpeg;base64,', '')}`
						break

					case 'guardianName':
					case 'guardianTel':
					case 'guardianRelation':
						if (currentData.hasOwnProperty('guardianInfo')) {
							field.value = currentData.guardianInfo[field.name] ?? ''
						}
						break

					default:
						field.value = currentData[field.name] ?? ''
						break
				}
			}
			
			FormValidator.handleFormValidate(form)
			document.querySelector('side-nav').readerBtn.click()
		})

		this.sendBtn = shadow.getElementById('send-btn')
		this.sendBtn.addEventListener('click', async () => {
			const sendClip = {
				identifier: identifier,
				tsId: Date.now(),
				roomNum: HistoryCard.selectedHistoryData.roomNum ?? '',
				tel: HistoryCard.selectedHistoryData.tel ?? '',
				guestType: HistoryCard.selectedHistoryData.guestType,
				idType: groupedCardTypes.get(HistoryCard.selectedHistoryData.guestType).get(HistoryCard.selectedHistoryData.cardType),
				region: HistoryCard.selectedHistoryData.region,
				gender: HistoryCard.selectedHistoryData.gender,
				data: HistoryCard.selectedHistoryData.data,
			}
			
			if (FormValidator.getAge(new Date(sendClip.data.birthday)) < 18 && sendClip.guestType !== '国外旅客') {
				sendClip.guardianInfo = HistoryCard.selectedHistoryData.guardianInfo
			}

			await navigator.clipboard.writeText(JSON.stringify(sendClip))
		})
	}

	static createHistoryListItem(data) {
		if (!data.name) {
			data.name = `${data.lastName}, ${data.firstName}`
		}
		const historyItem = document.createElement('template')
		historyItem.innerHTML = html`
			<div class="history-item">
				<img 
					class="history-photo" 
					src="${data.data.curPhoto.startsWith('data:image/jpeg;base64,') ? data.data.curPhoto : 'data:image/jpeg;base64,' + data.data.curPhoto}" 
					alt="head" 
				/>
				<div class="history-info">
					<div class="history-name" title="${data.name}">${data.name}</div>
					<div class="history-meta">${data.roomNum && (data.roomNum + ' • ')} ${data.region} • ${data.birthday}</div>
				</div>
			</div>
		`

		historyItem.content.querySelector('.history-item').addEventListener('click', e => {
			const list = document.querySelector('history-card').shadowRoot.querySelector('.history-list')
			list.querySelectorAll('.history-item').forEach(item => item.classList.remove('active'))

			const item = e.target.closest('.history-item')
			if (!item) return

			item.classList.add('active')
			HistoryCard.handleHistoryDetailUpdate(data)
		})

		return historyItem
	}

	static handleHistoryDetailUpdate(data = null) {
		HistoryCard.selectedHistoryData = data
		const historyDetailContainer = document.querySelector('history-card').shadowRoot.querySelector('.history-detail')
		if (!data) {
			[...historyDetailContainer.querySelectorAll('span')].forEach(span => span.innerText = '')
			return
		}

		historyDetailContainer.innerHTML = ''
		const historyDetailContent = document.createElement('template')
		historyDetailContent.innerHTML = html`
				${data.guestType !== '国外旅客' 
					? html`
						<div class="detail-row">
							<label>姓名</label>
							<span>${data.name}</span>
						</div>
					`
					: ''
				}

				${data.guestType !== '内地旅客' 
					? html`
						<div class="detail-row">
							<label>英文姓</label>
							<span>${data.lastName}</span>
						</div>
						
						<div class="detail-row">
							<label>英文名</label>
							<span>${data.firstName}</span>
						</div>
					`
					: ''
				}

				<div class="detail-row">
					<label>房号</label>
					<span>${data.roomNum}</span>
				</div>

				<div class="detail-row">
					<label>联系电话</label>
					<span>${data.tel}</span>
				</div>

				<div class="detail-row">
					<label>旅客类型</label>
					<span>${data.guestType}</span>
				</div>

				<div class="detail-row">
					<label>国籍/地区</label>
					<span>${data.region}</span>
				</div>

				<div class="detail-row">
					<label>证件地址</label>
					<span>${data.address}</span>
				</div>

				<div class="detail-row">
					<label>证件号码</label>
					<span>${data.data.cardNo}</span>
				</div>

				<div class="detail-row">
					<label>证件类型</label>
					<span>${groupedCardTypes.get(data.guestType).get(data.cardType)}</span>
				</div>

				<div class="detail-row">
					<label>性别</label>
					<span>${data.gender}</span>
				</div>

				<div class="detail-row">
					<label>生日</label>
					<span>${data.birthday}</span>
				</div>

				${data.hasOwnProperty('guardianInfo') ? html`
					<div class="detail-row">
						<label>监护人姓名</label>
						<span>${data.guardianInfo.guardianName}</span>
					</div>

					<div class="detail-row">
						<label>监护人电话</label>
						<span>${data.guardianInfo.guardianTel}</span>
					</div>

					<div class="detail-row">
						<label>监护人关系</label>
						<span>${data.guardianInfo.guardianRelation}</span>
					</div>
				` : ''}

				<div class="detail-row">
					<label>证件有效期</label>
					<span>${data.validDate}</span>
				</div>

				<div class="detail-row">
					<label>登记时间</label>
					<span>${data.regTime}</span>
				</div>
		`

		historyDetailContainer.appendChild(historyDetailContent.content)
	}
}

customElements.define('history-card', HistoryCard)