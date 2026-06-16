/**
 * @typedef {Object} SvanerConfigs
 * @property { { options?: String, title?: String } } gui
 * @property { { options?: String, name?: String } } font
 * @property { { [key: String]: ()=>void } } events
 * @property { { border?: false } } devOpt
 */

class Svaner {
    /**
     * Initialize a Svaner object.
     * ```
     * {
     *      gui: {
     *          options: "+AlwaysOnTop +Resize ...",
     *          title: A_ScriptName
     *      },
     *      font: {
     *          options: "s12 bold",
     *          name: "Tahoma"
     *      },
     *      events: {
     *          close: (thisGui) => thisGui.Destroy(),
     *          ; ...
     *      },
     *      devOpt: {
     *          border: false
     *      }
     * }
     * ```
     * @param {SvanerConfigs} SvanerConfigs 
     * @returns {Svaner}
     */
    __New(SvanerConfigs := {
        gui: {
            options: "",
            title: A_ScriptName
        },
        font: {
            name: "Tahoma"
        },
        events: {
            close: (thisGui) => thisGui.Destroy()
        },
        devOpt: {
            border: false
        }
    }) {
        ; create gui
        if (SvanerConfigs.HasOwnProp("gui")) {
            guiOptions := SvanerConfigs.gui.HasOwnProp("options") ? SvanerConfigs.gui.options : ""
            guiTitle := SvanerConfigs.gui.HasOwnProp("title") ? SvanerConfigs.gui.title : A_ScriptName
        }

        this.gui := Gui(IsSet(guiOptions) ? guiOptions : "", IsSet(guiTitle) ? guiTitle : A_ScriptName)

        this.events := []
        if (SvanerConfigs.HasOwnProp("events")) {
            for event, callback in SvanerConfigs.events.OwnProps() {
                this.gui.OnEvent(event, callback)
            }
        }

        ; add svaner control map
        this.gui.svanerCtrls := Map()
        this.gui.svanerCtrls.Default := ""

        ; set font
        this.font := { options: "", name: "" }
        if (SvanerConfigs.HasOwnProp("font")) {
            this.gui.SetFont(
                SvanerConfigs.font.HasOwnProp("options") ? SvanerConfigs.font.options : "",
                SvanerConfigs.font.HasOwnProp("name") ? SvanerConfigs.font.name : ""
            )
        }

        this.devOpt := {}
        if (SvanerConfigs.HasOwnProp("devOpt")) {
            this.devOpt := SvanerConfigs.devOpt
        }

        ; components
        this.components := Map()

        ; add option parser
        this.optParser := OptionParser(this)
    }


    /**
     * Retrieves the GuiControl object associated with the specified condition.
     * @param {String | Func} ctrlSearchCondition directive/function to search target control.                                        
     * prefixes: - "type:{type-name}": returns the first type matched control
     *           - "typeAll:{type-name}": returns all type matched control in an array.
     *           - "component:{component-name}": returns a component.
     *           - "#{attribute}": returns an array of controls with the same attribute.
     *           - "#{attribute}={value}": returns an array of controls with the same attribute value.
     * @returns {Gui.Control | Array<Gui.Control> | Component}
     */
    __Item[ctrlSearchCondition] {
        get {
            if (ctrlSearchCondition is func) {
                return GuiExt.getCtrlsByMatch(this.gui, ctrlSearchCondition)
            }

            switch {
                ; by type
                case StringExt.startsWith(ctrlSearchCondition, "type:"):
                    return GuiExt.getCtrlByType(this.gui, StrReplace(ctrlSearchCondition, "type:", ""))

                ; by type all
                case StringExt.startsWith(ctrlSearchCondition, "typeAll:"):
                    return GuiExt.getCtrlByTypeAll(this.gui, StrReplace(ctrlSearchCondition, "typeAll:", ""))

                ; search component
                case StringExt.startsWith(ctrlSearchCondition, "component:"):
                    return this.components[StrReplace(ctrlSearchCondition, "component:")]

                ; by attribute
                case (StringExt.startsWith(ctrlSearchCondition, "#") && !InStr(ctrlSearchCondition, "=")):
                    attr := pipe(
                        res => StrReplace(res, "#", "", , , 1),
                        res => StringExt.toCase(res, "camel")
                    )(ctrlSearchCondition)

                    return GuiExt.getCtrlsByMatch(this.gui, ctrl => ctrl.attributes.HasOwnProp(attr))

                ; by attribute with matched value
                case (StringExt.startsWith(ctrlSearchCondition, "#") && InStr(ctrlSearchCondition, "=")):
                    pair := pipe(
                        res => StrReplace(res, "#", "", , , 1),
                        res => StrSplit(res, "=")
                    )(ctrlSearchCondition)

                    return GuiExt.getCtrlsByMatch(
                        this.gui,
                        ctrl => ctrl.attributes.HasOwnProp(StringExt.toCase(pair[1], "kebab")) && ctrl.attributes.%pair[1]% == pair[2]
                    )

                ; by name(same as Gui.__Item)
                default:
                    return GuiExt.getCtrlByName(this.gui, ctrlSearchCondition)
            }
        }
    }


    /**
     * Parse options/directives to native options.
     * @param {String} optionString 
     * @returns { {parsed: String, callbacks: Func[], attributes: Object<String, String>} } 
     */
    __parseOptions(optionString) {
        if (!InStr(optionString, "@") && !InStr(optionString, "#")) {
            return {
                parsed: (this.devOpt.HasOwnProp("border") && this.devOpt.border == true) ? optionString . " Border " : optionString,
                callbacks: [],
                attributes: {}
            }
        }

        parsed := ""
        optCallbacks := []
        attributes := {}
        splittedOptions := StrSplit(optionString, " ")

        for opt in splittedOptions {
            ; parse directives
            res := this.optParser.parseDirective(opt, optCallbacks)
            ; define attributes
            if (StringExt.startsWith(res, "#")) {
                pair := pipe(
                    res => StrReplace(res, "#", "", , , 1),
                    res => StrSplit(res, "=")
                )(res)

                if (pair.Length == 1) {
                    pair.Push("")
                }

                attributes.DefineProp(StringExt.toCase(pair[1], "camel"), { value: pair[2] })
                continue
            }

            if (res is Func) {
                optCallbacks.Push(res)
            } else {
                parsed .= Format(" {1} ", res)
            }
        }

        return {
            parsed: (this.devOpt.HasOwnProp("border") && this.devOpt.border == true) ? parsed . " Border " : parsed,
            callbacks: optCallbacks,
            attributes: attributes
        }
    }


