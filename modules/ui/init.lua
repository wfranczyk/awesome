local ui = {}
function ui.setup()
  local awful = require("awful")
  local topbar = require("modules.ui.topbar")
  local dock = require("modules.ui.dock")
  awful.screen.connect_for_each_screen(function(s)
    topbar.create(s)
    dock.create(s)
  end)
end
return ui
