class useFileDB {
	/**
	 * @param {Object} dbConfig 
	 */
	__New(dbConfig) {
		this.main := dbConfig.main,
			this.archive := dbConfig.HasOwnProp("archive") ? dbConfig.archive : ""
		this.backup := dbConfig.HasOwnProp("backup") ? dbConfig.backup : ""
		this.cleanPeriodDays := dbConfig.HasOwnProp("cleanPeriodDays") ? dbConfig.cleanPeriodDays : 180
		this.cacheKey := dbConfig.HasOwnProp("cacheKey") ? dbConfig.cacheKey : ""

		if (this.cacheKey) {
			this.cache := this.load(, , 60 * 24)
		}
	}

	cleanup() {
		loop files, this.main . "\*", "D" {
			if (DateDiff(A_Now, A_LoopFileName, "Days") > this.cleanPeriodDays) {
				DirDelete(A_LoopFileFullPath, true)
			}
		}
	}

	/**
	 * 
	 * @param {String} jsonString 
	 * @param {String} date 
	 * @param {String} saveName 
	 */
	add(jsonString, date := FormatTime(A_Now, "yyyyMMdd"), saveName := "") {
		if (!saveName) {
			res := JSON.parse(jsonString)
			if (res is Error) {
				MsgBox("Unable to add data.`nError: " . res.Message, , "0x10")
				return
			}

			saveName := res.Has("fileName") ? res["fileName"] : A_Now
		}

		dateFolder := "\" . date
		fileName := "\" . saveName . ".json"
		; create dateFolder if not exist yet
		if (!DirExist(this.main . dateFolder)) {
			DirCreate(this.main . dateFolder)
		}
		if (FileExist(this.main . dateFolder . fileName)) {
			return
		}
		FileAppend(jsonString, this.main . dateFolder . fileName, "UTF-8")
		Sleep(100)
		; cleanup outdated if cleanPeriod is unset/0
		if (this.cleanPeriodDays > 0) {
			this.cleanup()
		}
	}

	/**
	 * 
	 * @param {String} db 
	 * @param {String}  queryDate 
	 * @param {Number}  queryPeriodInput 
	 * @returns {String[]} 
	 */
	getPathsByPeriod(db, queryDate, queryPeriodInput) {
		matchFilePaths := []
		loop files, (db . "\" . queryDate . "\*.json") {
			if (DateDiff(A_Now, A_LoopFileTimeCreated, "Minutes") <= queryPeriodInput) {
				matchFilePaths.InsertAt(1, A_LoopFileFullPath)
			}
		}

		return matchFilePaths
	}

