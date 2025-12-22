/**
 * Extension methods for AutoHotkey GUI controls.
 * Provides utility functions for control lookup and manipulation.
 */
class GuiExt {
    /**
     * Patches the Gui and ListView prototypes with extended methods if enabled in ARConfig.
     */
    static patch() {
        for method, status in ARConfig.enableExtendMethods.gui.OwnProps() {
            if (method == "listview") {
                for lvMethod, lvStatus in status.OwnProps() {
                    if (lvStatus) {
                        Gui.ListView.Prototype.%lvMethod% := ObjBindMethod(this, lvMethod)
                    }
                }
            }
            else if (method == "control") {
                for ctrlMethod, ctrlStatus in status.OwnProps() {
                    if (ctrlMethod == "setFont") {
                        _originalSetFont := Gui.Control.Prototype.setFont
                        Gui.Control.Prototype.DeleteProp("SetFont")
                        Gui.Control.Prototype.setFont := (control, options := "", fontName := "") => (
                            _originalSetFont(control, options, fontName),
                            control
                        )
                        continue
                    }

                    if (ctrlStatus) {
                        Gui.Control.Prototype.%ctrlMethod% := ObjBindMethod(this, ctrlMethod)
                    }
                }
            }
            else if (status) {
                Gui.Prototype.%method% := ObjBindMethod(this, method)
            }
        }
    }

    /**
     * Returns a control from a GUI by its name.
     * @param {Gui} gui - The GUI object.
     * @param {String} name - The name of the control.
     * @returns {Object} The control object.
     * @throws {ValueError} If the control name is not found.
     */
    static getCtrlByName(gui, name) {
        try {
            if (name is String) {
                if (gui.svanerCtrls[name]) {
                    return gui.svanerCtrls[name]
                }

                if (gui[name]) {
                    return gui[name]
                }
            }
        }

        throw ValueError("Control not found.", -1, name)
    }

    /**
     * Returns an Array of controls that fulfills the function.
     * @param {Gui} gui - The GUI Object
     * @param {Func} fn  - Filter function.
     * @returns {Array<Gui.Control>}
     * @throws {ValueError} 
     */
    static getCtrlsByMatch(gui, fn) {
        ctrls := []

        for ctrl in gui {
            if (fn(ctrl)) {
                ctrls.Push(ctrl)
            }
        }

        if (!ctrls.Length) {
            throw ValueError("Control not found.", -1, fn)
        }

        return ctrls
    }

    /**
     * Returns the first control of a given type from a GUI.
     * @param {Gui} gui - The GUI object.
     * @param {string} ctrlType - The type of the control.
     * @returns {Object} The control object.
     * @throws {TypeError} If no control of the type is found.
     */
    static getCtrlByType(gui, ctrlType) {
        for ctrl in gui {
            if (ctrl.Type == ctrlType) {
                return ctrl
            }
        }
        throw TypeError("Control type not found.", -1, ctrlType)
    }

    /**
     * Returns all controls of a given type from a GUI.
     * @param {Gui} gui - The GUI object.
     * @param {string} ctrlType - The type of the control.
     * @returns {Array<Object>} Array of control objects.
     */
    static getCtrlByTypeAll(gui, ctrlType) {
        ctrlArray := []

        for ctrl in gui {
            if (ctrl.Type == ctrlType) {
                ctrlArray.Push(ctrl)
            }
        }

        return ctrlArray
    }

    /**
     * Returns a component from a GUI by its name.
     * @param {Gui | Svaner} targetObj - The GUI/Svaner object.
     * @param {string} componentName - The name of the component.
     * @returns {Object} The component object.
     * @throws {TypeError} If the component is not found.
     */
    static getComponent(targetObj, componentName) {
        for component in targetObj.components {
            if (component.name == componentName) {
                return component
            }
        }
        throw TypeError("Component not found.", -1, componentName)
    }

    /**
     * Returns a control from a GUI by its text or by a predicate function on its text.
     * @param {Gui} gui - The GUI object.
     * @param {string|Func} text - The text to match or a predicate function.
     * @returns {Object} The control object.
     * @throws {ValueError} If no control with the text is found.
     */
    static getCtrlByText(gui, text) {
        for ctrl in gui {
            if (text is Func && text(ctrl.Text)) {
                return ctrl
            } else if (ctrl.Text == text) {
                return ctrl
            }
        }

        throw ValueError("Control with Text not found.", -1, text)
    }

