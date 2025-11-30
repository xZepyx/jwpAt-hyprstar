// modules/datetimepanel/Weather.qml
import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    radius: 14
    color: "#1e1e2e"
    antialiasing: true

    // Optional folder fallback: iconDir/<key>.svg
    property string iconDir: ""   // e.g. "../assets/weather"

    // Auto-set from sunrise/sunset
    property bool isNight: false

    // Sunrise/sunset
    property double sunriseMs: NaN
    property double sunsetMs: NaN

    // icon paths
    property string iconBase: "file://" + Quickshell.env("HOME") + "/.config/quickshell/assets/weather_icons"
    property var iconPaths: ({
        clear:            { day: iconBase + "/sun-1.svg", night: iconBase + "/moon-1.svg" },
        mostly_clear:     { day: iconBase + "/sun-1.svg", night: iconBase + "/moon-1.svg" },
        partly_cloudy:    { day: iconBase + "/partly-cloudy-1.svg", night: iconBase + "/partly-cloudy-3.svg" },
        overcast:         { day: iconBase + "/mostly-cloudy-1.svg", night: iconBase + "/mostly-cloudy-1.svg" },
        fog:              { day: iconBase + "/fog-1.svg", night: iconBase + "/fog-4.svg" },

        drizzle_light:    { day: iconBase + "/drizzle.svg", night: iconBase + "/drizzle.svg" },
        drizzle:          { day: iconBase + "/drizzle.svg", night: iconBase + "/drizzle.svg" },
        drizzle_heavy:    { day: iconBase + "/drizzle.svg", night: iconBase + "/drizzle.svg" },
        drizzle_freezing: { day: iconBase + "/snow-day-1.svg", night: iconBase + "/snow-night-1.svg" },

        rain_light:       { day: iconBase + "/rain-1.svg", night: iconBase + "/rain-1.svg" },
        rain:             { day: iconBase + "/rain-1.svg", night: iconBase + "/rain-1.svg" },
        rain_heavy:       { day: iconBase + "/heavy-rain-1.svg", night: iconBase + "/heavy-rain-1.svg" },
        rain_freezing:    { day: iconBase + "/hail-1.svg", night: iconBase + "/hail-1.svg" },

        snow_light:       { day: iconBase + "/snow.svg", night: iconBase + "/snow.svg" },
        snow:             { day: iconBase + "/snow.svg", night: iconBase + "/snow.svg" },
        snow_heavy:       { day: iconBase + "/blizzard.svg", night: iconBase + "/blizzard.svg" },
        snow_grains:      { day: iconBase + "/blizzard.svg", night: iconBase + "/blizzard.svg" },

        showers_light:    { day: iconBase + "/rain-1.svg", night: iconBase + "/rain-1.svg" },
        showers:          { day: iconBase + "/rain-1.svg", night: iconBase + "/rain-1.svg" },
        showers_heavy:    { day: iconBase + "/heavy-rain-1.svg", night: iconBase + "/heavy-rain-1.svg" },

        snow_showers:     { day: iconBase + "/rain-and-snow.svg", night: iconBase + "/rain-and-snow.svg" },

        thunder:          { day: iconBase + "/thunderstorm.svg", night: iconBase + "/thunderstorm.svg" },
        thunder_hail:     { day: iconBase + "/thunderstorm.svg", night: iconBase + "/thunderstorm.svg" },

        unknown:          { day: iconBase + "/sun-1.svg", night: iconBase + "/moon-1.svg" }
    })

    // Control refreshing from your panel if you want
    property bool active: true

    // data
    property real tempF: NaN
    property int weatherCode: -1
    property string condition: "Loading…"
    property real lat: NaN
    property real lon: NaN
    property string greeting: weekdayGreeting(new Date())
    property string cityLine: "Locating…"

    function weekdayGreeting(d) {
        const dayName = Qt.formatDateTime(d, "dddd") // Monday, Tuesday, ...
        const dow = d.getDay() // 0 Sun ... 5 Fri ... 6 Sat
        if (dow === 5) return "Happy Friday"
        if (dow === 6) return "It's Saturday!"
        return dayName
    }

    // --- helpers: parse "YYYY-MM-DDTHH:MM" as LOCAL time safely ---
    function parseLocalIso(iso) {
        // ex: "2025-11-28T16:32"
        if (!iso || iso.indexOf("T") === -1) return NaN
        const parts = iso.split("T")
        const d = parts[0].split("-")
        const t = parts[1].split(":")
        if (d.length < 3 || t.length < 2) return NaN
        const y = parseInt(d[0], 10)
        const m = parseInt(d[1], 10) - 1
        const day = parseInt(d[2], 10)
        const hh = parseInt(t[0], 10)
        const mm = parseInt(t[1], 10)
        const ss = (t.length >= 3) ? parseInt(t[2], 10) : 0
        return new Date(y, m, day, hh, mm, ss).getTime()
    }

    function updateNightFlag() {
        // Night = after (sunset+1h) OR before sunrise
        if (!isNaN(sunriseMs) && !isNaN(sunsetMs)) {
            const now = Date.now()
            const nightStart = sunsetMs + (60 * 60 * 1000)
            root.isNight = (now >= nightStart) || (now < sunriseMs)
        }
        // else: keep previous isNight (don’t thrash to false before we’ve fetched daily data)
    }

    // --- helpers: weather code -> icon key ---
    function iconKeyForCode(code) {
        if (code === 0) return "clear"
        if (code === 1) return "mostly_clear"
        if (code === 2) return "partly_cloudy"
        if (code === 3) return "overcast"
        if (code === 45 || code === 48) return "fog"

        if (code === 51) return "drizzle_light"
        if (code === 53) return "drizzle"
        if (code === 55) return "drizzle_heavy"
        if (code === 56 || code === 57) return "drizzle_freezing"

        if (code === 61) return "rain_light"
        if (code === 63) return "rain"
        if (code === 65) return "rain_heavy"
        if (code === 66 || code === 67) return "rain_freezing"

        if (code === 71) return "snow_light"
        if (code === 73) return "snow"
        if (code === 75) return "snow_heavy"
        if (code === 77) return "snow_grains"

        if (code === 80) return "showers_light"
        if (code === 81) return "showers"
        if (code === 82) return "showers_heavy"

        if (code === 85 || code === 86) return "snow_showers"

        if (code === 95) return "thunder"
        if (code === 96 || code === 99) return "thunder_hail"

        return "unknown"
    }

    // --- helpers: weather code -> text ---
    function conditionForCode(code) {
        if (code === 0) return "Clear"
        if (code === 1) return "Mostly clear"
        if (code === 2) return "Partly cloudy"
        if (code === 3) return "Overcast"
        if (code === 45 || code === 48) return "Fog"
        if (code === 51) return "Light drizzle"
        if (code === 53) return "Drizzle"
        if (code === 55) return "Heavy drizzle"
        if (code === 56 || code === 57) return "Freezing drizzle"
        if (code === 61) return "Light rain"
        if (code === 63) return "Rain"
        if (code === 65) return "Heavy rain"
        if (code === 66 || code === 67) return "Freezing rain"
        if (code === 71) return "Light snow"
        if (code === 73) return "Snow"
        if (code === 75) return "Heavy snow"
        if (code === 77) return "Snow grains"
        if (code === 80) return "Light showers"
        if (code === 81) return "Showers"
        if (code === 82) return "Heavy showers"
        if (code === 85 || code === 86) return "Snow showers"
        if (code === 95) return "Thunderstorm"
        if (code === 96 || code === 99) return "Thunderstorm (hail)"
        return "Unknown"
    }

    function iconSource() {
        const key = iconKeyForCode(weatherCode)

        const entry = iconPaths ? iconPaths[key] : null
        const preferred = entry ? (root.isNight ? entry.night : entry.day) : ""
        if (preferred && preferred.length > 0) return Qt.resolvedUrl(preferred)

        const unk = iconPaths ? iconPaths["unknown"] : null
        const unkPick = unk ? (root.isNight ? unk.night : unk.day) : ""
        if (unkPick && unkPick.length > 0) return Qt.resolvedUrl(unkPick)

        if (iconDir && iconDir.length > 0) return Qt.resolvedUrl(iconDir + "/" + key + ".svg")

        return ""
    }

    function refresh() {
        greeting = weekdayGreeting(new Date())
        updateNightFlag() // keep isNight current between refreshes

        if (!isNaN(lat) && !isNaN(lon)) fetchWeather()
        else fetchGeo()
    }

    function fetchGeo() {
        if (ipProc.running) return
        condition = "Locating…"
        cityLine = "Locating…"
        ipProc.buffer = ""
        ipProc.running = true
    }

    function fetchWeather() {
        if (meteoProc.running) return
        condition = "Updating…"
        meteoProc.buffer = ""

        const url =
            "https://api.open-meteo.com/v1/forecast" +
            "?latitude=" + lat +
            "&longitude=" + lon +
            "&current=temperature_2m,weather_code" +
            "&daily=sunrise,sunset" +
            "&forecast_days=1" +
            "&temperature_unit=fahrenheit" +
            "&timezone=auto"

        meteoProc.command = ["sh", "-c", "curl -s '" + url + "'"]
        meteoProc.running = true
    }

    // --- UI ---
    Item {
        anchors.fill: parent
        anchors.margins: 12

        Column {
            anchors.left: parent.left
            anchors.top: parent.top
            spacing: 2

            Text {
                text: root.greeting
                color: "#cdd6f4"
                opacity: 0.9
                font.pixelSize: 24
                font.weight: 300
                font.family: "Adwaita Sans"
            }

            Text {
                text: isNaN(tempF) ? "--°F" : (Math.round(tempF) + "°F")
                color: "#cdd6f4"
                font.pixelSize: 24
                font.weight: 600
                font.family: "Adwaita Sans"
            }

            Text {
                text: root.cityLine
                color: "#a6adc8"
                font.pixelSize: 12
                font.family: "Adwaita Sans"
                elide: Text.ElideRight
            }
        }

        Image {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 36
            anchors.rightMargin: -22
            width: 150
            height: 150
            source: iconSource()
            fillMode: Image.PreserveAspectFit
            smooth: true
            visible: source !== ""
            opacity: 0.95
        }
    }

    // --- refresh timer (10 min) ---
    Timer {
        interval: 600000
        repeat: true
        running: root.active
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    // --- ipinfo fetch ---
    Process {
        id: ipProc
        running: false
        command: ["sh", "-c", "curl -s 'https://ipinfo.io/json'"]
        property string buffer: ""

        stdout: SplitParser { onRead: data => { ipProc.buffer += data } }

        onRunningChanged: {
            if (running) return
            if (!ipProc.buffer || ipProc.buffer.trim() === "") {
                root.condition = "Location failed"
                return
            }
            try {
                const obj = JSON.parse(ipProc.buffer)

                const city = (obj.city || "").trim()
                const region = (obj.region || "").trim()
                root.cityLine = city
                    ? (region ? (city + ", " + region) : city)
                    : "Unknown location"

                const loc = (obj.loc || "").split(",")
                const latV = parseFloat(loc[0])
                const lonV = parseFloat(loc[1])
                if (isNaN(latV) || isNaN(lonV)) throw "bad loc"
                root.lat = latV
                root.lon = lonV
                root.fetchWeather()
            } catch (e) {
                root.condition = "Location failed"
                root.cityLine = "Location failed"
            }
        }
    }

    // --- open-meteo fetch ---
    Process {
        id: meteoProc
        running: false
        property string buffer: ""

        stdout: SplitParser { onRead: data => { meteoProc.buffer += data } }

        onRunningChanged: {
            if (running) return
            if (!meteoProc.buffer || meteoProc.buffer.trim() === "") {
                root.condition = "Weather failed"
                return
            }
            try {
                const obj = JSON.parse(meteoProc.buffer)

                const cur = obj.current || {}
                root.tempF = Number(cur.temperature_2m)
                root.weatherCode = Number(cur.weather_code)
                root.condition = root.conditionForCode(root.weatherCode)

                // sunrise/sunset for today (index 0)
                const daily = obj.daily || {}
                const sunriseStr = (daily.sunrise && daily.sunrise[0]) ? daily.sunrise[0] : ""
                const sunsetStr  = (daily.sunset  && daily.sunset[0])  ? daily.sunset[0]  : ""

                const sRise = root.parseLocalIso(sunriseStr)
                const sSet  = root.parseLocalIso(sunsetStr)

                if (!isNaN(sRise)) root.sunriseMs = sRise
                if (!isNaN(sSet))  root.sunsetMs  = sSet

                root.updateNightFlag()
            } catch (e) {
                root.condition = "Weather failed"
            }
        }
    }
}