	/**
	 * 
	 * @param {String} db 
	 * @param {String}  queryDate 
	 * @param {Number}  queryPeriodInput 
	 * @return {Array<Map>}
	 */
	load(db := this.main, queryDate := FormatTime(A_Now, "yyyyMMdd"), queryPeriodInput := 60) {
		if (queryDate == FormatTime(A_Now, "yyyyMMdd")) {
			return this.loadOneDay(db, queryDate, queryPeriodInput)
		}
		else if (FileExist(this.archive . "\" . queryDate . " - archive.json")) {
			return this.loadArchiveOneDay(queryDate)
		}
		else {
			if (!FileExist(this.archive . "\" . queryDate . " - archive.json")) {
				if (DateDiff(A_Now, queryDate, "Days") > 0) {
					SetTimer(() => this.createArchive(queryDate), -100)
				}
				return this.loadOneDay(db, queryDate, 60 * 24 * this.cleanPeriodDays)
			}
		}
	}

	/**
	 * 
	 * @param {String} db 
	 * @param {String}  queryDate 
	 * @param {Number}  queryPeriodInput 
	 * @return {Array<Map>}
	 */
	loadOneDay(db := this.main, queryDate := FormatTime(A_Now, "yyyyMMdd"), queryPeriodInput := 60) {
		queryPeriod := queryPeriodInput
		parsedData := []

		; using cache
		; if (this.HasOwnProp("cache") && this.cache.Length) {
		; 	min := this.cache[1][this.cacheKey].toFormat("yyyyMMddHHmm")
		; 	queryPeriod := A_Now.toFormat("yyyyMMddHHmm").minutesBetween(min) + 1

		; 	parsedData := this.cache.filter(item => item[this.cacheKey].toFormat("yyyyMMddHHmm") != min)
		; }

		loadedPaths := this.getPathsByPeriod(db, queryDate, queryPeriod)

		for file in loadedPaths {
			jsonStr := FileRead(file, "UTF-8")

			res := JSON.parse(jsonStr)
			if (res is Error) {
				parsedData.InsertAt(A_Index, this._handleMalformedJson(jsonStr).map(profile => JSON.parse(profile))*)
				FileCopy(file, file.replace(".json", ".malformed"))
			} else {
				parsedData.Push(res)
			}
		}

		; if (this.HasOwnProp("cache")) {
		; 	this.cache := parsedData
		; }

		return parsedData
	}

	/**
	 * @param {String} malformedString
	 * @returns {Array}
	 */
	_handleMalformedJson(malformedString) {
		if (!malformedString.includes("}{")) {
			return []
		}

		return JSON.parse("[" . malformedString.replace("}{", "}, {") . "]").map(profile => JSON.stringify(profile)).unique()
	}

	/**
	 * 
	 * @param newJsonString 
	 * @param queryDate 
	 * @param fileName 
	 */
	updateOne(newJsonString, queryDate, fileName) {
		loop files, (this.main . "\" . queryDate . "\*.json") {
			if (fileName . ".json" = A_LoopFileName) {
				FileDelete(A_LoopFileFullPath)
				FileAppend(newJsonString, this.main . "\" . queryDate . "\" . filename . ".json", "UTF-8")
			}
		}

		if (queryDate != FormatTime(A_Now, "yyyyMMdd")) {
			if (this.archive) {
				this.createArchive(queryDate)
			}
			if (this.backup) {
				this.createArchiveBackup(queryDate)
			}
		}
	}

	/**
	 * 
	 * @param archiveDate 
	 */
	createArchive(archiveDate) {
		archiveDataStr := JSON.stringify(this.loadOneDay(, archiveDate, 60 * 24 * this.cleanPeriodDays))
		archiveFullPath := this.archive . "\" . archiveDate . " - archive.json"
		if (FileExist(archiveFullPath)) {
			FileDelete(archiveFullPath)
		}

		FileAppend(archiveDataStr, archiveFullPath, "UTF-8")

		return archiveFullPath
	}

	/**
	 * 
	 * @param archiveDate 
	 * @return {Array<Map>}
	 */
	loadArchiveOneDay(archiveDate) {
		archiveFullPath := this.archive . "\" . archiveDate . " - archive.json"
		; try {
		; 	archivedData := JSON.parse(FileRead(archiveFullPath, "UTF-8"))
		; } catch {
		; 	this.createArchive(archiveDate)
		; 	archivedData := JSON.parse(FileRead(archiveFullPath, "UTF-8"))
		; }
		res := JSON.parse(FileRead(archiveFullPath, "UTF-8"))
		archivedData := res is Error ? JSON.parse(this.createArchive(archiveDate)) : res

		return archivedData
	}

	createArchiveBackup(backupDate) {
		archiveData := JSON.stringify(this.loadOneDay(, backupDate, 60 * 24 * this.cleanPeriodDays))
		monthFolder := "\" . SubStr(backupDate, 1, 6)
		backupFullPath := this.backup . monthFolder . "\" . backupDate . " - backup.json"

		if (!DirExist(this.backup . monthFolder)) {
			DirCreate(this.backup . monthFolder)
		}
		if (FileExist(backupFullPath)) {
			FileDelete(backupFullPath)
		}

		FileAppend(archiveData, backupFullPath, "UTF-8")

		return archiveData
	}

	; restoreRecent() {
	; 	recent := JSON.parse(FileRead(this.backup . "\recent.json", "UTF-8"))
	; 	for snippet in recent {
	; 		this.add(JSON.stringify(snippet))
	; 	}
	; }

	restoreArchiveOneDay(restoreDate) {
		monthFolder := "\" . SubStr(restoreDate, 1, 6)
		loop files, (this.backup . monthFolder . "\*.json") {
			if (!InStr(A_LoopFileName, restoreDate)) {
				continue
			}

			archive := FileRead(A_LoopFileFullPath, "UTF-8")
			filename := StrReplace(A_LoopFileName, "backup", "archive")
			archiveFullPath := this.archive . "\" . filename

			if (FileExist(archiveFullPath)) {
				FileDelete(archiveFullPath)
			}
			FileAppend(archive, archiveFullPath, "UTF-8")
			break
		}
	}
}