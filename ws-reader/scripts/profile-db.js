/**
 * @typedef {object} Profile
 * @property {string | ''} name 
 * @property {string | ''} lastName
 * @property {string | ''} firstName
 * @property {string | ''} roomNum
 * @property {string | ''} tel
 * @property {'内地旅客' | '港澳台旅客' | '国外旅客'} guestType
 * @property {string} region
 * @property {string} cardNo
 * @property {string} cardType
 * @property {'男' | '女'} gender
 * @property {string} birthday
 * @property {string} validDate
 * @property {object} data
 * @property {string} checkinDate
 */

class ProfileDB {
    constructor() {
        /** @type {IDBDatabase | undefined} */
        this.db

        const objectStoreIndexes = [
            'name',
            'lastName',
            'firstName',
            'roomNum',
            'tel',
            'guestType',
            'region',
            'address',
            'cardNo',
            'cardType',
            'gender',
            'birthday',
            'validDate',
            'data',
            'checkinDate',
        ]

        const DBOpenRequest = window.indexedDB.open("guestProfiles")
        DBOpenRequest.onsuccess = (e) => this.db = e.target.result
        DBOpenRequest.onupgradeneeded = (e) => {
            this.db = e.target.result
    
            this.db.onerror = (e) => console.log("Error loading database.")
    
            const objectStore = this.db.createObjectStore("guestProfiles", { keyPath: "cardNo" })
            for (const index of objectStoreIndexes) {
                objectStore.createIndex(index, index, { unique: index === 'cardNo' ? true : false })
            }
        }
    }

    add(data) {
        /** @type {Profile} */
        const newItem = {
            name: data.name ?? '',
            lastName: data.lastName ?? '',
            firstName: data.firstName ?? '',
            roomNum: data.roomNum ?? '',
            tel: data.tel ?? '',
            guestType: data.guestType,
            region: data.region,
            address: data.address ?? '',
            cardNo: data.cardNo,
            cardType: data.cardType,
            gender: data.gender,
            birthday: data.birthday,
            validDate: data.validDate ?? '',
            data: data,
            checkinDate: data.checkinDate,
        }

        const transaction = this.db.transaction(['guestProfiles'], 'readwrite')

        transaction.onerror = () => console.log(`Transaction not opened due to error: ${transaction.error}`)
        transaction.oncomplete = () => console.log("Transaction completed: database modification finished.")

        const objectStore = transaction.objectStore('guestProfiles')
        const getRequest = objectStore.get(data.cardNo)
        getRequest.onsuccess = (e) => {
            const record = e.target.result
            if (!record) {
                objectStore.add(newItem)
            } else {
                objectStore.put(newItem)
            }
        }
    }

    showAll() {
        const list = document.querySelector('history-card').shadowRoot.querySelector('.history-list')
        list.innerHTML = ''

        const initialize = true
        const objectStore = this.db.transaction('guestProfiles').objectStore('guestProfiles')
        objectStore.index('checkinDate').openCursor(null, 'prev').onsuccess = e => {
            /** @type {IDBCursorWithValue | null} */
            const cursor = e.target.result
            if (!cursor) return

            list.appendChild(HistoryCard.createHistoryListItem(cursor.value).content)
            if (initialize) {
                list.firstElementChild.click()
            } else {
                initialize = false
            }
            cursor.continue()
        }
    }

    getAll(index, keyword) {
        if (!keyword) {
            this.showAll()
            return
        }

        const list = document.querySelector('history-card').shadowRoot.querySelector('.history-list')
        list.innerHTML = ''

        const objectStore = this.db.transaction('guestProfiles').objectStore('guestProfiles')
        objectStore.index(index).getAll().onsuccess = e => {
            const result = e.target.result
            const filteredRecords = result.filter(record => record[index].toLowerCase().includes(keyword.toLowerCase()))

            for (const record of filteredRecords) {
                list.appendChild(HistoryCard.createHistoryListItem(record).content)
            }

            list.firstElementChild.click()
        }
    }
}

const PDB = new ProfileDB() 