    /**
     * Returns the row numbers of checked items in a ListView control.
     * @param {Gui.ListView} LV - The ListView control.
     * @returns {Array<number>} Array of checked row numbers.
     */
    static getCheckedRowNumbers(LV) {
        checkedRowNumbers := []
        rowNumber := 1
        LVM_GETITEMSTATE := 0x102C
        LVIS_STATEIMAGEMASK := 0xF000

        loop {
            itemState := SendMessage(LVM_GETITEMSTATE, rowNumber - 1, LVIS_STATEIMAGEMASK, LV)
            isChecked := (itemState >> 12) - 1
            if (isChecked) {
                checkedRowNumbers.Push(rowNumber)
            }
            rowNumber++
        } until (A_Index == LV.GetCount())
        
        return checkedRowNumbers
    }

    /**
     * Returns the row numbers of focused items in a ListView control.
     * @param {Gui.ListView} LV - The ListView control.
     * @returns {Array<number>} Array of focused row numbers.
     */
    static getFocusedRowNumbers(LV) {
        focusedRows := []
        rowNumber := 0
        loop {
            rowNumber := LV.GetNext(RowNumber)
            if (!rowNumber) {
                break
            }
            focusedRows.Push(rowNumber)
        }
        return focusedRows
    }

    /**
     * Registers a function to be call when "Change" event is raised.
     * @param {Gui.Control} control The target control.
     * @param eventCallback The callback function when event is raised.
     * @param [delay=1] Delay ms for debounce.
     * @param [addRemove=1] Registers a function or method to be called when the given event is raised.
     *                      -  1 = Call the callback after any previously registered callbacks.
     *                      - -1 = Call the callback before any previously registered callbacks.
     *                      -  0 = Do not call the callback.
     * @returns {Gui.Control} 
     */
    static onChange(control, eventCallback, delay := 0, addRemove := 1) {
        if (delay) {
            inner() => eventCallback(control, 0)
            delayedCallback() => SetTimer(inner, 0 - delay)
        }

        control.OnEvent("Change", !delay ? eventCallback : (ctrl, info) => delayedCallback(), addRemove)

        return control
    }

    /**
     * Registers a function to be call when "Click" event is raised.
     * @param {Gui.Control} control
     * @param {Func} eventCallback The callback function when event is raised.
     * @param [addRemove=1] Registers a function or method to be called when the given event is raised.
     *                      -  1 = Call the callback after any previously registered callbacks.
     *                      - -1 = Call the callback before any previously registered callbacks.
     *                      -  0 = Do not call the callback.
     * @returns {Gui.Control} 
     */
    static onClick(control, eventCallback, addRemove := 1) {
        control.OnEvent("Click", eventCallback, addRemove)

        return control
    }

    /**
     * Registers a function to be call when "DoubleClick" event is raised.
     * @param {Gui.Control} control
     * @param {Func} eventCallback The callback function when event is raised.
     * @param [addRemove=1] Registers a function or method to be called when the given event is raised.
     *                      -  1 = Call the callback after any previously registered callbacks.
     *                      - -1 = Call the callback before any previously registered callbacks.
     *                      -  0 = Do not call the callback.
     * @returns {Gui.Control} 
     */
    static onDoubleClick(control, eventCallback, addRemove := 1) {
        control.OnEvent("DoubleClick", eventCallback)

        return control
    }

    /**
     * Registers a function to be call when "ColClick" event is raised.
     * @param {Gui.Control} control
     * @param {Func} eventCallback The callback function when event is raised.
     * @param [addRemove=1] Registers a function or method to be called when the given event is raised.
     *                      -  1 = Call the callback after any previously registered callbacks.
     *                      - -1 = Call the callback before any previously registered callbacks.
     *                      -  0 = Do not call the callback.
     * @returns {Gui.Control} 
     */
    static onColClick(control, eventCallback, addRemove := 1) {
        control.OnEvent("ColClick", eventCallback, addRemove)

        return control
    }

    /**
     * Registers a function to be call when "ContextMenu" event is raised.
     * @param {Gui.Control} control
     * @param {Func} eventCallback The callback function when event is raised.
     * @param [addRemove=1] Registers a function or method to be called when the given event is raised.
     *                      -  1 = Call the callback after any previously registered callbacks.
     *                      - -1 = Call the callback before any previously registered callbacks.
     *                      -  0 = Do not call the callback.
     * @returns {Gui.Control} 
     */
    static onContextMenu(control, eventCallback, addRemove := 1) {
        control.OnEvent("ContextMenu", eventCallback, addRemove)

        return control
    }

    /**
     * Registers a function to be call when "Focus" event is raised.
     * @param {Gui.Control} control
     * @param {Func} eventCallback The callback function when event is raised.
     * @param [addRemove=1] Registers a function or method to be called when the given event is raised.
     *                      -  1 = Call the callback after any previously registered callbacks.
     *                      - -1 = Call the callback before any previously registered callbacks.
     *                      -  0 = Do not call the callback.
     * @returns {Gui.Control} 
     */
    static onFocus(control, eventCallback, addRemove := 1) {
        control.OnEvent("Focus", eventCallback, addRemove)

        return this
    }

