local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local util = require("modules.widgets.util")
local M = {}
local prev_total, prev_idle = nil, nil
local function read_cpu()
  local s = util.read_file("/proc/stat")
  if not s then return nil end
  local line = s:match("cpu%s+([^\n]+)")
  if not line then return nil end
  local user, nice, system, idle, iowait, irq, softirq, steal = line:match("(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")
  user, nice, system, idle, iowait, irq, softirq, steal = tonumber(user), tonumber(nice), tonumber(system), tonumber(idle), tonumber(iowait), tonumber(irq), tonumber(softirq), tonumber(steal)
  local idle_all = idle + iowait
  local total = user + nice + system + idle + iowait + irq + softirq + steal
  return total, idle_all
end
function M.widget()
  local txt = wibox.widget.textbox(); txt.font = beautiful.font_bold or beautiful.font
  local function update()
    local total, idle = read_cpu(); if not total then return end
    if prev_total and prev_idle then
      local dt = total - prev_total; local di = idle - prev_idle; local usage = 0
      if dt > 0 then usage = (dt - di) / dt * 100 end
      txt.markup = string.format('<span foreground="%s">CPU</span> <span foreground="%s">%d%%</span>', beautiful.widget_dim_fg or beautiful.fg_minimize, beautiful.widget_accent or beautiful.border_focus, math.floor(usage + 0.5))
    else
      txt.markup = string.format('<span foreground="%s">CPU</span> <span foreground="%s">--%%</span>', beautiful.widget_dim_fg or beautiful.fg_minimize, beautiful.widget_accent or beautiful.border_focus)
    end
    prev_total, prev_idle = total, idle
  end
  gears.timer{timeout=1.5,autostart=true,call_now=true,callback=update}
  return txt
end
return M