    /**
     * Apply custom directives to control.
     * @param {Svaner.Control | Gui.Control} control 
     * @param {Array<Func>} callbacks 
     * @param {Object<string, string>} attributes 
     */
    __applyCallbackAndAttributes(control, callbacks, attributes) {
        ctrl := control is Gui.Control ? control : control.ctrl

        for callback in callbacks {
            callback(ctrl)
        }

        ctrl.attributes := attributes
    }


    /**
     * Sets various options and styles for the appearance and behavior of the gui window.
     * @param {String} options options apply to the gui window.
     */
    Opt(options) => this.gui.Opt(options)


    /**
     * Show Gui window.
     * @param {String} [options] 
     */
    Show(options := "") => this.gui.Show(options)


    /**
     * Hide Gui Window.
     */
    Hide() => this.gui.Hide()


    /**
     * Destroy Gui window.
     */
    Destroy() => this.gui.Destroy()


    /**
     * Collect values from named controls and combine them into an object, optionally hiding the window.
     * @param {true | false} hide 
     * @param {"camel" | "pascal" | "kebab" | "snake" | "constant"} keyCasing
     */
    Submit(hide := true, keyCasing := "camel") {
        form := this.gui.Submit(hide)
        fmtForm := {}

        for key, val in form.OwnProps() {
            fmtForm.defineProp(StringExt.toCase(key, keyCasing), { value: val })
        }

        return fmtForm
    }


    /**
     * Define custom directives.
     * @param {[String, String | ()=>void, *]} directiveDescriptor 
     */
    defineDirectives(directiveDescriptor*) {
        this.optParser.defineDirectives(Map(directiveDescriptor*))
    }


    /**
     * Add a Button/SvanerButton control to Gui.
     * @param {String} options Options/Directives apply to the control.
     * @param {String} content Text or formatted text to hold signal values.
     * @param {signal} [depend] Subscribed signal.
     * @param {String|Array|Object} [key] the keys or index of the signal's value.
     * @returns {SvanerButton | Gui.Button} 
     */
    AddButton(options := "", content := "", depend?, key?) {
        parsedOptions := this.__parseOptions(options)

        control := IsSet(depend)
            ? SvanerButton(this.gui, parsedOptions.parsed, content, (IsSet(depend) ? depend : 0), (IsSet(key) ? key : 0))
            : this.gui.AddButton(parsedOptions.parsed, content)
        this.__applyCallbackAndAttributes(control, parsedOptions.callbacks, parsedOptions.attributes)

        return control
    }


    /**
     * Add a CheckBox/SvanerCheckBox control to Gui.
     * @param {String} options Options apply to the control, same as Gui.Add.
     * @param {string} content Text or formatted text to hold signal values.
     * @param {signal} [depend] Subscribed signal
     * @param {array} [key] the keys or index of the signal's value
     * @returns {SvanerCheckBox | Gui.CheckBox} 
     */
    AddCheckBox(options, content := "", depend?, key?) {
        parsedOptions := this.__parseOptions(options)

        control := IsSet(depend)
            ? SvanerCheckBox(this.gui, parsedOptions.parsed, content, (IsSet(depend) ? depend : 0), (IsSet(key) ? key : 0))
            : this.gui.AddCheckbox(parsedOptions.parsed, content)
        this.__applyCallbackAndAttributes(control, parsedOptions.callbacks, parsedOptions.attributes)

        return control
    }


    /**
     * Add a ComboBox/SvanerComboBox control to Gui.
     * @param options Options/Directives apply to the control.
     * @param {Array | signal} listOrDepend List items/ Subsribed signal
     * @param {String | Array | Object} [key] the keys or index of the signal's value.
     * @returns {SvanerComboBox | Gui.ComboBox} 
     */
    AddComboBox(options, listOrDepend := [], key?) {
        parsedOptions := this.__parseOptions(options)

        control := listOrDepend is Array
            ? this.gui.AddComboBox(parsedOptions.parsed, listOrDepend)
            : SvanerComboBox(this.gui, parsedOptions.parsed, listOrDepend, (IsSet(key) ? key : 0))
        this.__applyCallbackAndAttributes(control, parsedOptions.callbacks, parsedOptions.attributes)

        return control
    }

    /**
     * Add a DateTime/SvanerDateTime control to Gui.
     * @param {String} options Options/Directives apply to the control.
     * @param {String} dateFormat Date Format to show.
     * @param {signal} [depend] Subsribed signal.
     * @returns {SvanerDateTime | Gui.DateTime} 
     */
    AddDateTime(options, dateFormat := "yyyy/MM/dd", depend?, key?) {
        parsedOptions := this.__parseOptions(options)

        control := IsSet(depend)
            ? SvanerDateTime(this.gui, parsedOptions.parsed, dateFormat, depend, (IsSet(key) ? key : 0))
            : this.gui.AddDateTime(parsedOptions.parsed, dateFormat)
        this.__applyCallbackAndAttributes(control, parsedOptions.callbacks, parsedOptions.attributes)

        return control
    }


    /**
     * Add a DropDownList/DropDownList control to Gui.
     * @param options Options/Directives apply to the control.
     * @param {Array | signal} listOrDepend List items/ Subsribed signal.
     * @param {String | Array | Object} [key] the keys or index of the signal's value.
     * @returns {SvanerDropDownList | Gui.DDL} 
     */
    AddDropDownList(options, listOrDepend, key?) {
        parsedOptions := this.__parseOptions(options)

        control := listOrDepend is Array
            ? this.gui.AddDDL(parsedOptions.parsed, listOrDepend)
            : SvanerDropDownList(this.gui, parsedOptions.parsed, listOrDepend)
        this.__applyCallbackAndAttributes(control, parsedOptions.callbacks, parsedOptions.attributes)

        return control
    }
    /**
     * Add a DropDownList/DropDownList control to Gui.
     * @param options Options/Directives apply to the control.
     * @param {Array | signal} listOrDepend List items/ Subsribed signal.
     * @param {String | Array | Object} [key] the keys or index of the signal's value.
     * @returns {SvanerDropDownList | Gui.DDL} 
     */
    AddDDL(options, listOrDepend, key?) => this.AddDropDownList(options, listOrDepend, IsSet(key) ? key : 0)


