class useProps {
    /**
     * Define optional props with an object for default values. (Or with StructInstance for type checking).
     * ```
     * StaffCard({ name: "Jenny", age: 22 })
     * 
     * StaffCard(props){
     *   ; define default values
     *   info := useProps(props, {
     *     name: "John Doe",
     *     age:  35,
     *     tel:  88372153
     *   })
     * }
     * ```
     * @param {Object | Map} props Props object received in a component.
     * ```
     * jenny := { name: "Jenny", age: 22 }
     * ```
     * @param {Object | Struct} propsDefaults Default values.
     * ```
     * StaffCard(props){
     *   staff := {
     *     name: "John Doe",
     *     age:  35,
     *     tel:  88372153
     *   }
     * 
     *   ; use Struct for more confined props defining
     *   staff := Struct({
     *     name: String,
     *     age:  Integer,
     *     tel:  Integer
     *   })
     * 
     *   info := useProps(props, staff)
     * }
     * ```
     * @return {Object}
     */
    __New(props, propsDefaults) {
        TypeChecker.checkType(props, [Object.Prototype, Map])
        TypeChecker.checkType(propsDefaults, [Object.Prototype, Map, Struct])

        this.props := props
        this.propsDefaults := propsDefaults

        if (propsDefaults is Struct) {
            matchTest := propsDefaults.new(props)
            matchTest := ""
        }

        this._addProps(this)
    }
    
    _defineEnum() {
        if (TypeChecker.isPlainObject(this.propsDefaults)) {
            enum := this.propsDefaults.OwnProps()
        } else if (this.propsDefaults is Map) {
            enum := this.propsDefaults
        } else if (this.propsDefaults is Struct) {
            enum := TypeChecker.isPlainObject(this.props) 
                ? this.props.OwnProps()
                : this.props            
        }

        return enum
    }

    _addProps(obj) {
        for name, value in this._defineEnum() {
            valueToDefine := TypeChecker.isPlainObject(this.props)
                ? (this.props.HasOwnProp(name) ? this.props.%name% : value)
                : (this.props.Has(name) ? this.props[name] : value)
        
            obj.DefineProp(name, { Value: valueToDefine })
        }
    }

    toObject() {
        obj := {}

        for key, val in this._defineEnum() {
            obj.defineProp(key, { Value: this.%key% })
        }

        return obj  
    }
}