    /**
     * Registers a function to be call when "LoseFocus" event is raised.
     * @param {Gui.Control} control
     * @param {Func} eventCallback The callback function when event is raised.
     * @param [addRemove=1] Registers a function or method to be called when the given event is raised.
     *                      -  1 = Call the callback after any previously registered callbacks.
     *                      - -1 = Call the callback before any previously registered callbacks.
     *                      -  0 = Do not call the callback.
     * @returns {Gui.Control} 
     */
    static onBlur(control, eventCallback, addRemove := 1) {
        control.OnEvent("LoseFocus", eventCallback, addRemove)

        return control
    }

    /**
     * Registers a function to be call when "ItemCheck" event is raised.
     * @param {Gui.Control} control
     * @param {Func} eventCallback The callback function when event is raised.
     * @param [addRemove=1] Registers a function or method to be called when the given event is raised.
     *                      -  1 = Call the callback after any previously registered callbacks.
     *                      - -1 = Call the callback before any previously registered callbacks.
     *                      -  0 = Do not call the callback.
     * @returns {Gui.Control} 
     */
    static onItemCheck(control, eventCallback, addRemove := 1) {
        control.OnEvent("ItemCheck", eventCallback, addRemove)

        return control
    }

    /**
     * Registers a function to be call when "ItemEdit" event is raised.
     * @param {Gui.Control} control
     * @param {Func} eventCallback The callback function when event is raised.
     * @param [addRemove=1] Registers a function or method to be called when the given event is raised.
     *                      -  1 = Call the callback after any previously registered callbacks.
     *                      - -1 = Call the callback before any previously registered callbacks.
     *                      -  0 = Do not call the callback.
     * @returns {Gui.Control} 
     */
    static onItemEdit(control, eventCallback, addRemove := 1) {
        control.OnEvent("ItemEdit", eventCallback, addRemove)

        return control
    }

    /**
     * Registers a function to be call when "ItemExpand" event is raised.
     * @param {Gui.Control} control
     * @param {Func} eventCallback The callback function when event is raised.
     * @param [addRemove=1] Registers a function or method to be called when the given event is raised.
     *                      -  1 = Call the callback after any previously registered callbacks.
     *                      - -1 = Call the callback before any previously registered callbacks.
     *                      -  0 = Do not call the callback.
     * @returns {Gui.Control} 
     */
    static onItemExpand(control, eventCallback, addRemove := 1) {
        control.OnEvent("ItemExpand", eventCallback, addRemove)

        return control
    }

    /**
     * Registers a function to be call when "ItemFocus" event is raised.
     * @param {Gui.Control} control
     * @param {Func} eventCallback The callback function when event is raised.
     * @param [addRemove=1] Registers a function or method to be called when the given event is raised.
     *                      -  1 = Call the callback after any previously registered callbacks.
     *                      - -1 = Call the callback before any previously registered callbacks.
     *                      -  0 = Do not call the callback.
     * @returns {Gui.Control} 
     */
    static onItemFocus(control, eventCallback, addRemove := 1) {
        control.OnEvent("ItemFocus", eventCallback, addRemove)

        return control
    }

    /**
     * Registers a function to be call when "ItemSelect" event is raised.
     * @param {Gui.Control} control
     * @param {Func} eventCallback The callback function when event is raised.
     * @param [addRemove=1] Registers a function or method to be called when the given event is raised.
     *                      -  1 = Call the callback after any previously registered callbacks.
     *                      - -1 = Call the callback before any previously registered callbacks.
     *                      -  0 = Do not call the callback.
     * @returns {Gui.Control} 
     */
    static onItemSelect(control, eventCallback, addRemove := 1) {
        control.OnEvent("ItemSelect", eventCallback, addRemove)

        return control
    }

    /**
     * Gets the selection range(cursor position) of a Gui.Edit
     * @param {Gui.Edit} edit 
     * @returns {[start, end]} 
     */
    static editGetCaret(edit) {
        s := Buffer(4, 0)
        e := Buffer(4, 0)
        EM_GETSEL := 0xB0

        SendMessage(EM_GETSEL, s.Ptr, e.Ptr, edit)
        start := NumGet(s, "UInt")
        end := NumGet(e, "UInt")
        
        return [start, end]
    }

    /**
     * Sets the selection range(cursor position) of a Gui.Edit
     * @param {Gui.Edit} edit 
     * @param position
     */
    static editSetCaret(edit, start, end?) {
        EM_SETSEL := 0xB1

        SendMessage(EM_SETSEL, start, IsSet(end) ? end : start, edit)   
    }
}