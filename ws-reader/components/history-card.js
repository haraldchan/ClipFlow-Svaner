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
		}

		.send-btn {
			min-width: 120px;
			height: 40px;
			border: none;
			border-radius: 8px;
			background: #4592D8;
			color: white;
			font-size: 15px;
			font-weight: 600;
			cursor: pointer;
			transition:
				background .2s,
				transform .15s,
				box-shadow .2s;
		}

		.send-btn:hover {
			background: #63C1F6;
			transform: translateY(-2px);
			box-shadow:
				0 4px 12px rgba(69,146,216,.25);
		}

		.send-btn:active {
			transform: translateY(0);
			box-shadow: none;
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
					<option value="checkinDate">登记日期</option>
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
					<label>旅客类型</label>
					<span></span>
				</div>
				
				<div class="detail-row">
					<label>国籍/地区</label>
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
					<label>生日</label>
					<span></span>
				</div>

				<div class="detail-row">
					<label>性别</label>
					<span></span>
				</div>

				<div class="detail-row">
					<label>联系电话</label>
					<span></span>
				</div>

				<div class="detail-row">
					<label>证件地址</label>
					<span></span>
				</div>

				<div class="detail-row">
					<label>证件有效期</label>
					<span></span>
				</div>

				<div class="detail-row">
					<label>登记日期</label>
					<span></span>
				</div>
			</section>

		</div>
		<div class="history-actions">
			<button class="send-btn">重新发送</button>
		</div>
	</section>
`

class HistoryCard extends HTMLElement {
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
				case 'checkinDate':
					const dateFormat = new Date().toLocaleDateString('cn-ZH', { year: '2-digit', month: '2-digit', day: '2-digit' }).replaceAll('/', '-')
					const timeFormat = new Date().toLocaleTimeString('cn-ZH', { hour: '2-digit', minute: '2-digit', hour12: false })
					this.searchInput.placeholder = `如：${dateFormat} 或 ${timeFormat}`
					break
				default:
					this.searchInput.placeholder = 'Search...'
					break
			}

			PDB.getAll(e.target.value, this.searchInput.value)
		})

		this.sendBtn = shadow.querySelector('.send-btn')
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

			await navigator.clipboard.writeText(JSON.stringify(sendClip))
		})
	}

	static selectedHistoryData = {}

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
		console.log(data)
		const historyDetailContainer = document.querySelector('history-card').shadowRoot.querySelector('.history-detail')
		if (!data) {
			[...historyDetailContainer.querySelectorAll('span')].forEach(span => span.innerText = '')
			return
		}

		historyDetailContainer.innerHTML = ''
		const historyDetailContent = document.createElement('template')
		historyDetailContent.innerHTML = html`
				<div class="detail-row">
					<label>旅客类型</label>
					<span>${data.guestType}</span>
				</div>
				
				<div class="detail-row">
					<label>国籍/地区</label>
					<span>${data.region}</span>
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
					<label>生日</label>
					<span>${data.birthday}</span>
				</div>

				<div class="detail-row">
					<label>性别</label>
					<span>${data.gender}</span>
				</div>

				<div class="detail-row">
					<label>联系电话</label>
					<span>${data.tel}</span>
				</div>

				<div class="detail-row">
					<label>证件地址</label>
					<span>${data.address}</span>
				</div>

				<div class="detail-row">
					<label>证件有效期</label>
					<span>${data.validDate}</span>
				</div>

				<div class="detail-row">
					<label>登记日期</label>
					<span>${data.checkinDate}</span>
				</div>
		`

		historyDetailContainer.appendChild(historyDetailContent.content)
	}
}

customElements.define('history-card', HistoryCard)