; An AddReactive component that allows you to render componeny dynamically based on signal and Map.
class Dynamic {
    /**
     * Render stateful component dynamically base on signal.
     * @param {Svaner} svanerInstance The Svaner instance to which the Dynamic belongs
     * ```
     * Dynamic(SvanerApp, color, colorEntries, props)
     * ```
     * @param {signal} depend Depend signal.
     * ```
     * color := signal("Red")
     * ```
     * @param {Map<Any, Func | Class>} componentEntries A Map with option values and associated components functions or classes.
     * ```
     * Red(SvanerApp, props) {
     *     r := Component(SvanerApp, A_ThisFuc)
     *     return r
     * }
     * 
     * colorEntries := Map("Red", Red, "Blue", Blue)
     * ```
     * @param {Object} [props] Additional props for components.
     * ```
     * props := { style: "w200 h30" }
     * ```
     * @param {VarRef} [instances] Component instances called by Dynamic.
     */
    __New(svanerInstance, depend, componentEntries, props?, &instances?) {
        TypeChecker.checkType(svanerInstance, Svaner, "Parameter is not a Gui object or Svaner")
        TypeChecker.checkType(depend, signal, "Parameter is not a signal")
        TypeChecker.checkType(componentEntries, Map, "Parameter is not a Map")
        (IsSet(props) && TypeChecker.checkType(props, Object.Prototype, "Parameter is not an Object"))

        this.svaner := svanerInstance
        this.signal := depend
        this.componentEntries := componentEntries
        this.props := IsSet(props) ? props : {}
        this.instanceMap := Map()
        
        ; mount components
        for val, component in componentEntries {
            instance := component(this.svaner, this.props)

            ; add/combine props
            instance.defineProps(this.props)
            this.instanceMap[val] := instance

            instance.render()
            this._handleNestedComponentRender(instance.childComponents)
        }

        ; show components conditionally
        this._renderDynamic(this.signal.value)
        effect(this.signal, cur => this._renderDynamic(cur))

        ; pass component instances reference
        instances := this.instanceMap
    }

    _renderDynamic(currentValue) {
        for val, instance in this.instanceMap {
            instance.visible(false)
        }

        this.instanceMap[currentValue].visible(true)
    }

    _handleNestedComponentRender(childComponents){
        if (!childComponents.Length) {
            return
        }

        for childComponent in childComponents {
            childComponent.render()
            if (childComponent.childComponents.Length > 0) {
                this._handleNestedComponentRender(childComponent.childComponents)
            }
        }
    }
}