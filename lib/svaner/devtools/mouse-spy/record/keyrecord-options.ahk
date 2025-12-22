#Include "./key-recorder.ahk"

/**
 * @typedef {Object} Props
 * @property {Map} config
 * @property {signal} recordedLog
 * @property {signal} isKeyRecording
 */

/**
 * @param {Svaner} App 
 * @param {Props} props
 * @returns {Component} 
 */
MouseSpy_Record_KeyRecordOptions(App, props) {
    config := props.config
    recordedLog := props.recordedLog
    isKeyRecording := props.isKeyRecording

    comp := Component(App, A_ThisFunc)

    logLinePrint := signal([{ keyName: "", updn: "", elapsed: "" }], { name: "logLinePrint" })
    recorder := KeyRecorder({
        recordedLog: recordedLog, 
        isKeyRecording: isKeyRecording, 
        loglinePrint: logLinePrint,
        replaceSleep: { 
            isReplace: (*) => App["replace-sleep"].Value, 
            stepFiller: (*) => App["step-filler-snippet"].Value
        },
        saveLog: false
    })

    lvOptions := {
        lvOptions: "xs10 w325 y+10 r3"
    }

    columnDetails := {
        keys: ["vk", "sc","keyName", "updn", "elapsed"],
        titles: ["vk", "sc", "Key", "Up/Dn", "Elapsed"],
        widths: [40, 40, 110, 60, 60]
    }

    effect(isKeyRecording, handleRecordToggle)
    handleRecordToggle(recording) {
        App["key-record-toggler"].Enabled := !recording
        App["key-record-toggler"].Text := recording ? "{Esc} to stop" : "Start"

        if (recording) {
            recorder.Start()
            recorder.Wait()
        }
    }

    comp.render := this => this.Add(
        App.AddButton("vkey-record-toggler xs10 y110 w80 h20", "Start").onClick((*) => isKeyRecording.set(true)),
        App.AddCheckbox("vreplace-sleep x+30 w210 h20", "Replace `"Sleep`" with Step Filler"),
        ; key history log
        App.AddListView(lvOptions, columnDetails, logLinePrint)
    )

    return comp
}