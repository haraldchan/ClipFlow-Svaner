class PsbSheetExporter {
    static template := A_ScriptDir . "\src\modules\profile-modify-next\templates\psb-upload-template.xlsx"
    static TITLE_ROW := 4
    static progressBar := ""

    /**
     * @param {Array} profiles
     * @param {String} saveDest
     */
    static export(profiles, saveDest, progressBar) {
        if (!profiles.Length) {
            return 
        }

        this.progressBar := progressBar

        try {
            xl := ComObject("Ket.Application")
        } catch {
            xl := ComObject("Excel.Application")
        }

        try {
            book := Xl.Workbooks.Open(this.template)
        } catch Error as err {
            msgbox(err.Message, "旅客信息导出", "4096 T2 iconx")
            return
        }

        this.handleExportToSheet(book, profiles)

        try {
            book.SaveAs(saveDest . "\旅客填报模板.xlsx")
        } catch Error as err {
            msgbox(err.Message, "旅客信息导出", "4096 T2 iconx")
        }

        xl.Quit()
        MsgBox("导出已完成。", "旅客信息导出", "4096 T1 iconi")
    }

    /**
     * @param {Worksheet} sheet
     * @return {Map<String, Integer>}
     */
    static getColNumbers(sheet) {
        colTitlesMap := Map(
            "serial", "序号",
            "name", "中文名*",
            "nameLast", "英文姓*",
            "nameLastNonRequired", "英文姓",
            "nameFirst", "英文名*",
            "nameFirstNonRequired", "英文名",
            "idType", "证件类型*",
            "idNum", "证件号码*",
            "gender", "性别*",
            "birthday", "出生日期*",
            "addr", "常住地址*",
            "ethnic", "民族*",
            "regTime", "入住时间*",
            "roomNum", "房号*",
            "tel", "联系电话*",
            "staff", "登记人员*",
            "region", "地区*",
            "country", "国籍/地区*",
            "guardianName", "监护人",
            "guardianTel", "监护人电话",
            "guardianRelation", "关系",
        )

        cols := Map()
        for key, title in colTitlesMap {
            colFound := sheet.Rows(this.TITLE_ROW).Find(title)
            if (colFound) {
                cols[key] := colFound.Column
            }
        }
        return cols
    }

    /**
     * @param {Workbook} book 
     * @param {Array} profiles 
     */
    static handleExportToSheet(book, profiles) {
        sheetMainland := book.Worksheets("内地旅客")
        sheetHkMoTw := book.Worksheets("港澳台旅客")
        sheetForeign := book.Worksheets("国外旅客")
        colsMainland := this.getColNumbers(sheetMainland)
        colsHkMoTw := this.getColNumbers(sheetHkMoTw)
        colsForeign := this.getColNumbers(sheetForeign)

        sheetRef := Map(
            "内地旅客", Map("sheet", sheetMainland, "cols", colsMainland),
            "港澳台旅客", Map("sheet", sheetHkMoTw, "cols", colsHkMoTw),
            "国外旅客", Map("sheet", sheetForeign, "cols", colsForeign),
        )

        for profile in profiles {
            guestType := profile["guestType"]
            sheet := sheetRef[guestType]["sheet"]
            cols := sheetRef[guestType]["cols"]
            row := sheet.Cells(sheet.Rows.Count, "A").End(-4162).Row + 1

            for key, val in profile {
                if (key == "guardianInfo") {
                    for guardianInfoKey, guardianInfoValue in val {
                        sheet.Cells(row, cols[guardianInfoKey]).Value := guardianInfoValue
                    }
                    continue
                }

                if (cols.Has(key)) {
                    if (guestType == "港澳台旅客" && (key == "lastName" || key == "firstName")) {
                        sheet.Cells(row, cols[key . "NonRequired"]).Value := val
                        continue
                    }

                    if (key == "name") {
                        val := val.replace("👤", "")
                    }
                    else if (key == "birthday") {
                        if (DateDiff(A_Now.toFormat("yyyyMMdd"), val.replace("-", ""), "Days") / 365 < 18) {
                            BGR_RED := 0x0000FF
                            sheet.Cells(row, cols[key]).Font.Color := BGR_RED
                        }
                    }
                    else if (key == "regTime") {
                        val := val.toFormat("yyyy-MM-dd HH:mm")
                    }

                    sheet.Cells(row, cols[key]).Value := val
                }
            }

            sheet.Cells(row, cols["serial"]).Value := row - this.TITLE_ROW
            if (guestType == "内地旅客") {
                sheet.Cells(row, cols["ethnic"]).Value := "汉"
            }

            this.progressBar.value++
        }
    }
}