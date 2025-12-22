class SvanerButton extends Svaner.Control {
    /**
     * Add a reactive Button control to Gui
     * @param {Gui} GuiObject The target Gui Object.
     * @param {string} options Options apply to the control, same as Gui.Add.
     * @param {string} content Text or formatted text to hold signal values.
     * @param {signal} [depend] Subscribed signal
     * @param {array} [key] the keys or index of the signal's value
     * @returns {SvanerButton}     
     */
    __New(GuiObject, options := "", content := "", depend := 0, key := 0) {
        TypeChecker.checkType(options, String, "Parameter #1 (options) is not a String")
        TypeChecker.checkType(content, [String, Number], "Parameter #2 (content) is not a String")
        TypeChecker.checkTypeDepend(depend)

        this.key := key
        super.__New(GuiObject, "Button", options, content, depend, key)
    }
}


class SvanerCheckBox extends Svaner.Control {
    /**
     * Add a reactive CheckBox control to Gui
     * @param {Gui} GuiObject The target Gui Object.
     * @param {string} options Options apply to the control, same as Gui.Add.
     * @param {string} content Text or formatted text to hold signal values.
     * @param {signal} [depend] Subscribed signal
     * @param {array} [key] the keys or index of the signal's value
     * @returns {SvanerCheckBox}     
     */
    __New(GuiObject, options := "", content := "", depend := 0, key := 0) {
        TypeChecker.checkType(options, String, "Parameter #1 (options) is not a String")
        TypeChecker.checkType(content, [String, Number], "Parameter #2 (content) is not a String")
        TypeChecker.checkTypeDepend(depend)

        this.key := key
        super.__New(GuiObject, "CheckBox", options, content, depend, key)
    }
}


class SvanerComboBox extends Svaner.Control {
    __New(GuiObject, options, depend := 0, key := 0) {
        TypeChecker.checkType(options, String, "Parameter #1 (options) is not a String")
        TypeChecker.checkTypeDepend(depend)

        this.key := key
        super.__New(GuiObject, "ComboBox", options, , depend, key)
    }
}


class SvanerDateTime extends Svaner.Control {
    /**
     * Add a reactive GroupBox control to Gui
     * @param {Gui} GuiObject The target Gui Object.
     * @param {string} options Options apply to the control, same as Gui.Add.
     * @param {string} content Text or formatted text to hold signal values.
     * @param {signal} [depend] Subscribed signal
     * @param {array} [key] the keys or index of the signal's value
     * @returns {SvanerDateTime}     
     */
    __New(GuiObject, options := "", dateFormat := "", depend := 0, key := 0) {
        TypeChecker.checkType(options, String, "Parameter #1 (options) is not a String")
        ; TypeChecker.checkType(dateFormat, IsTime, "Parameter #2 (content) is not a String")
        TypeChecker.checkTypeDepend(depend)

        this.key := key
        super.__New(GuiObject, "DateTime", options, dateFormat, depend)
    }
}


class SvanerDropDownList extends Svaner.Control {
    __New(GuiObject, options, depend := 0, key := 0) {
        TypeChecker.checkType(options, String, "Parameter #1 (options) is not a String")
        TypeChecker.checkTypeDepend(depend)
        this.key := key

        super.__New(GuiObject, "DropDownList", options, , depend, key)
    }
}


class SvanerEdit extends Svaner.Control {
    /**
     * Add a reactive Edit control to Gui
     * @param {Gui} GuiObject The target Gui Object.
     * @param {string} options Options apply to the control, same as Gui.Add.
     * @param {string} content Text or formatted text to hold signal values.
     * @param {signal} [depend] Subscribed signal.
     * @param {array} [key] the keys or index of the signal's value.
     * @returns {SvanerEdit}     
     */
    __New(GuiObject, options := "", content := "", depend := 0, key := 0) {
        TypeChecker.checkType(options, String, "Parameter #1 (options) is not a String")
        TypeChecker.checkType(content, [String, Number], "Parameter #2 (content) is not a String")
        TypeChecker.checkTypeDepend(depend)

        this.key := key
        super.__New(GuiObject, "Edit", options, content, depend, key)
    }
}


class SvanerGroupBox extends Svaner.Control {
    /**
     * Add a reactive GroupBox control to Gui
     * @param {Gui} GuiObject The target Gui Object.
     * @param {string} options Options apply to the control, same as Gui.Add.
     * @param {string} content Text or formatted text to hold signal values.
     * @param {signal} [depend] Subscribed signal
     * @param {array} [key] the keys or index of the signal's value
     * @returns {SvanerGroupBox}     
     */
    __New(GuiObject, options := "", content := "", depend := 0, key := 0) {
        TypeChecker.checkType(options, String, "Parameter #1 (options) is not a String")
        TypeChecker.checkType(content, String, "Parameter #2 (content) is not a String")
        TypeChecker.checkTypeDepend(depend)

        this.key := key
        super.__New(GuiObject, "GroupBox", options, content, depend, key)
    }
}


