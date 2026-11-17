--!nonstrict
-- Reads the headset in a single place and publishes the result in noctalia.state,
-- so widgets on several monitors never talk to the receiver at the same time.

local pending = false
local warnedLow = false

local function cfg(key, fallback)
  local value = noctalia.getConfig(key)
  if value == nil then
    return fallback
  end
  return value
end

local function checkLow(data)
  if not cfg("notify_low", true) or data.percent == nil then
    return
  end
  local low = cfg("low_threshold", 15)
  if data.charging or data.percent > low + 5 then
    warnedLow = false
  elseif data.percent <= low and not warnedLow then
    warnedLow = true
    noctalia.notify("Headset battery low", `{data.percent}% remaining`)
  end
end

local function refresh()
  if pending then
    return
  end
  pending = true

  local script = noctalia.expandPath(cfg("script", "~/.local/bin/hyperx-stinger-battery"))
  local started = noctalia.runAsync({ script, "--json" }, function(result)
    pending = false
    local out = noctalia.string.trim(result.stdout or "")
    local data = nil
    if out ~= "" then
      data = noctalia.json.decode(out)
    end
    if type(data) ~= "table" then
      local err = noctalia.string.trim(result.stderr or "")
      data = { error = if err ~= "" then err else "the script returned no output" }
    end
    data.updatedAt = noctalia.nowMs()
    noctalia.state.set("battery", data)
    if data.connected then
      checkLow(data)
    end
  end)

  if not started then
    pending = false
    noctalia.state.set("battery", { error = "could not run " .. script, updatedAt = noctalia.nowMs() })
  end
end

noctalia.setUpdateInterval(cfg("interval", 60) * 1000)

function update()
  refresh()
end

-- Clicking the widget requests an immediate reading.
noctalia.state.watch("refresh_request", function(_value)
  refresh()
end)

refresh()