    /**
     * Add a Edit/SvanerEdit control to Gui.
     * @param {String} options Options/Directives apply to the control.
     * @param {String} content Text or formatted text to hold signal values.
     * @param {signal} [depend] Subscribed signal.
     * @param {String | Array | Object} [key] the keys or index of the signal's value.
     * @returns {SvanerEdit | Gui.Edit} 
     */
    AddEdit(options := "", content := "", depend?, key?) {
        parsedOptions := this.__parseOptions(options)

        control := IsSet(depend)
            ? SvanerEdit(this.gui, parsedOptions.parsed, content, (IsSet(depend) ? depend : 0), (IsSet(key) ? key : 0))
            : this.gui.AddEdit(parsedOptions.parsed, content)
        this.__applyCallbackAndAttributes(control, parsedOptions.callbacks, parsedOptions.attributes)

        return control
    }


    /**
     * Add a Edit/SvanerEdit control to Gui.
     * @param {String} options Options/Directives apply to the control.
     * @param {String} content Text or formatted text to hold signal values.
     * @param {signal} [depend] Subscribed signal.
     * @param {String | Array | Object} [key] the keys or index of the signal's value.
     * @returns {SvanerGroupBox | Gui.GroupBox} 
     */
    AddGroupBox(options, content := "", depend?, key?) {
        parsedOptions := this.__parseOptions(options)

        control := IsSet(depend)
            ? SvanerGroupBox(this.gui, parsedOptions.parsed, content, (IsSet(depend) ? depend : 0), (IsSet(key) ? key : 0))
            : this.gui.AddGroupBox(parsedOptions.parsed, content)
        this.__applyCallbackAndAttributes(control, parsedOptions.callbacks, parsedOptions.attributes)

        return control
    }


    /**
     * Add a Hotkey control to Gui.
     * @param {String} options 
     * @returns {Gui.Hotkey} 
     */
    AddHotkey(options, hotkeyString) {
        parsedOptions := this.__parseOptions(options)

        control := this.gui.AddHotkey(parsedOptions.parsed, hotkeyString)
        this.__applyCallbackAndAttributes(control, parsedOptions.callbacks, parsedOptions.attributes)

        return control
    }


    /**
     * Add a Link control to Gui.
     * @param {String} options 
     * @param {String} text 
     * @param {Object | Array} [linkInfo] 
     * @returns {Gui.Link} 
     */
    AddLink(options := "", text := "", linkInfo?) {
        parsedOptions := this.__parseOptions(options)

        if (IsSet(linkInfo)) {
            a := "<a href=`"{2}`" id=`"{3}`">{1}</a>"

            if (linkInfo.base == Object.Prototype) {
                anchorEl := Format(a, linkInfo.text, linkInfo.href, linkInfo.HasOwnProp("id") ? linkInfo.id : "")
                linkText := Format(text, anchorEl)
            }
            else if (linkInfo is Array) {
                anchorEls := []
                for info in linkInfo {
                    anchorEl := Format(a, info.text, info.href, info.HasOwnProp("id") ? info.id : "")
                    anchorEls.Push(anchorEl)
                }
                linkText := Format(text, anchorEls*)
            }
        }

        control := IsSet(linkInfo)
            ? this.gui.AddLink(parsedOptions.parsed, linkText)
            : this.gui.AddLink(parsedOptions.parsed, text)
        this.__applyCallbackAndAttributes(control, parsedOptions.callbacks, parsedOptions.attributes)

        return control
    }


    /**
     * Add a ListBox/SvanerListBox control to Gui.
     * @param {String} options Options/Directives apply to the control.
     * @param {Array | signal} listOrDepend List items/ Subsribed signal.
     * @returns {Gui.ListBox} 
     */
    AddListBox(options, listOrDepend) {
        parsedOptions := this.__parseOptions(options)

        control := listOrDepend is signal
            ? SvanerListBox(this.gui, parsedOptions.parsed, , listOrDepend)
            : this.gui.AddListBox(parsedOptions.parsed, listOrDepend)
        this.__applyCallbackAndAttributes(control, parsedOptions.callbacks, parsedOptions.attributes)

        return control
    }


    /**
     * Add a ListView/SvanerListView control to Gui.
     * @param { {lvOptions: Array<String>, itemOptions: Array<String>} | String} options Options/Directives apply to the control.
     * @param { {keys: Array<String>, titles: Array<String>, width: Array<Number>} | Array<String>} columnDetailsOrList 
     * @param {signal} [depend] Subscribed signal.
     * @param {String|Array|Object} [key] the keys or index of the signal's value.
     * @returns {SvanerListView | Gui.ListView}
     */
    AddListView(options, columnDetailsOrList, depend?, key?) {
        if (options is Object) {
            ; SvanerListView
            parsedLvOptions := this.__parseOptions(options.lvOptions)
            parsedItemOptions := options.HasOwnProp("itemOptions")
                ? this.__parseOptions(options.itemOptions)
                : { parsed: "", callbacks: [] }
        }
        else {
            ; Native ListView
            parsedLvOptions := this.__parseOptions(options)
        }

        control := IsSet(depend) && depend is signal
            ? SvanerListView(
                this.gui, { lvOptions: parsedLvOptions.parsed, itemOptions: parsedItemOptions.parsed },
                columnDetailsOrList, depend, (IsSet(key) ? key : 0))
            : this.gui.AddListView(parsedLvOptions.parsed, columnDetailsOrList)

        if (control is SvanerListView && (parsedLvOptions.callbacks || parsedItemOptions.callbacks)) {
            callbacks := ArrayExt.append(parsedLvOptions.callbacks, parsedItemOptions.callbacks)
        }

        this.__applyCallbackAndAttributes(control, IsSet(callbacks) ? callbacks : [], parsedLvOptions.attributes)

        return control
    }


    /**
     * Add a MonthCal/SvanerMonthCal control to Gui.
     * @param {String} [options] Options/Directives apply to the control.
     * @param {signal} [depend] Subscribed signal.
     * @returns {Gui.MonthCal} 
     */
    AddMonthCal(options := "", dateOrDepend?) {
        parsedOptions := this.__parseOptions(options)

        control := IsSet(dateOrDepend)
            ? SvanerMonthCal(this.gui, parsedOptions.parsed, dateOrDepend)
            : this.gui.AddMonthCal(parsedOptions.parsed, IsSet(dateOrDepend) ? dateOrDepend : FormatTime(A_Now, "yyyyMMdd"))
        this.__applyCallbackAndAttributes(control, parsedOptions.callbacks, parsedOptions.attributes)

        return control
    }


