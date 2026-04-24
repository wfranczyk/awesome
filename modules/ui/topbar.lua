-- modules/ui/topbar.lua
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")

local cpu = require("modules.widgets.cpu")
local ram = require("modules.widgets.ram")
local net = require("modules.widgets.net")

local topbar = {}

local function pill(widget, bg, fg)
  return wibox.widget{
    {
      widget,
      left   = 10,
      right  = 10,
      top    = 4,
      bottom = 4,
      widget = wibox.container.margin
    },
    bg = bg,
    fg = fg,
    shape = function(cr,w,h)
      gears.shape.rounded_rect(cr, w, h, beautiful.corner_radius or 10)
    end,
    widget = wibox.container.background
  }
end

local function taglist(s)
  local taglist_buttons = gears.table.join(
    awful.button({}, 1, function(t) t:view_only() end),
    awful.button({}, 3, awful.tag.viewtoggle),
    awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end)
  )

  return awful.widget.taglist{
    screen  = s,
    filter  = awful.widget.taglist.filter.all,
    buttons = taglist_buttons,
    layout  = {
      spacing = 8,
      layout  = wibox.layout.fixed.horizontal,
    },
    widget_template = {
      {
        {
          id     = "text_role",
          widget = wibox.widget.textbox,
          align  = "center",
          valign = "center",
          font   = beautiful.font_bold or beautiful.font,
        },
        widget  = wibox.container.margin
      },
      id     = "bg_role",
      widget = wibox.container.background,
      shape  = gears.shape.circle,
      update_callback = function(self, t)
        local txt = self:get_children_by_id("text_role")[1]
        if t.selected then
          self.bg = beautiful.tag_active_bg or beautiful.border_focus
          txt.markup = string.format('<span foreground="%s">%s</span>',
            beautiful.tag_active_fg or beautiful.bg_normal, t.name)
        elseif #t:clients() == 0 then
          self.bg = "#00000000"
          txt.markup = string.format('<span foreground="%s">%s</span>',
            beautiful.tag_empty_fg or beautiful.fg_minimize, t.name)
        else
          self.bg = "#00000000"
          txt.markup = string.format('<span foreground="%s">%s</span>',
            beautiful.tag_idle_fg or beautiful.fg_normal, t.name)
        end
      end
    }
  }
end

local function clock_widget()
  local txt = wibox.widget.textclock("%a %d %b %H:%M")
  txt.font = beautiful.font_bold or beautiful.font
  txt.align = "center"
  return pill(txt, beautiful.bg_normal, beautiful.clock_fg or beautiful.fg_normal)
end

function topbar.create(s)
  local bar = awful.wibar{
    screen   = s,
    position = "top",
    height   = beautiful.wibar_height or 38,
    bg       = "#00000000",
    fg       = beautiful.fg_normal,
    ontop    = false,
  }

  local logo = wibox.widget{
    markup = string.format(
      '<span foreground="%s" font="%s">A</span>',
      beautiful.border_focus or "#ff2fb9",
      beautiful.font_bold or beautiful.font
    ),
    widget = wibox.widget.textbox,
    align  = "center",
    valign = "center",
  }

  local left = wibox.widget{
    {
      logo,
      left = 12, right = 10, top = 6, bottom = 6,
      widget = wibox.container.margin
    },
    taglist(s),
    spacing = 10,
    layout  = wibox.layout.fixed.horizontal
  }

  local right = wibox.widget{
    pill(cpu.widget(), beautiful.bg_focus, beautiful.widget_fg),
    pill(ram.widget(), beautiful.bg_focus, beautiful.widget_fg),
    pill(net.widget(), beautiful.bg_focus, beautiful.widget_fg),

    -- Only show tray on primary screen
    (s == screen.primary) and wibox.widget.systray() or nil,

    clock_widget(),
    spacing = 10,
    layout  = wibox.layout.fixed.horizontal
  }

  local align = wibox.widget{
    left,
    wibox.widget.textbox(), -- safe spacer (don't use nil here)
    right,
    layout = wibox.layout.align.horizontal,
    expand = "none",
  }

  local inner = wibox.widget{
    align,
    left = 10, right = 10, top = 8, bottom = 6,
    widget = wibox.container.margin
  }

  local container = wibox.widget{
    inner,
    bg = (beautiful.bg_normal or "#000000") .. "dd",
    shape = function(cr,w,h)
      gears.shape.rounded_rect(cr, w, h, beautiful.corner_radius or 12)
    end,
    border_width = 1,
    border_color = (beautiful.neon and beautiful.neon.border1) or beautiful.border_normal,
    widget = wibox.container.background
  }

  bar:setup(container)
end

return topbar
