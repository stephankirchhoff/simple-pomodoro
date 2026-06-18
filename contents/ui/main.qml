import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.plasma.plasmoid
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as P5Support

PlasmoidItem {
    id: root

    preferredRepresentation: compactRepresentation

    // ── Durations (seconds) — driven by the Settings page (right-click → Configure) ──
    readonly property int workSecs:       Plasmoid.configuration.workMinutes * 60
    readonly property int shortBreakSecs: Plasmoid.configuration.shortBreakMinutes * 60
    readonly property int longBreakSecs:  Plasmoid.configuration.longBreakMinutes * 60
    readonly property int longBreakEvery: Plasmoid.configuration.longBreakInterval

    // ── State ────────────────────────────────────────────────────────────────
    property int    timeLeft:      workSecs
    property bool   running:       false
    property string phase:         "work"   // "work" | "shortBreak" | "longBreak"
    property int    pomodoroCount: 0
    property int    wiggleTrigger: 0        // bump this to play the wiggle animation

    // If the settings change while the timer is idle, reflect the new duration immediately
    Connections {
        target: Plasmoid.configuration
        function onValueChanged() {
            if (!root.running) {
                root.timeLeft = root.phaseTotalSecs
            }
        }
    }

    // ── Derived ──────────────────────────────────────────────────────────────
    property string phaseEmoji: {
        if (phase === "work")        return "🍅"
        if (phase === "shortBreak")  return "☕"
        return "🌿"
    }
    property string phaseLabel: {
        if (phase === "work")        return "Focus"
        if (phase === "shortBreak")  return "Short Break"
        return "Long Break"
    }
    property int phaseTotalSecs: {
        if (phase === "work")        return workSecs
        if (phase === "shortBreak")  return shortBreakSecs
        return longBreakSecs
    }
    property string timeString: {
        var m = Math.floor(timeLeft / 60)
        var s = timeLeft % 60
        return (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s
    }

    toolTipMainText: phaseEmoji + "  " + phaseLabel + " — " + timeString
    toolTipSubText:  "Pomodoros completed: " + pomodoroCount +
                     (running ? "" : "  (paused — click the icon to start)")

    // ── One-second countdown ─────────────────────────────────────────────────
    Timer {
        id: ticker
        interval: 1000
        repeat: true
        onTriggered: {
            if (root.timeLeft > 0) {
                root.timeLeft--
            } else {
                root.advancePhase()
            }
        }
    }

    // ── Shell runner — used to call notify-send ──────────────────────────────
    P5Support.DataSource {
        id: runner
        engine: "executable"
        connectedSources: []
        onNewData: function(sourceName) { disconnectSource(sourceName) }
    }

    function notify(title, body) {
        runner.connectSource(
            "notify-send --app-name='Pomodoro' --icon=appointment-soon '" + title + "' '" + body + "'"
        )
    }

    // ── Logic ────────────────────────────────────────────────────────────────
    function advancePhase() {
        ticker.stop()
        running = false
        if (phase === "work") {
            pomodoroCount++
            if (pomodoroCount % longBreakEvery === 0) {
                phase    = "longBreak"
                timeLeft = longBreakSecs
                notify("Pomodoro complete!", "Long break time 🌿")
            } else {
                phase    = "shortBreak"
                timeLeft = shortBreakSecs
                notify("Pomodoro complete!", "Short break time ☕")
            }
        } else {
            phase    = "work"
            timeLeft = workSecs
            notify("Break over!", "Back to focusing 🍅")
        }
        wiggleTrigger++   // play the wiggle whenever a new phase begins

        if (Plasmoid.configuration.autoContinue) {
            running = true
            ticker.start()
        }
    }

    function toggle() {
        if (running) { ticker.stop();  running = false }
        else         { ticker.start(); running = true  }
    }

    function skip() {
        ticker.stop()
        running = false
        advancePhase()
    }

    function resetAll() {
        ticker.stop()
        running       = false
        phase         = "work"
        timeLeft      = workSecs
        pomodoroCount = 0
    }

    // ── Presets — shared list used by the popup's quick-switch selector ────────
    readonly property var builtinPresets: [
        { name: "Classic (25/5/15)",    work: 25, short: 5,  long: 15, interval: 4 },
        { name: "Extended (50/10/20)",  work: 50, short: 10, long: 20, interval: 4 },
        { name: "Deep Work (90/15/30)", work: 90, short: 15, long: 30, interval: 2 },
        { name: "Quick (15/3/10)",      work: 15, short: 3,  long: 10, interval: 4 }
    ]

    function customPresetsList() {
        try {
            var parsed = JSON.parse(Plasmoid.configuration.customPresetsJson)
            return Array.isArray(parsed) ? parsed : []
        } catch (e) {
            return []
        }
    }

    function allPresets() {
        return builtinPresets.concat(customPresetsList())
    }

    function applyPreset(p) {
        Plasmoid.configuration.workMinutes       = p.work
        Plasmoid.configuration.shortBreakMinutes = p.short
        Plasmoid.configuration.longBreakMinutes  = p.long
        Plasmoid.configuration.longBreakInterval = p.interval
    }

    // ── Compact representation — the text shown in the panel ───────────────────
    compactRepresentation: Item {
        id: compact

        implicitWidth: compactRow.implicitWidth + Kirigami.Units.smallSpacing * 2

        // NOTE: emoji glyphs from color-emoji fonts often paint larger than their
        // reported font metrics, so a hit area sized purely from Text.implicitWidth
        // leaves a "dead zone" right where the glyph visually sits. Each zone below
        // gets an explicit, generous fixed size instead of relying on font metrics,
        // so clicking the visible icon or digits always registers.
        Row {
            id: compactRow
            anchors.centerIn: parent
            spacing: Math.round(compact.height * 0.08)

            // Wiggle transform applied to the whole icon+time group
            transform: Rotation {
                id: wiggleRot
                origin.x: compactRow.width  / 2
                origin.y: compactRow.height / 2
                angle: 0
            }

            // ── Icon zone — click to start/pause ───────────────────────────────
            Item {
                id: iconZone
                width: Math.round(compact.height * 0.85)
                height: compact.height
                scale: 1.0

                transform: Rotation {
                    id: spinRot
                    origin.x: iconZone.width  / 2
                    origin.y: iconZone.height / 2
                    angle: 0
                }

                Text {
                    anchors.centerIn: parent
                    text: root.phaseEmoji
                    font.pixelSize: Math.round(compact.height * 0.42)
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.toggle()
                        clickSpin.start()
                    }
                }

                // Clear click feedback: a full spin plus a little grow/shrink pop.
                // (A subtle scale-only pulse turned out invisible on small panel icons.)
                ParallelAnimation {
                    id: clickSpin
                    SequentialAnimation {
                        NumberAnimation { target: spinRot; property: "angle"; from: 0; to: 360; duration: 380; easing.type: Easing.OutCubic }
                        ScriptAction    { script: spinRot.angle = 0 }   // snap back invisibly (360° looks identical to 0°)
                    }
                    SequentialAnimation {
                        NumberAnimation { target: iconZone; property: "scale"; to: 1.3; duration: 150; easing.type: Easing.OutQuad }
                        NumberAnimation { target: iconZone; property: "scale"; to: 1.0; duration: 200; easing.type: Easing.OutBack }
                    }
                }
            }

            // ── Time zone — click to open the popup ─────────────────────────────
            Item {
                id: timeZone
                width: timeText.implicitWidth + Math.round(compact.height * 0.3)
                height: compact.height

                Text {
                    id: timeText
                    anchors.centerIn: parent
                    text: root.timeString
                    font.pixelSize: Math.round(compact.height * 0.45)
                    font.bold: true
                    font.family: "monospace"
                    color: "#ffffff"
                    style: Text.Outline
                    styleColor: "#80000000"     // subtle dark outline so it reads on light panels too
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.expanded = !root.expanded
                }
            }
        }

        // Wiggle animation — plays whenever wiggleTrigger changes (i.e. a phase completes)
        SequentialAnimation {
            id: wiggleAnim
            NumberAnimation { target: wiggleRot; property: "angle"; to: -14; duration: 55;  easing.type: Easing.InOutQuad }
            NumberAnimation { target: wiggleRot; property: "angle"; to:  14; duration: 100; easing.type: Easing.InOutQuad }
            NumberAnimation { target: wiggleRot; property: "angle"; to:  -9; duration: 90;  easing.type: Easing.InOutQuad }
            NumberAnimation { target: wiggleRot; property: "angle"; to:   9; duration: 80;  easing.type: Easing.InOutQuad }
            NumberAnimation { target: wiggleRot; property: "angle"; to:   0; duration: 70;  easing.type: Easing.InOutQuad }
        }
        Connections {
            target: root
            function onWiggleTriggerChanged() { wiggleAnim.start() }
        }
    }

    // ── Full representation — popup opened by clicking the time digits ─────────
    fullRepresentation: ColumnLayout {
        spacing: Kirigami.Units.largeSpacing
        Layout.preferredWidth: Kirigami.Units.gridUnit * 16
        Layout.minimumHeight:  implicitHeight

        PlasmaComponents.Label {
            Layout.alignment: Qt.AlignHCenter
            text: root.phaseEmoji + "  " + root.phaseLabel
            font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.4
            font.bold: true
        }

        PlasmaComponents.Label {
            Layout.alignment: Qt.AlignHCenter
            text: root.timeString
            font.pointSize: 34
            font.bold: true
            font.family: "monospace"
            color: Kirigami.Theme.textColor
        }

        Controls.ProgressBar {
            Layout.fillWidth: true
            value: 1.0 - (root.timeLeft / root.phaseTotalSecs)
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: Kirigami.Units.smallSpacing

            PlasmaComponents.Button {
                text: root.running ? "⏸  Pause" : "▶  Start"
                onClicked: root.toggle()
            }
            PlasmaComponents.Button {
                text: "⏭  Skip"
                onClicked: root.skip()
            }
            PlasmaComponents.Button {
                text: "↺  Reset"
                onClicked: root.resetAll()
            }
        }

        PlasmaComponents.Label {
            Layout.alignment: Qt.AlignHCenter
            text: "Pomodoros today: " + root.pomodoroCount
            opacity: 0.65
        }

        Kirigami.Separator { Layout.fillWidth: true }

        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            PlasmaComponents.Label { text: "Preset:" }

            Controls.ComboBox {
                id: presetPicker
                Layout.fillWidth: true
                model: root.allPresets().map(function(p) { return p.name })
                currentIndex: {
                    var list = root.allPresets()
                    for (var i = 0; i < list.length; i++) {
                        var p = list[i]
                        if (p.work === Plasmoid.configuration.workMinutes &&
                            p.short === Plasmoid.configuration.shortBreakMinutes &&
                            p.long === Plasmoid.configuration.longBreakMinutes &&
                            p.interval === Plasmoid.configuration.longBreakInterval) {
                            return i
                        }
                    }
                    return -1
                }
                onActivated: function(index) {
                    var list = root.allPresets()
                    if (index >= 0 && index < list.length) {
                        root.applyPreset(list[index])
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            PlasmaComponents.Label {
                text: "Auto-continue"
                Layout.fillWidth: true
            }

            Controls.Switch {
                checked: Plasmoid.configuration.autoContinue
                onToggled: Plasmoid.configuration.autoContinue = checked
            }
        }

        PlasmaComponents.Label {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            text: "Tip: right-click the panel icon → Configure to create your own presets"
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            opacity: 0.55
        }

        Item { Layout.preferredHeight: Kirigami.Units.smallSpacing }
    }
}