    /**
     * Add a Picture/SvanerPicture control to Gui.
     * @param {String} options 
     * @param {String | signal} PicFilepathOrDepend 
     * @param {String | Array | Object} [key] the keys or index of the signal's value.
     * @returns {SvanerPicture | Gui.Pic} 
     */
    AddPicture(options, PicFilepathOrDepend, key?) {
        parsedOptions := this.__parseOptions(options)

        control := PicFilepathOrDepend is String
            ? this.gui.AddPicture(parsedOptions.parsed, PicFilepathOrDepend)
            : SvanerPicture(this.gui, parsedOptions.parsed, PicFilepathOrDepend, (IsSet(key) ? key : 0))
        this.__applyCallbackAndAttributes(control, parsedOptions.callbacks, parsedOptions.attributes)

        return control
    }
    /**
     * Add a Picture/SvanerPicture control to Gui.
     * @param {String} options 
     * @param {String | signal} PicFilepathOrDepend 
     * @param {String | Array | Object} [key] the keys or index of the signal's value.
     * @returns {SvanerPicture | Gui.Pic} 
     */
    AddPic(options, PicFilepathOrDepend, key?) => this.AddPicture(options, PicFilepathOrDepend, IsSet(key) ? key : 0)


    /**
     * Add a Progress control to Gui.
     * @param {String} options 
     * @param {Integer} startingPos 
     * @returns {Gui.Progress} 
     */
    AddProgress(options, startingPos := 0) {
        parsedOptions := this.__parseOptions(options)

        control := this.gui.AddProgress(parsedOptions.parsed, startingPos)
        this.__applyCallbackAndAttributes(control, parsedOptions.callbacks, parsedOptions.attributes)

        return control
    }


    /**
     * Add a Radio/SvanerRadio control to Gui
     * @param {String} options Options/Directives apply to the control.
     * @param {String} content Text or formatted text to hold signal values.
     * @param {signal} [depend] Subscribed signal.
     * @param {String | Array | Object} [key] the keys or index of the signal's value.
     * @returns {SvanerRadio | Gui.Radio} 
     */
    AddRadio(options, content := "", depend?, key?) {
        parsedOptions := this.__parseOptions(options)

        control := IsSet(depend)
            ? SvanerRadio(this.gui, parsedOptions.parsed, content, (IsSet(depend) ? depend : 0), (IsSet(key) ? key : 0))
            : this.gui.AddRadio(parsedOptions.parsed, content)
        this.__applyCallbackAndAttributes(control, parsedOptions.callbacks, parsedOptions.attributes)

        return control
    }


    /**
     * Add a Radio/SvanerRadio control to Gui
     * @param {String} [options] Options/Directives apply to the control.
     * @param {Integer | signal} [startingPosOrDepend] Starting position of the slider/ Subsribed signal associates with slider value.
     * @param {String | Array | Object} [key] the keys or index of the signal's value.
     * @returns {SvanerSlider | Gui.Slider} 
     */
    AddSlider(options := "", startingPosOrDepend := 0, key?) {
        parsedOptions := this.__parseOptions(options)

        control := startingPosOrDepend is Number
            ? this.gui.AddSlider(parsedOptions.parsed, startingPosOrDepend)
            : SvanerSlider(this.gui, parsedOptions.parsed, startingPosOrDepend, (IsSet(key) ? key : 0))
        this.__applyCallbackAndAttributes(control, parsedOptions.callbacks, parsedOptions.attributes)

        return control
    }


    /**
     * Add StatusBar control to Gui
     * @param {String} options Options/Directives apply to the control.
     * @param {String} startingText Initial text.
     * @returns {Gui.StatusBar} 
     */
    AddStatusBar(options := "", startingText := "") {
        parsedOptions := this.__parseOptions(options)

        control := this.gui.AddStatusBar(parsedOptions.parsed, startingText)
        this.__applyCallbackAndAttributes(control, parsedOptions.callbacks, parsedOptions.attributes)

        return control
    }


    /**
     * Add Tab3 control to Gui
     * @param {String} options Options/Directives apply to the control.
     * @param {Array<String> | Map<String | Integer, ()=>void>>} pages Page titles or pages with components.
     * ```
     * tab3 := oGui.AddTab3("...", ["first-tab", "second-tab", ...])
     * 
     * oGui.AddTab3("...", Map(
     *     "first-tab",  () => SomeComonentFunc(),
     *     "second-tab", () => SomeComonentFunc2(),
     * ))
     * ```
     * @returns {Gui.Tab}
     */
    AddTab3(options := "", pages := []) {
        parsedOptions := this.__parseOptions(options)

        control := this.gui.AddTab3(parsedOptions.parsed, pages is Map ? MapExt.keys(pages) : pages)
        this.__applyCallbackAndAttributes(control, parsedOptions.callbacks, parsedOptions.attributes)

        if (pages is Map) {
            for pageTitle, pageFunc in pages {
                control.UseTab(pageTitle)
                pageFunc()
            }
            control.UseTab()
        }

        return control
    }


    /**
     * Add a Text control to Gui
     * @param {String} options Options/Directives apply to the control.
     * @param {String} content Text or formatted text to hold signal values.
     * @param {signal} [depend] Subscribed signal
     * @param {String | Array | Object} [key] the keys or index of the signal's value
     * @returns {SvanerText | Gui.Text} 
     */
    AddText(options, content := "", depend?, key?) {
        parsedOptions := this.__parseOptions(options)

        control := IsSet(depend)
            ? SvanerText(this.gui, parsedOptions.parsed, content, (IsSet(depend) ? depend : 0), (IsSet(key) ? key : 0))
            : this.gui.AddText(parsedOptions.parsed, content)

        this.__applyCallbackAndAttributes(control, parsedOptions.callbacks, parsedOptions.attributes)

        return control
    }


    /**
     * Add a TreeView/SvanerTreeView control to Gui
     * @param {String} options Options/Directives apply to the control.
     * @param {signal} [depend] Subscribed signal
     * @param {String | Array | Object} [key] the keys or index of the signal's value
     * @returns {SvanerTreeView | Gui.TreeView} 
     */
    AddTreeView(options, depend?, key?) {
        parsedOptions := this.__parseOptions(options)

        control := IsSet(depend)
            ? SvanerTreeView(this.gui, options, (IsSet(depend) ? depend : 0), (IsSet(key) ? key : 0))
            : this.gui.AddTreeView(options)
        this.__applyCallbackAndAttributes(control, parsedOptions.callbacks, parsedOptions.attributes)

        return control
    }


