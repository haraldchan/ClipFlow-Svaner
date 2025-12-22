class OptionParser {
    /**
     * Creates an option parser.
     * @param {Svaner} SvanerInstance 
     */
    __New(SvanerInstance) {
        this.svaner := SvanerInstance
        this.callbackDirectives := Map()
        this.customUseDirectives := Map()
        this.presetDirectives := Map(
            "@button:icon-only", "0x40 0x300",
            "@text:align-center", "Center 0x200",
            "@pic:real-size", "0x40",
            "@lv:label-tip", "LV0x4000",
            "@lv:track-select", "LV0x8",
            "@dt:updown", "0x1",
            "@mc:week-numbers", "0x4",
            "@mc:no-today-circle", "0x8",
            "@mc:no-today", "0x10",
        )
    }


    /**
     * Define custom directives.
     * @param {Map<string, ()=>void>} directiveDescriptor 
     */
    defineDirectives(directiveDescriptor) {
        for directive, optionsOrCallback in directiveDescriptor {
            if (!StringExt.startsWith(directive, "@")) {
                throw ValueError("Directive must starts with `"@`"", -1, directive)
            }

            if (StringExt.startsWith(directive, "@use:")) {
                this.customUseDirectives[directive] := optionsOrCallback
            }
            else if (StringExt.startsWith(directive, "@func:")) {
                this.callbackDirectives[directive] := optionsOrCallback
            }
        }
    }


    /**
     * Evaluate options/directives.
     * @param {String} opt 
     * @param {Array} callbackArray 
     * @returns {String} 
     * @throws {ValueError}
     */
    parseDirective(opt, callbackArray) {
        ; native ahk options
        if (!StringExt.startsWith(opt, "@")) {
            ; ahk options
            return opt
        }
        ; func directive, ignore
        else if (StringExt.startsWith(opt, "@func:")) {
            return this.callbackDirectives[opt]
        }
        ; preset directives
        else if (this.presetDirectives.Has(opt)) {
            return Format(" {1} ", this.presetDirectives[opt])
        }
        ; custom directives
        else if (this.customUseDirectives.Has(opt)) {
            return this._parseCustomUseDirectives(opt, callbackArray)
        }
        ; align directives
        else if (StringExt.startsWith(opt, "@align[") && InStr(opt, "]:")) {
            return this._handleAlignDirectives(opt)
        }
        ; relative directives
        else if (StringExt.startsWith(opt, "@relative[") && InStr(opt, "]:")) {
            return this._handleRelativeDirectives(opt)
        }
        ; unknown
        else {
            throw ValueError("Unknown directive. `n`nCustom directives must starts with `"@use:`" or `"@func:`".", -1, opt)
        }
    }

    _parseCustomUseDirectives(opt, callbackArray) {
        if (!InStr(this.customUseDirectives[opt], "@")) {
            return Format(" {1} ", this.customUseDirectives[opt])
        }

        parsed := ""
        loop parse this.customUseDirectives[opt], " " {
            res := this.parseDirective(A_LoopField, callbackArray)
            if (res is Func) {
                callbackArray.Push(res)
            } else {
                parsed .= Format(" {1} ", res)
            }
        }

        return parsed
    }

    _handleAlignDirectives(opt) {
        splittedOpts := StrSplit(opt, ":")
        alignments := StringExt.replaceThese(splittedOpts[1], ["@align[", "]"])
        targetCtrl := splittedOpts[2]

        this.svaner[targetCtrl].GetPos(&X, &Y, &Width, &Height)

        parsedPos := ""
        loop parse alignments, "" {
            switch StrLower(A_LoopField) {
                case "x":
                    parsedPos .= Format(" x{1} ", X)
                case "y":
                    parsedPos .= Format(" y{1} ", Y)
                case "w":
                    parsedPos .= Format(" w{1} ", Width)
                case "h":
                    parsedPos .= Format(" h{1} ", Height)
            }
        }

        return parsedPos
    }

    _handleRelativeDirectives(opt) {
        splittedOpts := StrSplit(opt, ":")
        relatives := StrLower(StringExt.replaceThese(splittedOpts[1], ["@relative[", "]"]))
        targetCtrl := splittedOpts[2]

        this.svaner[targetCtrl].GetPos(&X, &Y, &Width, &Height)

        parsedPos := ""
        for offset in StrSplit(relatives, ";") {
            switch {
                case InStr(offset, "x",,1):
                    parsedPos .= Format(" x{1} ", this._calcRelative(offset, X) + Width)       
                case InStr(offset, "y",,1):
                    parsedPos .= Format(" y{1} ", this._calcRelative(offset, Y) + Height)       
                case InStr(offset, "w",,1):
                    parsedPos .= Format(" w{1} ", this._calcRelative(offset, Width))       
                case InStr(offset, "h",,1):
                    parsedPos .= Format(" h{1} ", this._calcRelative(offset, Height))       
            }
        }

        return parsedPos
    }
    _calcRelative(offset, xywz) { ; +3, 200
        operator := match(offset, Map(
            o => InStr(o, "+"), "+",
            o => InStr(o, "-"), "-",
            o => InStr(o, "*"), "*",
            o => InStr(o, "/"), "/",
        ))

        offsetNum := Integer(StrSplit(offset, operator)[2])
        switch operator {
            case "+":
                return xywz + offsetNum
            case "-":
                return xywz - offsetNum
            case "*":
                return xywz * offsetNum
            case "/":                
                return xywz / offsetNum
        }
    }
}