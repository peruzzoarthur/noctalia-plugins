--!nonstrict

-- Hyprwhspr — bar indicator for hyprwhspr-rs voice dictation.
--
-- Hidden while idle and healthy. Pulsing mic glyph while recording,
-- static loader while transcribing, muted mic-off with a setup hint
-- when hyprwhspr-rs is missing or its daemon is unreachable.
--
-- Left click while recording stops the recording. No other bindings:
-- starting is done with the hyprwhspr-rs keyboard shortcut.

local BIN = "hyprwhspr-rs"

local state = "idle" -- idle | recording | transcribing | error
local errorKey = "tooltip.error_daemon"
local pulse = false
local polling = false

local function parseStatus(stdout)
  local out = string.lower(stdout or "")
  -- Check "inactive" before "active": one contains the other.
  if string.find(out, "inactive") or string.find(out, "idle") then
    return "idle"
  end
  if string.find(out, "record") or string.find(out, "active") then
    return "recording"
  end
  if string.find(out, "process") or string.find(out, "transcrib") then
    return "transcribing"
  end
  return "error"
end

local function render()
  if state == "recording" then
    barWidget.setGlyph("microphone")
    barWidget.setGlyphColor(pulse and "error" or "on_surface")
    barWidget.setTooltip(noctalia.tr("tooltip.recording"))
    barWidget.setVisible(true)
  elseif state == "transcribing" then
    barWidget.setGlyph("loader")
    barWidget.setGlyphColor("primary")
    barWidget.setTooltip(noctalia.tr("tooltip.transcribing"))
    barWidget.setVisible(true)
  elseif state == "error" then
    barWidget.setGlyph("microphone-off")
    barWidget.setGlyphColor("on_surface_variant")
    barWidget.setTooltip(noctalia.tr(errorKey))
    barWidget.setVisible(true)
  else
    barWidget.setVisible(false)
  end
end

local function poll()
  if polling then
    return
  end
  if not noctalia.commandExists(BIN) then
    state = "error"
    errorKey = "tooltip.error_missing"
    render()
    return
  end
  polling = true
  noctalia.runAsync(BIN .. " record status", function(result)
    polling = false
    if result.exitCode == 0 then
      state = parseStatus(result.stdout)
    else
      state = "error"
      errorKey = "tooltip.error_daemon"
    end
    render()
  end)
end

function update()
  -- Adaptive cadence: react quickly only while something is happening.
  if state == "recording" or state == "transcribing" then
    noctalia.setUpdateInterval(250)
  else
    noctalia.setUpdateInterval(1000)
  end
  pulse = not pulse
  render()
  poll()
end

function onClick()
  if state == "recording" then
    noctalia.runAsync(BIN .. " record toggle", function()
      poll()
    end)
  end
end
