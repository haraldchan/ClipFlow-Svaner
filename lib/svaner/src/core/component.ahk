class Component {
    /**
     * Create a component instance.
     * ```
     * comp := Component(svanerObj, "componentName")
     * 
     * Comp(svanerObj) {
     *   c := Component(svanerObj, A_ThisFunc)
     *   ; ...
     *   return c
     * }
     * ```
     * @param {Svaner} svanerObj
     * @param {String} name The unique name of the component
     * @param {Object} props 
     */
    __New(svanerObj, name, props := {}) {
        TypeChecker.checkType(name, String, "Parameter #1 is not a string")
        this.svaner := svanerObj
        this.name := name
        this.props := props
        this.ctrls := []
        this.children := () => {}
        this.childComponents := []
        this.isDisabled := false
        this.isVisible := true

        this.defineChildren(props)
        this.svaner.components[this.name] := this
    }

    /**
     * Specify native or AddReactive controls to in component
     * @param {...Gui.Control|...Svaner.Control} controls 
     * @returns {Component}
     */
    Add(controls*) {
        ctrls := []
        this._saveControls(ctrls, controls)
        this.ctrls.Push(ctrls*)

        return this
    }

    _saveControls(ctrlsArray, controls) {
        for control in controls {
            ; native control
            if (control is Gui.Control) {
                control.groupName := "$$" . this.name
                ctrlsArray.Push(control)
            }

            ; svaner control
            if (Control is Svaner.Control) {
                control.ctrl.groupName := "$$" . this.name
                ctrlsArray.Push(control.ctrl)
            }

            ; Array
            if (control is Array) {
                this._saveControls(ctrlsArray, control)
            }

            ; IndexList
            if (control is IndexList) {
                for listControl in control.ctrlGroups {
                    this._saveControls(ctrlsArray, listControl)
                }
            }

            ; nested component
            if (control is Component) {
                this.childComponents.Push(control)
            }

            ; StackBox
            if (control is StackBox) {
                this._saveControls(ctrlsArray, control.ctrls)
            }
        }
    }

    /**
     * Define additional props
     * @param {Object} props props Object
     */
    defineProps(props) {
        TypeChecker.checkType(props, Object.Prototype)
        for key, val in props.OwnProps() {
            this.props.DefineProp(key, { value: val })
        }
        
    }

    defineChildren(props) {
        if (props.HasOwnProp("children")) {
            TypeChecker.checkType(props.children, Func)
            this.children := props.children
        }
    }

    /**
     * Sets the visibility state of the component.
     * @param {Integer|Func} isShow a true/false value or a computation function to change visibility of the component.
     */
    visible(isShow) {
        this.isVisible := isShow is Func ? isShow(this.isVisible) : isShow

        for ctrl in this.ctrls {
            ctrl.visible := this.isVisible
        }

        this._handleChildComponentVisible(this.isVisible, this.childComponents)
    }

    _handleChildComponentVisible(state, childComponents) {
        if (!childComponents.Length) {
            return
        }

        for component in childComponents {
            component.visible(state)
            if (component.childComponents.Length > 0) {
                this._handleChildComponentVisible(state, component.childComponents)
            }
        }
    }

    /**
     * Collects the values from named controls of the component and composes them into an Object.
    /**
     * 
     * @param {true | false} hide 
     * @param {true | false} asMap 
     * @param {true | false} kebabToCamel 
     * @returns {Object | Map} 
     */
    submit(hide := false, asMap := false, kebabToCamel := true) {
        if (hide) {
            this.svaner.gui.hide()
        }

        formData := {}
        for ctrl in this.ctrls {
            if (ctrl.name) {
                if (kebabToCamel) {
                    keyName := pipe(
                        n => StrSplit(n, "-"),
                        n => ArrayExt.map(n, item => A_Index == 1 ? item : StrTitle(item)),
                        n => ArrayExt.join(n, "")
                    )(ctrl.name)
                }
                else {
                    keyName := ctrl.name
                }
                
                asMap ? formData[keyName] := ctrl.Value : formData.DefineProp(keyName, { Value: ctrl.Value }) 
            }
        }

        this._handleChildComponentSubmit(formData, this.childComponents)

        return formData
    }

    _handleChildComponentSubmit(dataObj, childComponents) {
        if (childComponents.Length == 0) {
            return
        }

        for component in childComponents {
            componentFormData := component.submit()
            if (component.childComponents.Length > 0) {
                this._handleChildComponentSubmit(componentFormData, component.childComponents)
            }
            dataObj.DefineProp(component.name, { Value: componentFormData })
        }
    }

    /**
     * Sets the enabled state of the component.
     * @param {Integer|Func} disabled a true/false value or a computation function to change enabled of the component.
     */
    disable(disabled) {
        this.isDisabled := disabled is Func ? disabled(this.isDisabled) : disabled

        for ctrl in this.ctrls {
            ctrl.Enabled := !this.isDisabled
        }

        this._handleChildComponentDisable(this.isDisabled, this.childComponents)
    }

    _handleChildComponentDisable(state, childComponents) {
        if (!childComponents.Length) {
            return
        }

        for component in childComponents {
            component.disable(state)
            if (component.childComponents.Length > 0) {
                this._handleChildComponentDisable(state, component.childComponents)
            }
        }
    }
}