    /**
     * 
     * @param {String} options Options/Directives apply to the control.
     * @param {Integer} startingPos 
     * @returns {Gui.UpDown} 
     */
    AddUpDown(options, startingPos := 0) {
        parsedOptions := this.__parseOptions(options)

        control := this.gui.AddUpDown(options, startingPos)
        this.__applyCallbackAndAttributes(control, parsedOptions.callbacks, parsedOptions.attributes)

        return control
    }


    ; Svaner Controls
    class Control {
        /**
         * Creates a new reactive control and add it to the window.
         * @param {Gui} GuiObject The target Gui Object.
         * @param {string} controlType Control type to create. Available: Text, Edit, CheckBox, Radio, DropDownList, ComboBox, ListView.
         * @param {string} options Options apply to the control, same as Gui.Add.
         * @param {string|Array|Object} content Text or formatted text for text, options for DDL/ComboBox, column option object for ListView.
         * @param {signal|Array|Object} depend Subscribed signal, or an array of signals. 
         * @param {string|number} key A key or index as render indicator.
         * @returns {Svaner} 
         */
        __New(GuiObject, controlType, options := "", content := "", depend := 0, key := 0) {
            this.GuiObject := GuiObject
            this.ctrlType := controlType
            this.options := options ? this._handleOptionsFormatting(options) : ""
            this.content := content ? content : ""
            this.selectStatusDepend := ""
            this.checkStatusDepend := ""
            this.depend := depend ? this._filterDepends(depend) : 0
            this.key := key

            ; textString handling
            if (controlType == "ComboBox" || controlType == "DropDownList") {
                if (this.depend.value is Array) {
                    this.optionTexts := this.depend.value
                } else if (this.depend.value is Map) {
                    this.optionTexts := MapExt.keys(this.depend.value)
                    this.optionsValues := MapExt.values(this.depend.value)
                }
            }
            else if (controlType == "ListView") {
                this.isFocusOnUpdate := false
                this.titleKeys := this.content.keys
                this.formattedContent := this.content.HasOwnProp("titles")
                    ? this.content.titles
                    : ArrayExt.map(this.titleKeys, key => (key is Array) ? key[key.Length] : key)
                this.colWidths := this.content.HasOwnProp("widths") ? this.content.widths : ArrayExt.map(this.titleKeys, item => "AutoHdr")
            }
            else {
                this.formattedContent := RegExMatch(this.content, "\{\d+\}") ? this._handleFormatStr(this.content, this.depend, this.key) : this.content
            }

            ; mount control
            switch {
                case controlType == "ListView":
                    this.lvOptions := this.options.lvOptions
                    this.itemOptions := this.options.HasOwnProp("itemOptions") ? this.options.itemOptions : ""
                    this.checkedRows := []

                    this.ctrl := this.GuiObject.Add(this.ctrlType, this.lvOptions, this.formattedContent)
                    for width in this.colWidths {
                        this.ctrl.ModifyCol(A_Index, width)
                    }
                    this._handleListViewUpdate()
                case controlType == "TreeView":
                    this.tvOptions := this.options.tvOptions
                    this.itemOptions := this.options.HasOwnProp("itemOptions") ? this.options.itemOptions : ""

                    this.ctrl := this.GuiObject.AddTreeView(this.tvOptions)
                    this.shadowTree := SvanerTreeView.ShadowTree(this.ctrl)
                    this._handleTreeViewUpdate()
                case controlType == "CheckBox":
                    this.ctrl := this.GuiObject.Add(this.ctrlType, this.options, this.formattedContent)

                    if (this.checkStatusDepend) {
                        this.ctrl.value := this.checkStatusDepend.value
                    }
                case (controlType == "ComboBox" || controlType == "DropDownList" || controlType == "ListBox"):
                    if (this.depend.value is Array) {
                        this.optionTexts := this.depend.value
                    } else if (this.depend.value is Map) {
                        this.optionTexts := MapExt.keys(this.depend.value)
                        this.optionsValues := MapExt.values(this.depend.value)
                    }

                    this.ctrl := this.GuiObject.Add(this.ctrlType, this.options, this.optionTexts)
                case controlType == "MonthCal":
                    this.ctrl := this.GuiObject.Add(this.ctrlType, this.options, this.depend.value)
                case controlType == "DateTime":
                    this.ctrl := this.GuiObject.Add(this.ctrlType, this.options, this.content)
                    this.update(this.depend)
                case controlType == "Slider":
                    if (this.key is Func) {
                        f := this.key
                        this.ctrl := this.GuiObject.Add(this.ctrlType, this.options, f(this.depend.value))
                    }
                    else {
                        this.ctrl := this.GuiObject.Add(this.ctrlType, this.options, this._traverse_get(this.key, this.depend.value))
                    }
                default:
                    this.ctrl := this.GuiObject.Add(this.ctrlType, this.options, this.formattedContent)
            }

            this.ctrl.svanerWrapper := this

            ; add subscribe
            if (!this.depend) {
                return
            }
            else if (this.depend is Array) {
                for dep in this.depend {
                    dep.addSub(this)
                }
            }
            else {
                this.depend.addSub(this)
            }
        }

        /**
         * Reformat options string to assign proper options for each control type.
         * @param {String} options 
         * @returns {String} formatted options string.
         */
        _handleOptionsFormatting(options) {
            if (this.ctrlType == "ListView") {
                optionsString := options.lvOptions
            }
            else if (this.ctrlType == "TreeView") {
                optionsString := options.tvOptions
            }
            else {
                optionsString := options
            }

            optionsArr := StrSplit(optionsString, " ")
            arcNameIndex := ArrayExt.findIndex(optionsArr, item => InStr(item, "$"))

            if (arcNameIndex) {
                this.name := optionsArr.RemoveAt(arcNameIndex)
                this.GuiObject.scs[this.name] := this
            }

            formattedOptions := ""
            for option in optionsArr {
                formattedOptions .= option . " "
            }

            if (this.ctrlType == "ListView") {
                options.lvOptions := formattedOptions
                return options
            }
            else if (this.ctrlType == "TreeView") {
                options.tvOptions := formattedOptions
                return options
            }

            return formattedOptions
        }

