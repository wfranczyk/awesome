Neonwave Awesome WM Theme

Install:
1. Unzip into ~/.config/awesome/
2. In rc.lua add:

local gears = require("gears")
local beautiful = require("beautiful")
beautiful.init(gears.filesystem.get_configuration_dir() .. "themes/neonwave/theme.lua")
require("modules.ui").setup()

Apps used by the dock:
- alacritty
- firefox
- google-chrome-stable
- thunar
- thunderbird

Override network interface if needed:
export NEONWAVE_NET_IFACE=enp3s0

Recommended fonts:
- JetBrainsMono Nerd Font
- Symbols Nerd Font
