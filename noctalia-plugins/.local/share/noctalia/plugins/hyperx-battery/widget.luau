--!nonstrict
-- Only displays what the service publishes in noctalia.state("battery").

local function cfg(key, fallback)
  local value = noctalia.getConfig(key)
  if value == nil then
    return fallback
  end
  return value
end

local function batteryGlyph(percent, charging)
  if charging then
    return "battery-charging"
  elseif percent >= 80 then
    return "battery-4"
  elseif percent >= 55 then
    return "battery-3"
  elseif percent >= 30 then
    return "battery-2"
  elseif percent >= 10 then
    return "battery-1"
  end
  return "battery"
end

local function resetColors()
  barWidget.setColor("on_surface")
  barWidget.setGlyphColor("on_surface")
end

local function render(data)
  if data == nil then
    barWidget.setGlyph("headphones")
    barWidget.setText("")
    resetColors()
    barWidget.setTooltip("Reading headset battery…")
    return
  end

  if data.error ~= nil then
    barWidget.setGlyph("headphones-off")
    barWidget.setText("")
    resetColors()
    barWidget.setTooltip({ { "Headset", "unavailable" }, { "Reason", tostring(data.error) } })
    return
  end

  if not data.connected or data.percent == nil then
    barWidget.setGlyph("headphones-off")
    barWidget.setText("")
    resetColors()
    barWidget.setTooltip({ { "Headset", "off or out of range" } })
    return
  end

  local percent = data.percent
  local charging = data.charging == true

  if cfg("icon_style", "battery") == "headset" then
    barWidget.setGlyph("headphones")
  else
    barWidget.setGlyph(batteryGlyph(percent, charging))
  end

  barWidget.setText(if cfg("show_percent", true) then `{percent}%` else "")

  local low = cfg("low_threshold", 15)
  if percent <= low and not charging then
    barWidget.setColor("error")
    barWidget.setGlyphColor("error")
  else
    resetColors()
  end

  local rows = {
    { "Headset", data.device or "HyperX" },
    { "Battery", `{percent}%` },
    { "Status", if charging then "charging" else "discharging" },
  }
  if data.millivolts ~= nil then
    table.insert(rows, { "Voltage", `{data.millivolts} mV` })
  end
  barWidget.setTooltip(rows)
end

render(noctalia.state.get("battery"))
noctalia.state.watch("battery", render)

function onClick()
  noctalia.state.set("refresh_request", noctalia.nowMs())
end