        /**
         * Filters checkValue for checks status binding with shared signal for ListView and CheckBox.
         * @param {signal|Object|Array} depend 
         */
        _filterDepends(depend) {
            if (depend.base == Object.Prototype) {
                this.checkStatusDepend := depend.check
                this.checkStatusDepend.addSub(this)

                return depend.HasOwnProp("text") ? depend.text : 0
            }
            else {
                return depend
            }
        }

        /**
         * Updates text content of the control with latest signal value.
         * @param {String} formatStr Text content of the control in format string form.
         * @param {signal} depend depend signal.
         * @param {Number|Array} key A index for Array of key for an Object value of depend signal.
         */
        _handleFormatStr(formatStr, depend, key) {
            vals := []

            if (!key) {
                this._fmtStr_handleKeyless(depend, vals)
            }
            else if (key is Number) {
                this._fmtStr_handleKeyNumber(depend, key, vals)
            }
            else if (key is Func) {
                this._fmtStr_handleKeyFunc(depend, key, vals)
            }
            else {
                this._fmtStr_handleKeyObject(depend, key, vals)
            }

            return Format(formatStr, vals*)
        }
        _fmtStr_handleKeyless(depend, vals) {
            if (!depend) {
                return
            }

            if (depend is Array) {
                for dep in depend {
                    vals.Push(dep.value)
                }
            }
            else if (depend.value is Array) {
                vals := depend.value
            }
            else {
                vals.Push(depend.value)
            }
        }
        _fmtStr_handleKeyNumber(depend, key, vals) {
            for item in depend.value {
                vals.Push(depend.value[key])
            }
        }
        _fmtStr_handleKeyFunc(depend, key, vals) {
            vals.Push(key(depend.value))
        }
        _fmtStr_handleKeyObject(depend, key, vals) {
            if (key.base == Object.Prototype) {
                index := key.HasOwnProp("index") ? key.index : A_Index

                for k in key.keys {
                    val := ""
                    switch {
                        case (k is Func):
                            val := k(depend.value[index])
                        case (depend.value[index] is Map):
                            val := depend.value[index][k]
                        case (k is Array):
                            val := this._traverse_get(k, depend.value[index], 1)
                        default:
                            val := depend.value[index].%k%
                    }
                    vals.Push(val)
                }
            }
            else {
                for k in key {
                    vals.Push(k is Func ? k(depend.value) : (depend.value is Map ? depend.value[k] : depend.value.%k%))
                }
            }
        }
        _traverse_get(keys, target, index := 1) {
            if (!keys) {
                return target
            }

            if (index == keys.Length) {
                return target is Map ? target[keys[index]] : target.%keys[index]%
            }

            if (target is Map ? target.Has(keys[index]) : target.HasOwnProp(keys[index])) {
                return this._traverse_get(keys, target is Map ? target[keys[index]] : target.%keys[index]%, index + 1)
            }
        }
        _traverse_set(keys, target, newValue, index := 1) {
            if (index == keys.Length) {
                return target is Map ? target[keys[index]] := newValue : target.%keys[index]% := newValue
            }

            if (target is Map ? target.Has(keys[index]) : target.HasOwnProp(keys[index])) {
                return this._traverse_get(keys, target is Map ? target[keys[index]] : target.%keys[index]%, index + 1)
            }
        }

        /**
         * Updates ListView items with latest signal value.
         */
        _handleListViewUpdate() {
            this.ctrl.Delete()

            for item in this.depend.value {
                ; item -> Object || Map || OrderedMap
                if (item.base == Object.Prototype) {
                    itemIn := JSON.parse(JSON.stringify(item))
                }
                else if (item is Map) {
                    itemIn := item
                }

                rowData := ArrayExt.map(this.titleKeys, key => getRowData(key, itemIn))
                getRowData(key, itemIn, layer := 1) {
                    if (key is String) {
                        if (itemIn.base == Object.Prototype && itemIn.HasOwnProp(key)) {
                            return itemIn.%key%
                        }
                        else if (itemIn is Map && itemIn.Has(key)) {
                            return itemIn[key]
                        }
                        else {
                            return this._listview_getFirstMatch(key, itemIn)
                        }
                    }

                    if (key is Array) {
                        return this._listview_getExactMatch(key, itemIn, 1)
                    }
                }
                try {
                    this.ctrl.Add(this.itemOptions, rowData*)
                }
            }

            this.ctrl.Modify(1, "Select")
            if (this.isFocusOnUpdate) {
                this.ctrl.Focus()
            }
        }
        _listview_getExactMatch(keys, item, index) {
            if !(item is Map || item.base == Object.Prototype) {
                return item
            }

            itemToGet := item is Map ? item[keys[index]] : item.%keys[index]%

            return this._listview_getExactMatch(keys, itemToGet, index + 1)
        }
        _listview_getFirstMatch(key, item) {
            if (item is Map && item.Has(key)) {
                return item[key]
            }
            else if (item.base == Object.Prototype && item.HasOwnProp(key)) {
                return item.%key%
            }

            for k, v in item {
                if (v is Map || v.base == Object.Prototype) {
                    res := this._listview_getFirstMatch(key, v)
                    if (res) {
                        return res
                    }
                }
            }
        }

        /**
         * Updates TreeView items with latest signal value.
         */
        _handleTreeViewUpdate() {
            this.ctrl.Delete()
            this.shadowTree.copy(this.depend.value)

            itemId := 0
            loop {
                itemId := this.ctrl.GetNext(itemId, "Full")
                if (!itemId) {
                    break
                }

                this.ctrl.Modify(itemId, this.itemOptions)
            }

            this.ctrl.Modify(this.ctrl.GetNext(0, "Full"), "Select")
        }

