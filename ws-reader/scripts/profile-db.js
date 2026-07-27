class ProfileDB {
    constructor() {
        /** @type {IDBDatabase | undefined} */
        this.db

        const objectStoreIndexes = [
            "curPhoto",
            "ocrPhoto",
            "name",
            "nameLast",
            "nameFirst",
            "roomNum",
            "tel",
            "guestType",
            "region",
            "address",
            "cardNo",
            "cardType",
            "gender",
            "birthday",
            "validDate",
            "regTime"
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

    /**
     * @param {object} data 
     */
    add(newItem) {
        const transaction = this.db.transaction(['guestProfiles'], 'readwrite')

        transaction.onerror = () => console.log(`Transaction not opened due to error: ${transaction.error}`)
        transaction.oncomplete = () => console.log("Transaction completed: database modification finished.")

        const objectStore = transaction.objectStore('guestProfiles')
        const getRequest = objectStore.get(newItem.cardNo)
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

        const objectStore = this.db.transaction('guestProfiles').objectStore('guestProfiles')
        objectStore.index('regTime').openCursor(null, 'prev').onsuccess = e => {
            /** @type {IDBCursorWithValue | null} */
            const cursor = e.target.result
            if (!cursor) {
                list.firstElementChild.click()
                return
            }

            list.appendChild(HistoryCard.createHistoryListItem(cursor.value).content)
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

            if (list.firstElementChild) {
                list.firstElementChild.click()
            } else {
                HistoryCard.handleHistoryDetailUpdate()
            }
        }
    }
}

const PDB = new ProfileDB() 