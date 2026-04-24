local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local util = require("modules.widgets.util")
local M = {}
local function read_mem()
  local s = util.read_file("/proc/meminfo")
  if not s then return nil end
  local total = tonumber(s:match("MemTotal:%s+(%d+)")) or 0
  local avail = tonumber(s:match("MemAvailable:%s+(%d+)")) or 0
  local used = total - avail
  return total, used
end
local function human_kib(kib)
  local b = kib * 1024; local units = { "B", "KiB", "MiB", "GiB", "TiB" }; local i = 1
  while b >= 1024 and i < #units do b = b / 1024; i = i + 1 end
  if i <= 2 then return string.format("%d %s", math.floor(b + 0.5), units[i]) end
  return string.format("%.2f %s", b, units[i])
end
function M.widget()
  local txt = wibox.widget.textbox(); txt.font = beautiful.font_bold or beautiful.font
  local function update()
    local total, used = read_mem(); if not total then return end
    txt.markup = string.format('<span foreground="%s">RAM</span> <span foreground="%s">%s/%s</span>', beautiful.widget_dim_fg or beautiful.fg_minimize, beautiful.widget_fg or beautiful.fg_normal, human_kib(used), human_kib(total))
  end
  gears.timer{timeout=2.0,autostart=true,call_now=true,callback=update}
  return txt
end
return M