class SvanerListView extends Svaner.Control {
    /**
     * Add a reactive ListView control to Gui
     * @param {Gui} GuiObject The target Gui Object.
     * @param {string} options Options apply to the control, same as Gui.Add.
     * @param { {keys: string[], titles: string[], width: number[]} } columnDetails Descriptor object contains keys of col value, column title texts and column width.
     * @param {signal} depend Subscribed signal
     * @param {array} [key] the keys or index of the signal's value
     * @returns {SvanerListView}     
     */
    __New(GuiObject, options, columnDetails, depend := 0, key := 0) {
        ; options type checking
        TypeChecker.checkType(options, Object.Prototype, "Parameter #1 (options) is not an Object")
        TypeChecker.checkType(options.lvOptions, String, "options.lvOptions is not a string")
        if (options.HasOwnProp("itemOptions")) {
            TypeChecker.checkType(options.itemOptions, String, "options.itemOptions is not a string")
        }
        ; colTitleGrid type checking
        TypeChecker.checkType(columnDetails, Object.Prototype, "Parameter #2 is (columnDetails) is not an Object")
        TypeChecker.checkType(columnDetails.keys, Array, "columnDetails.keys is not an Array")
        if (columnDetails.HasOwnProp("titles")) {
            TypeChecker.checkType(columnDetails.titles, Array, "columnDetails.titles is not an Array")
        }
        if (columnDetails.HasOwnProp("widths")) {
            TypeChecker.checkType(columnDetails.widths, Array, "columnDetails.widths is not an Array")
        }
        ; depend type checking
        TypeChecker.checkTypeDepend(depend)
        TypeChecker.checkType(depend.value, Array, "Depend value of AddReactive ListView is not an Array")

        this.key := key
        super.__New(GuiObject, "ListView", options, columnDetails, depend, key)
    }

    /**
     * Applies new options to columns
     * @param {Object} newColumnDetails 
     * @param {String} columnOptions 
     */
    setColumndDetails(newColumnDetails, columnOptions := "") {
        colDiff := newColumnDetails.keys.Length - this.titleKeys.Length
        if (colDiff > 0) {
            loop colDiff {
                this.ctrl.InsertCol()
            }
        } else if (colDiff < 0) {
            loop Abs(colDiff) {
                this.ctrl.DeleteCol(this.titleKeys.Length - A_Index)
            }
        }

        this.titleKeys := newColumnDetails.keys
        this.content := newColumnDetails.HasOwnProp("titles") ? newColumnDetails.titles : this.titleKeys
        this.colWidths := newColumnDetails.HasOwnProp("widths") ? newColumnDetails.widths : this.titleKeys.map(item => "AutoHdr")

        for title in this.content {
            this.ctrl.ModifyCol(A_Index, this.colWidths[A_Index], title)
        }
    }
}


class SvanerMonthCal extends Svaner.Control {
    __New(GuiObject, options := "", depend := 0) {
        TypeChecker.checkType(options, String, "Parameter #1 (options) is not a String")
        TypeChecker.checkType(depend, signal, "Parameter #2 (depend) is not a signal")

        super.__New(GuiObject, "MonthCal", options,, depend)
    }
}


class SvanerPicture extends Svaner.Control {
    /**
     * Add a reactive Text control to Gui
     * @param {Gui} GuiObject The target Gui Object.
     * @param {string} options Options apply to the control, same as Gui.Add.
     * @param {string} content Text or formatted text to hold signal values.
     * @param {signal} [depend] Subscribed signal
     * @param {array} [key] the keys or index of the signal's value
     * @returns {SvanerPicture}     
     */
    __New(GuiObject, options := "", depend := 0, key := 0) {
        TypeChecker.checkType(options, String, "Parameter #1 (options) is not a String")
        TypeChecker.checkTypeDepend(depend)

        this.key := key
        super.__New(GuiObject, "Picture", options, depend.value, depend, key)
    }
}


class SvanerRadio extends Svaner.Control {
    /**
     * Add a reactive Radio control to Gui
     * @param {Gui} GuiObject The target Gui Object.
     * @param {string} options Options apply to the control, same as Gui.Add.
     * @param {string} content Text or formatted text to hold signal values.
     * @param {signal} [depend] Subscribed signal
     * @param {array} [key] the keys or index of the signal's value
     * @returns {SvanerRadio}     
     */
    __New(GuiObject, options := "", content := "", depend := 0, key := 0) {
        TypeChecker.checkType(options, String, "Parameter #1 (options) is not a String")
        TypeChecker.checkType(content, [String, Number], "Parameter #2 (content) is not a String")
        TypeChecker.checkTypeDepend(depend)

        this.key := key
        super.__New(GuiObject, "Radio", options, content, depend, key)
    }
}


class SvanerSlider extends Svaner.Control {
    /**
     * Add a reactive Slider control to Gui
     * @param GuiObject The target Gui Object.
     * @param {String} options Options apply to the control, same as Gui.Add.
     * @param {signal} [depend] Subscribed signal.
     */
    __New(GuiObject, options := "", depend := 0) {
        TypeChecker.checkType(options, String, "Parameter #1 (options) is not a String")
        TypeChecker.checkType(depend, signal, "Parameter #2 (depend) is not a signal")

        super.__New(GuiObject, "Slider", options,, depend)
    }
}


