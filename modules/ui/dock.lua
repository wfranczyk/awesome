local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dock = {}
local function glow_icon(glyph, command, tooltip)
  local txt = wibox.widget{markup=string.format('<span foreground="%s">%s</span>', beautiful.dock_icon_fg or beautiful.fg_normal, glyph),font=beautiful.iconfont_big or beautiful.iconfont,align="center",valign="center",widget=wibox.widget.textbox}
  local btn = wibox.widget{{txt,margins=10,widget=wibox.container.margin},bg=beautiful.dock_icon_bg or beautiful.bg_focus,shape=function(cr,w,h) gears.shape.rounded_rect(cr,w,h,14) end,widget=wibox.container.background}
  btn:connect_signal("mouse::enter", function() btn.bg = (beautiful.dock_icon_hi or beautiful.border_focus) .. "33" end)
  btn:connect_signal("mouse::leave", function() btn.bg = beautiful.dock_icon_bg or beautiful.bg_focus end)
  btn:buttons(gears.table.join(awful.button({}, 1, function() awful.spawn(command, false) end)))
  if tooltip then
    awful.tooltip{objects={btn},text=tooltip,fg=beautiful.fg_normal,bg=beautiful.bg_normal,border_color=beautiful.border_focus,border_width=1,shape=function(cr,w,h) gears.shape.rounded_rect(cr,w,h,10) end}
  end
  return btn
end
function dock.create(s)
  local w = beautiful.dock_width or 62
  local dock_wibox = wibox{screen=s,width=w,height=s.geometry.height - (beautiful.wibar_height or 38) - 20,x=s.geometry.x + 10,y=s.geometry.y + (beautiful.wibar_height or 38) + 10,bg="#00000000",ontop=false,type="dock"}
  local icons = {
    {"", "alacritty", "Terminal"},
    {"", "firefox", "Firefox"},
    {"", "google-chrome-stable", "Chrome"},
    {"", "thunar", "Files"},
    {"", "thunderbird", "Thunderbird"},
  }
  local items = wibox.layout.fixed.vertical(); items.spacing = 10
  for _, it in ipairs(icons) do items:add(glow_icon(it[1], it[2], it[3])) end
  local content = wibox.widget{items,top=14,bottom=14,left=8,right=8,widget=wibox.container.margin}
  local container = wibox.widget{content,bg=beautiful.bg_normal .. "dd",shape=function(cr,ww,hh) gears.shape.rounded_rect(cr,ww,hh, beautiful.corner_radius or 14) end,border_width=1,border_color=beautiful.neon and beautiful.neon.border1 or beautiful.border_normal,widget=wibox.container.background}
  dock_wibox:setup(container)
  s:connect_signal("property::geometry", function()
    dock_wibox.height = s.geometry.height - (beautiful.wibar_height or 38) - 20
    dock_wibox.x = s.geometry.x + 10
    dock_wibox.y = s.geometry.y + (beautiful.wibar_height or 38) + 10
  end)
end
return dock
