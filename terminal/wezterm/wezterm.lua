local wezterm = require("wezterm")

local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
  local windows_platform = require("windows_platform")
  windows_platform.apply_to_config(config)
end

-- Colors
local colors = require("colors")
colors.apply_to_config(config)

-- General
config.audible_bell = "Disabled"
config.window_decorations = "RESIZE"
config.inactive_pane_hsb = {
  saturation = 1,
  brightness = 0.6,
}
config.initial_cols = 120
config.initial_rows = 30

-- Make block cursor reverse bg and fg colors when a character under it.
config.force_reverse_video_cursor = true

-- Fonts
config.font = wezterm.font {
  family = "FiraCode Nerd Font Mono",
  harfbuzz_features = { "ss03", "cv04", "calt=0" },
}

-- Tab Bar
local tab_bar = require("tab_bar")
tab_bar.apply_to_config(config)

-- Keybindings
local keybindings = require("keybindings")
keybindings.apply_to_config(config)

return config