        /**
         * Interface for signal too call and updating control contents.
         * @param {signal} signal The subscribed signal
         */
        update(signal) {
            if (this.ctrl is Gui.Edit) {
                ; update text value
                this.ctrl.Value := this._handleFormatStr(this.content, this.depend, this.key)
                return
            }
            else if (this.ctrl is Gui.Slider) {
                if (this.key is Func) {
                    f := this.key
                    this.ctrl.value := f(this.depend.value)
                }
                else {
                    this.ctrl.Value := this._traverse_get(this.key, this.depend.value) || 0
                }
                return
            }
            else if (this.ctrl is Gui.ListView) {
                ; update from checkStatusDepend
                if (this.checkStatusDepend) {
                    this.ctrl.Modify(0, this.checkStatusDepend.value == true ? "-Checked" : "+Checked")
                    return
                }
                ; update list items
                this._handleListViewUpdate()
                return
            }
            else if (this.ctrl is Gui.TreeView) {
                this._handleTreeViewUpdate()
                return
            }
            else if (this.ctrl is Gui.CheckBox) {
                ; update from checkStatusDepend
                if (this.checkStatusDepend) {
                    this.ctrl.Value := this.CheckStatusDepend.value
                }
                ; update text label
                this.ctrl.Text := this._handleFormatStr(this.content, this.depend, this.key)
                return
            }
            else if (this.ctrl is Gui.ComboBox || this.ctrl is Gui.DDL) {
                ; replace the list content
                this.ctrl.Delete()
                this.ctrl.Add(signal.value is Array ? signal.value : MapExt.keys(signal.value))
                this.ctrl.Choose(1)
                if (signal.value is Array) {
                    this.optionTexts := signal.value
                } else {
                    this.optionsTexts := MapExt.keys(signal.value)
                    this.optionsValues := MapExt.values(signal.value)
                }
                return
            }
            else if (this.ctrl is Gui.Pic) {
                try {
                    this.ctrl.Value := signal.value
                }
                return
            }
            else if (this.ctrl is Gui.DateTime || this.ctrl is Gui.MonthCal) {
                this.ctrl.Value := this._traverse_get(this.key, signal.value)
            }
            else {
                ; update text label
                this.ctrl.Text := this._handleFormatStr(this.content, this.depend, this.key)
            }

        }

        ; APIs
        /**
         * Sets a depend signal for Svaner Control.
         * @param {Signal} depend 
         */
        setDepend(depend) {
            this.depend := this._filterDepends(depend)
            this.update(this.depend)

            return this
        }

        setKey(newKey) {
            this.key := newKey
            this.update(this.depend)

            return this
        }

        bind(delay := 0) {
            try {
                if (this.depend.value is Primitive) {
                    this.onChange((ctrl, _) => this.depend.set(ctrl.value), delay)
                }
                else {
                    new := this.depend.value
                    this.onChange((ctrl, _) => (
                        this._traverse_set(this.key, new, ctrl.Value),
                        this.depend.set(new)
                    ), delay)
                }
            }
            catch {
                targetDepend := this is SvanerCheckBox ? this.checkStatusDepend : this.depend
                this.onClick((ctrl, _) => targetDepend.set(ctrl.value))
            }

            return this
        }


        /**
         * Registers one or more functions to be call when given event is raised. 
         * @param {<String, Func>} event key-value pairs of event-callback.
         * ```
         * ; single event
         * Svaner.Control.OnEvent("Click", (*) => (...))
         * 
         * ; multiple events
         * Svaner.Control.OnEvent(
         *   "Click", (*) => (...), 
         *   "DoubleClick", (*) => (...)
         * )
         * 
         * ```
         * @returns {Svaner.Control} 
         */
        OnEvent(event*) {
            loop event.Length {
                if (Mod(A_Index, 2) == 0) {
                    continue
                }

                this.ctrl.OnEvent(event[A_Index], event[A_Index + 1])
            }

            return this
        }

        /**
         * Registers a function to be call when "Change" event is raised.
         * @param eventCallback The callback function when event is raised.
         * @param [delay=1] Delay ms for debounce.
         * @param [addRemove=1] Registers a function or method to be called when the given event is raised.
         *                      -  1 = Call the callback after any previously registered callbacks.
         *                      - -1 = Call the callback before any previously registered callbacks.
         *                      -  0 = Do not call the callback.
         * @returns {Svaner.Control} 
         */
        onChange(eventCallback, delay := 0, addRemove := 1) {
            callbackToSet := ""
            if (delay) {
                inner() {
                    (this.ctrl is Gui.Edit && caretPos := GuiExt.editGetCaret(this.ctrl)[1])
                    eventCallback(this.ctrl, 0)
                    (this.ctrl is Gui.Edit && GuiExt.editSetCaret(this.ctrl, caretPos))
                }
                callbackToSet := delayedCallback(*) => SetTimer(inner, 0 - delay)
            } else {
                withParams(ctrl, info) {
                    (this.ctrl is Gui.Edit && caretPos := GuiExt.editGetCaret(this.ctrl)[1])
                    eventCallback(ctrl, info)
                    (this.ctrl is Gui.Edit && GuiExt.editSetCaret(this.ctrl, caretPos))
                }
                callbackToSet := withParams
            }

            this.ctrl.OnEvent("Change", callbackToSet, addRemove)

            return this
        }

        /**
         * Registers a function to be call when "Click" event is raised.
         * @param {Func} eventCallback The callback function when event is raised.
         * @param [addRemove=1] Registers a function or method to be called when the given event is raised.
         *                      -  1 = Call the callback after any previously registered callbacks.
         *                      - -1 = Call the callback before any previously registered callbacks.
         *                      -  0 = Do not call the callback.
         * @returns {Svaner.Control} 
         */
        onClick(eventCallback, addRemove := 1) {
            this.ctrl.OnEvent("Click", eventCallback, addRemove)

            return this
        }

        /**
         * Registers a function to be call when "DoubleClick" event is raised.
         * @param {Func} eventCallback The callback function when event is raised.
         * @param [addRemove=1] Registers a function or method to be called when the given event is raised.
         *                      -  1 = Call the callback after any previously registered callbacks.
         *                      - -1 = Call the callback before any previously registered callbacks.
         *                      -  0 = Do not call the callback.
         * @returns {Svaner.Control} 
         */
        onDoubleClick(eventCallback, addRemove := 1) {
            this.ctrl.OnEvent("DoubleClick", eventCallback, addRemove)

            return this
        }

        /**
         * Registers a function to be call when "ColClick" event is raised.
         * @param {Func} eventCallback The callback function when event is raised.
         * @param [addRemove=1] Registers a function or method to be called when the given event is raised.
         *                      -  1 = Call the callback after any previously registered callbacks.
         *                      - -1 = Call the callback before any previously registered callbacks.
         *                      -  0 = Do not call the callback.
         * @returns {Svaner.Control} 
         */
        onColClick(eventCallback, addRemove := 1) {
            this.ctrl.OnEvent("ColClick", eventCallback, addRemove)

            return this
        }

