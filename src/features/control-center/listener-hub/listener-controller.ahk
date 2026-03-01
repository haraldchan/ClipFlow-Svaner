/** 
 * @typedef {Object} ListenerDescriptor 
 * @property {String} description
 * @property {"module" | "persist"} type
 * @property {true | false} isOn
 * @property {()=>void} callback
 */

class ListenerController {
    __New() {
        /** @type {signal.value<Array<ListenerDescriptor> | []>} */
        this.listeners := signal([])

        OnClipboardChange((*) => this.runListeners())
    }

    /**
     * Add listener to controller
     * @param {ListenerController} descriptor
     */
    addListener(descriptor) {
        prev := [this.listeners.value*]
        this.listeners.set(prev.append(descriptor))
    }

    runListeners() {
        for listener in this.listeners.value {
            if (listener.isOn) {
                listener.callback.Call()
            }
        }
    }
}