class SvanerText extends Svaner.Control {
    /**
     * Add a reactive Text control to Gui
     * @param {Gui} GuiObject The target Gui Object.
     * @param {string} options Options apply to the control, same as Gui.Add.
     * @param {string} content Text or formatted text to hold signal values.
     * @param {signal} [depend] Subscribed signal
     * @param {array} [key] the keys or index of the signal's value
     * @returns {SvanerText}     
     */
    __New(GuiObject, options := "", content := "", depend := 0, key := 0) {
        TypeChecker.checkType(options, String, "Parameter #1 (options) is not a String")
        TypeChecker.checkType(content, [String, Number], "Parameter #2 (content) is not a String")
        TypeChecker.checkTypeDepend(depend)

        this.key := key
        super.__New(GuiObject, "Text", options, content, depend, key)
    }
}


class SvanerTreeView extends Svaner.Control {
    __New(GuiObject, options := "", depend := 0, key := 0) {
        ; checkType(options, [String, Object.Prototype])

        this.key := key
        super.__New(GuiObject, "TreeView", options, "", depend, key)
    }

    class ShadowNode {
        /**
         * Make a copy node with the original tree
         * @param {Gui.TreeView} TreeView 
         * @param {Object} originNode 
         */
        __New(TreeView, originNode) {
            this.name := originNode.name
            this.content := originNode.content
            this.parent := ""
            this.children := []
            this.nodeId := 0
        }   

        /**
         * Creates a node on TreeView control
         * @param {Gui.TreeView} TreeView 
         * @param {Number} parentId 
         */
        createTreeViewNode(TreeView, parentId := 0) {
            if (parentId) {
                this.nodeId := TreeView.Add(this.name, parentId)
            } else {
                this.nodeId := TreeView.Add(this.name)
            }
        }
    }

    class ShadowTree {
        /**
         * Creates copy tree base on the depend tree-structured object/
         * @param {Gui.TreeView} TreeView 
         */
        __New(TreeView) {
            this.TreeView := TreeView
            this.root := ""
        }

        /**
         * Creates a copy with original tree-structured object.
         * @param {Object} originTree 
         */
        copy(originTree) {
            ; clear tree and copy root
            this.root := ""
            this.addChild(originTree.root)

            ; copyChildrens
            this.copyChild(originTree.root)
        }

        /**
         * Copy children node and add it to shadow tree.
         * @param {Object} originNode 
         */
        copyChild(originNode) {
            if (originNode.children.Length == 0) {
                return
            }

            for node in originNode.children {
                this.addChild(node, node.parent.name)
                this.copyChild(node)
            }
        }

        /**
         * Print tree nodes with a custom function.
         * @param {Func} fn 
         */
        print(fn := node => node) {
            results := []
            this._printTree(fn, results)

            return results
        }
        _printTree(fn := node => node, results := [], curNode := this.root) {
            results.Push(fn(curNode))

            if (curNode.children.Length > 0) {
                for childNode in curNode.children {
                    this._printTree(fn, results)
                }
            }
        }

        /**
         * Gets a ShadowNode with `content.name`.
         * @param {String} name content.name
         * @param {ShadowNode} curNode starting node
         * @returns {false|ShadowNode}
         */
        getNode(name, curNode := this.root) {
            if (name == curNode.name) {
                return curNode
            }

            if (curNode.children.Length > 0) {
                for childNode in curNode.children {
                    res := this.getNode(name, childNode)
                    if (res) {
                        return res
                    }
                }
            }

            return false
        }

        /**
         * Gets a ShadowNode with Item ID of a TreeView node.
         * @param {Number} nodeId Item ID of the target TreeView node
         * @param {ShadowNode} curNode starting node
         * @returns {false|ShadowNode}
         */
        getNodeById(nodeId, curNode := this.root) {
            if (nodeId == curNode.nodeId) {
                return curNode
            }

            if (curNode.children.Length > 0) {
                for childNode in curNode.children {
                    res := this.getNodeById(nodeId, childNode)
                    if (res) {
                        return res
                    }
                }
            }

            return false
        }

        /**
         * Adds a children node to a node.
         * @param {Object} originNode 
         * @param {String} parentName `content.name` of a node
         */
        addChild(originNode, parentName := 0) {
            newShadowNode := SvanerTreeView.ShadowNode(this.TreeView, originNode)

            if (!parentName && !this.root) {
                this.root := newShadowNode
                newShadowNode.createTreeViewNode(this.TreeView)
                return newShadowNode
            }

            if (!parentName && this.root) {
                this.root.children.Push(newShadowNode)
                newShadowNode.parent := this.root
                newShadowNode.createTreeViewNode(this.TreeView, this.root.nodeId)
                return newShadowNode
            }

            parentShadowNode := this.getNode(parentName)
            if (!parentShadowNode) {
                return false
            }

            newShadowNode.parent := parentShadowNode
            parentShadowNode.children.Push(newShadowNode)
            newShadowNode.createTreeViewNode(this.TreeView, parentShadowNode.nodeId)

            return newShadowNode
        }
    }
}