        /**
         * Registers a function to be call when "ContextMenu" event is raised.
         * @param {Func} eventCallback The callback function when event is raised.
         * @param [addRemove=1] Registers a function or method to be called when the given event is raised.
         *                      -  1 = Call the callback after any previously registered callbacks.
         *                      - -1 = Call the callback before any previously registered callbacks.
         *                      -  0 = Do not call the callback.
         * @returns {Svaner.Control} 
         */
        onContextMenu(eventCallback, addRemove := 1) {
            this.ctrl.OnEvent("ContextMenu", eventCallback, addRemove)

            return this
        }

        /**
         * Registers a function to be call when "Focus" event is raised.
         * @param {Func} eventCallback The callback function when event is raised.
         * @param [addRemove=1] Registers a function or method to be called when the given event is raised.
         *                      -  1 = Call the callback after any previously registered callbacks.
         *                      - -1 = Call the callback before any previously registered callbacks.
         *                      -  0 = Do not call the callback.
         * @returns {Svaner.Control} 
         */
        onFocus(eventCallback, addRemove := 1) {
            this.ctrl.OnEvent("Focus", eventCallback, addRemove)

            return this
        }

        /**
         * Registers a function to be call when "LoseFocus" event is raised.
         * @param {Func} eventCallback The callback function when event is raised.
         * @param [addRemove=1] Registers a function or method to be called when the given event is raised.
         *                      -  1 = Call the callback after any previously registered callbacks.
         *                      - -1 = Call the callback before any previously registered callbacks.
         *                      -  0 = Do not call the callback.
         * @returns {Svaner.Control} 
         */
        onBlur(eventCallback, addRemove := 1) {
            this.ctrl.OnEvent("LoseFocus", eventCallback, addRemove)

            return this
        }

        /**
         * Registers a function to be call when "ItemCheck" event is raised.
         * @param {Func} eventCallback The callback function when event is raised.
         * @param [addRemove=1] Registers a function or method to be called when the given event is raised.
         *                      -  1 = Call the callback after any previously registered callbacks.
         *                      - -1 = Call the callback before any previously registered callbacks.
         *                      -  0 = Do not call the callback.
         * @returns {Svaner.Control} 
         */
        onItemCheck(eventCallback, addRemove := 1) {
            this.ctrl.OnEvent("ItemCheck", eventCallback, addRemove)

            return this
        }

        /**
         * Registers a function to be call when "ItemEdit" event is raised.
         * @param {Func} eventCallback The callback function when event is raised.
         * @param [addRemove=1] Registers a function or method to be called when the given event is raised.
         *                      -  1 = Call the callback after any previously registered callbacks.
         *                      - -1 = Call the callback before any previously registered callbacks.
         *                      -  0 = Do not call the callback.
         * @returns {Svaner.Control} 
         */
        onItemEdit(eventCallback, addRemove := 1) {
            this.ctrl.OnEvent("ItemEdit", eventCallback, addRemove)

            return this
        }

        /**
         * Registers a function to be call when "ItemExpand" event is raised.
         * @param {Func} eventCallback The callback function when event is raised.
         * @param [addRemove=1] Registers a function or method to be called when the given event is raised.
         *                      -  1 = Call the callback after any previously registered callbacks.
         *                      - -1 = Call the callback before any previously registered callbacks.
         *                      -  0 = Do not call the callback.
         * @returns {Svaner.Control} 
         */
        onItemExpand(eventCallback, addRemove := 1) {
            this.ctrl.OnEvent("ItemExpand", eventCallback, addRemove)

            return this
        }

        /**
         * Registers a function to be call when "ItemFocus" event is raised.
         * @param {Func} eventCallback The callback function when event is raised.
         * @param [addRemove=1] Registers a function or method to be called when the given event is raised.
         *                      -  1 = Call the callback after any previously registered callbacks.
         *                      - -1 = Call the callback before any previously registered callbacks.
         *                      -  0 = Do not call the callback.
         * @returns {Svaner.Control} 
         */
        onItemFocus(eventCallback, addRemove := 1) {
            this.ctrl.OnEvent("ItemFocus", eventCallback, addRemove)

            return this
        }

        /**
         * Registers a function to be call when "ItemSelect" event is raised.
         * @param {Func} eventCallback The callback function when event is raised.
         * @param [addRemove=1] Registers a function or method to be called when the given event is raised.
         *                      -  1 = Call the callback after any previously registered callbacks.
         *                      - -1 = Call the callback before any previously registered callbacks.
         *                      -  0 = Do not call the callback.
         * @returns {Svaner.Control} 
         */
        onItemSelect(eventCallback, addRemove := 1) {
            this.ctrl.OnEvent("ItemSelect", eventCallback, addRemove)

            return this
        }


        /**
         * Sets various options and styles for the appearance and behavior of the control.
         * @param newOptions Specify one or more control-specific or general options and styles, each separated from the next with one or more spaces or tabs.
         */
        Opt(newOptions) {
            this.ctrl.Opt(newOptions)
            return this
        }

        /**
         * Sets the font typeface, size, style, and/or color for controls added to the window from this point onward.
         * ```
         * SvanerText("...", "Text").SetFont("cRed s12", "Arial")
         * ```
         * @param {String} options Font options. C: color, S: size, W: weight, Q: quality
         * @param {String} fontName Name of font to set. 
         */
        SetFont(options := "", fontName := "") {
            this.ctrl.SetFont(options, fontName)
            return this
        }

        /**
         * Sets the font reactively with depend signal and option map.
         * ```
         * color := signal("red")
         * options := Map(
         *  "red", "cRed"
         *  "blue", "cBlue"
         *  "green", "cGreen"
         * )
         * 
         * SvanerText("...", "Text").SetFontStyles(options, color)
         * ; or
         * SvanerText("...", "{1}", color).SetFontStyles(options)
         * ```
         * @param {Map} optionMap A Map with depend signal value as keys, font options as values
         * @param {Signal} [depend] Signal dependency. If omitted, it will use the Svaner.Control.depend instead.
         */
        SetFontStyles(optionMap, depend := this.depend) {
            ; checkType(optionMap, Map)
            ; checkType(depend, signal)

            effect(depend, cur => this.ctrl.SetFont(optionMap.has(cur) ? optionMap[cur] : optionMap["default"]))
            return this
        }

        /**
         * Sets keyboard focus to the control.
         */
        Focus() {
            this.ctrl.Focus()
            return this
        }
    }
}