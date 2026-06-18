import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page

    // ── KConfigXT bindings — these sync automatically with main.xml entries ────
    property alias  cfg_workMinutes:       workSpin.value
    property alias  cfg_shortBreakMinutes: shortSpin.value
    property alias  cfg_longBreakMinutes:  longSpin.value
    property alias  cfg_longBreakInterval: intervalSpin.value
    property alias  cfg_autoContinue:      autoContinueSwitch.checked
    property string cfg_customPresetsJson: "[]"

    property var customPresets: []
    property var presetModel: []

    readonly property var builtinPresets: [
        { name: "Classic (25/5/15)",    work: 25, short: 5,  long: 15, interval: 4 },
        { name: "Extended (50/10/20)",  work: 50, short: 10, long: 20, interval: 4 },
        { name: "Deep Work (90/15/30)", work: 90, short: 15, long: 30, interval: 2 },
        { name: "Quick (15/3/10)",      work: 15, short: 3,  long: 10, interval: 4 }
    ]

    function loadCustomPresets() {
        try {
            var parsed = JSON.parse(cfg_customPresetsJson)
            customPresets = Array.isArray(parsed) ? parsed : []
        } catch (e) {
            customPresets = []
        }
    }

    function rebuildPresetModel() {
        var list = []
        for (var i = 0; i < builtinPresets.length; i++) list.push(builtinPresets[i])
        for (var j = 0; j < customPresets.length; j++) list.push(customPresets[j])
        presetModel = list
        presetCombo.model = list.map(function(p) { return p.name })
    }

    function selectMatchingPreset() {
        for (var i = 0; i < presetModel.length; i++) {
            var p = presetModel[i]
            if (p.work === workSpin.value && p.short === shortSpin.value &&
                p.long === longSpin.value && p.interval === intervalSpin.value) {
                presetCombo.currentIndex = i
                return
            }
        }
        presetCombo.currentIndex = -1   // current values don't match any saved preset
    }

    function applyPreset(index) {
        if (index < 0 || index >= presetModel.length) return
        var p = presetModel[index]
        workSpin.value     = p.work
        shortSpin.value    = p.short
        longSpin.value     = p.long
        intervalSpin.value = p.interval
    }

    function isCustomPresetIndex(index) {
        return index >= builtinPresets.length
    }

    Component.onCompleted: {
        loadCustomPresets()
        rebuildPresetModel()
        selectMatchingPreset()
    }

    // ── Preset picker ────────────────────────────────────────────────────────
    Controls.ComboBox {
        id: presetCombo
        Kirigami.FormData.label: "Preset:"
        Layout.fillWidth: true
        model: []
        onActivated: function(index) { applyPreset(index) }
    }

    Kirigami.Separator { Kirigami.FormData.isSection: true }

    // ── Manual duration fields ──────────────────────────────────────────────
    Controls.SpinBox {
        id: workSpin
        Kirigami.FormData.label: "Work duration (minutes):"
        from: 1; to: 180
        value: 25
        onValueChanged: page.selectMatchingPreset()
    }

    Controls.SpinBox {
        id: shortSpin
        Kirigami.FormData.label: "Short break (minutes):"
        from: 1; to: 60
        value: 5
        onValueChanged: page.selectMatchingPreset()
    }

    Controls.SpinBox {
        id: longSpin
        Kirigami.FormData.label: "Long break (minutes):"
        from: 1; to: 90
        value: 15
        onValueChanged: page.selectMatchingPreset()
    }

    Controls.SpinBox {
        id: intervalSpin
        Kirigami.FormData.label: "Pomodoros before long break:"
        from: 1; to: 10
        value: 4
        onValueChanged: page.selectMatchingPreset()
    }

    Controls.Switch {
        id: autoContinueSwitch
        Kirigami.FormData.label: "Auto-continue:"
        text: checked ? "Automatically starts the next phase" : "Pauses between phases (manual start)"
        checked: false
    }

    Kirigami.Separator { Kirigami.FormData.isSection: true }

    // ── Save current values as a new custom preset ──────────────────────────
    RowLayout {
        Kirigami.FormData.label: "Save as preset:"
        Controls.TextField {
            id: newPresetName
            placeholderText: "Preset name…"
            Layout.fillWidth: true
        }
        Controls.Button {
            text: "Save"
            enabled: newPresetName.text.length > 0
            onClicked: {
                page.customPresets.push({
                    name: newPresetName.text,
                    work: workSpin.value,
                    short: shortSpin.value,
                    long: longSpin.value,
                    interval: intervalSpin.value
                })
                page.cfg_customPresetsJson = JSON.stringify(page.customPresets)
                page.rebuildPresetModel()
                presetCombo.currentIndex = page.presetModel.length - 1
                newPresetName.text = ""
            }
        }
    }

    Controls.Button {
        text: "Delete Selected Preset"
        enabled: presetCombo.currentIndex >= 0 && page.isCustomPresetIndex(presetCombo.currentIndex)
        onClicked: {
            var customIdx = presetCombo.currentIndex - page.builtinPresets.length
            page.customPresets.splice(customIdx, 1)
            page.cfg_customPresetsJson = JSON.stringify(page.customPresets)
            page.rebuildPresetModel()
            page.selectMatchingPreset()
        }
    }
}
