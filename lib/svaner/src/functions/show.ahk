class Show {
    /**
     * Creates a block of controls which displays conditionally
     * @param {()=>Gui.Control | ()=>Svaner.Control | ()=>Array<Gui.Control|Svaner.Control>} renderCallBack 
     * @param {signal} depend 
     * @param {(signal.value)=>(true | false)} conditionFn 
     */
    __New(renderCallBack, depend, conditionFn) {
        this.renderCallBack := renderCallBack
        this.depend := depend
        this.conditionFn := conditionFn
        this.ctrls := []

        effect(this.depend, cur => this.toggleShowHide(conditionFn(cur)))

        ; mount & save controls
        ctrls := renderCallBack()
        this.saveCtrls(this.ctrls, ctrls is Array ? ctrls : [ctrls])
        this.toggleShowHide(conditionFn(this.depend.value))
    }

    saveCtrls(savedCtrls, renderedCtrls) {
        for control in renderedCtrls {
            ; native control 
            if (control is Gui.Control) {
                savedCtrls.Push(control)
            }

            ; svaner control
            if (control is Svaner.Control) {
                savedCtrls.Push(control.ctrl)
            }

            ; Array
            if (control is Array) {
                this.saveCtrls(savedCtrls, control)
            }

            ; IndexList
            if (control is IndexList) {
                for listControl in control.ctrlGroups {
                    this.saveCtrls(savedCtrls, listControl)
                }
            }

            ; nested component
            if (control is Component) {
                this.ctrls.Push(control.ctrls*)
                if (control.childComponents.Length > 0) {
                    this.saveCtrls(savedCtrls, control.childComponents)
                }
            }

            ; stackbox
            if (control is StackBox) {
                this.saveCtrls(savedCtrls, control.ctrls)
            }
        }
    }

    toggleShowHide(condition) {
        for ctrl in this.ctrls {
            ctrl.Visible := condition
        }
    }
}