local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local util = require("modules.widgets.util")
local M = {}
local iface = util.detect_iface()
local prev_rx, prev_tx, prev_t = 0, 0, nil
local function now_seconds() return os.time() + (os.clock() % 1) end
local function read_dev_bytes()
  local s = util.read_file("/proc/net/dev"); if not s then return nil end
  local line = s:match("\n%s*" .. iface:gsub("%-", "%%-") .. ":%s*[^\n]+")
  if not line then
    iface = util.detect_iface()
    line = s:match("\n%s*" .. iface:gsub("%-", "%%-") .. ":%s*[^\n]+")
    if not line then return nil end
  end
  local data = line:match(iface:gsub("%-", "%%-") .. ":%s*(.+)"); if not data then return nil end
  local fields = {}
  for num in data:gmatch("(%d+)") do fields[#fields+1] = tonumber(num) end
  return fields[1] or 0, fields[9] or 0
end
function M.widget()
  local txt = wibox.widget.textbox(); txt.font = beautiful.font_bold or beautiful.font
  local function update()
    local rx, tx = read_dev_bytes(); if not rx then return end
    local now = now_seconds()
    if prev_t then
      local dt = now - prev_t
      if dt > 0.2 then
        local rx_rate = (rx - prev_rx) / dt; local tx_rate = (tx - prev_tx) / dt
        txt.markup = string.format('<span foreground="%s">NET</span> <span foreground="%s">↓ %s</span> <span foreground="%s">↑ %s</span>', beautiful.widget_dim_fg or beautiful.fg_minimize, beautiful.widget_fg or beautiful.fg_normal, util.human_rate(rx_rate), beautiful.widget_fg or beautiful.fg_normal, util.human_rate(tx_rate))
      end
    else
      txt.markup = string.format('<span foreground="%s">NET</span> <span foreground="%s">↓ --  ↑ --</span>', beautiful.widget_dim_fg or beautiful.fg_minimize, beautiful.widget_fg or beautiful.fg_normal)
    end
    prev_rx, prev_tx, prev_t = rx, tx, now
  end
  gears.timer{timeout=1.0,autostart=true,call_now=true,callback=update}
  return txt
end
return M
