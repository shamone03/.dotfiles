-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

local TEMP_DIR = nil
-- This is where you actually apply your config choices.
config.window_background_opacity = 1.0
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	config.default_prog = { os.getenv("projects") .. "/.dotfiles/wezterm/nu-vs-dev-cmd.bat" }
	config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
	config.set_environment_variables = {
		XDG_CONFIG_HOME = os.getenv("projects") .. "/.dotfiles",
	}
	config.default_cwd = os.getenv("projects")
    TEMP_DIR = os.getenv("TEMP")
else
	config.default_prog = { "nu" }
	config.window_decorations = "NONE"
	config.default_cwd = os.getenv("HOME") .. "/Projects"
    TEMP_DIR = os.getenv("HOME") .. "/.cache"
end

-- config.hide_tab_bar_if_only_one_tab = true
config.font = wezterm.font({ family = "Hurmit Nerd Font Mono" })
config.initial_rows = 25
config.initial_cols = 110
config.cursor_blink_rate = 800
config.front_end = "WebGpu"
config.tab_bar_at_bottom = true
local act = wezterm.action

local function file_exists(path)
	local f = io.open(path, "r")
	if f then
		f:close()
		return true
	end
	return false
end

local theme_path = TEMP_DIR .. "/shmn/wezterm-base16-theme.yaml"
if file_exists(theme_path) then
	local colors, _ = wezterm.color.load_base16_scheme(theme_path)
	config.colors = colors
	wezterm.add_to_config_reload_watch_list(theme_path)
    print("Using theme " .. theme_path)
else
    print(theme_path .. " doesn't exist")
end

local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
tabline.setup({
	options = {
		theme = config.colors,
	},
	sections = {
		tabline_a = {
			cond = function()
				return false
			end,
		},
		tabline_b = {
			cond = function()
				return false
			end,
		},
		tab_active = {
			"index",
			{ "cwd", padding = { left = 0, right = 1 } },
			{ "zoomed", padding = 0 },
			max_length = 30,
		},
		tab_inactive = {
			"index",
			{ "cwd", padding = { left = 0, right = 1 } },
			{ "zoomed", padding = 0 },
		},
	},
})
tabline.apply_to_config(config)

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
	{
		key = "k",
		mods = "CTRL",
		action = act.ScrollByLine(-5),
	},
	{
		key = "j",
		mods = "CTRL",
		action = act.ScrollByLine(5),
	},
	{
		key = "d",
		mods = "CTRL|SHIFT",
		action = act.DisableDefaultAssignment,
	},
	{
		key = "u",
		mods = "CTRL|SHIFT",
		action = act.DisableDefaultAssignment,
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
