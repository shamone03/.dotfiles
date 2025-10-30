-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

config.default_prog = { "nu" }
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
	config.set_environment_variables = {
		XDG_CONFIG_HOME = "C:/Users/aryah.kannan/Projects/.dotfiles",
	}
	config.default_cwd = "C:/Users/aryah.kannan/Projects/"
else
	config.window_decorations = "NONE"
	config.default_cwd = "/home/shamone/Projects/"
end

config.hide_tab_bar_if_only_one_tab = true
config.font = wezterm.font({ family = "Hurmit Nerd Font Mono", weight = "Bold" })
config.initial_rows = 25
config.initial_cols = 110
local act = wezterm.action

config.keys = {
	{
		key = "+",
		mods = "SHIFT|ALT",
		action = act.SplitHorizontal({
			domain = "CurrentPaneDomain",
		}),
	},
	{
		key = "_",
		mods = "SHIFT|ALT",
		action = act.SplitVertical({
			domain = "CurrentPaneDomain",
		}),
	},
	{
		key = "LeftArrow",
		mods = "ALT",
		action = act.ActivatePaneDirection("Left"),
	},
	{
		key = "RightArrow",
		mods = "ALT",
		action = act.ActivatePaneDirection("Right"),
	},
	{
		key = "UpArrow",
		mods = "ALT",
		action = act.ActivatePaneDirection("Up"),
	},
	{
		key = "DownArrow",
		mods = "ALT",
		action = act.ActivatePaneDirection("Down"),
	},
	{
		key = "w",
		mods = "CTRL|SHIFT",
		action = act.CloseCurrentPane({ confirm = true }),
	},
}

for i = 1, 8 do
	-- CTRL+ALT + number to activate that tab
	table.insert(config.keys, {
		key = tostring(i),
		mods = "CTRL|ALT",
		action = act.ActivateTab(i - 1),
	})
end

-- Finally, return the configuration to wezterm:
return config
