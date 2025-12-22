/**
 * Bind values of CheckBox and ListView for check-all status.
 * @param {Gui.CheckBox} CheckBox Target CheckBox.
 * @param {Gui.ListView} ListView Target Control.
 * @param {signal} [depend] Associated signal depend.
 */
shareCheckStatus(CheckBox, ListView, depend := 0) {
    TypeChecker.checkType(CheckBox, Gui.CheckBox, "First parameter is not a Gui.CheckBox")
    TypeChecker.checkType(ListView, Gui.ListView, "Second parameter is not a Gui.ListView")
    if (depend) {
        TypeChecker.checkType(depend, signal, "Third parameter is not a Signal")
    }

    useInternalSignal := depend == 0
    if (useInternalSignal) {
        depend := signal(CheckBox.Value)
        effect(depend, cur => CheckBox.Value := cur)
    }

    ListView.Modify(0, CheckBox.Value == true ? "+Check" : "-Check")

    _handleCheckAll(*) {
        ListView.Modify(0, CheckBox.Value == true ? "+Check" : "-Check")
        if (useInternalSignal) {
            depend.set(CheckBox.Value)
        }
    }

    _handleItemCheck(LV, item, isChecked) {
        ; multi-check
        focusedRows := GuiExt.getFocusedRowNumbers(LV)
        for focusedRow in focusedRows {
            LV.Modify(focusedRow, isChecked ? "Check" : "-Check")
        }

        checkedRows := GuiExt.getCheckedRowNumbers(LV)
        depend.set(checkedRows.Length == LV.GetCount())
    }

    CheckBox.OnEvent("Click", _handleCheckAll)
    ListView.OnEvent("ItemCheck", _handleItemCheck)
}