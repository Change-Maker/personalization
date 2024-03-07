local wezterm = require("wezterm")

local M = {}
local override = {
  ["Tokyo Night"] = {
    colors = {
      split = "#7aa2f7",
      copy_mode_active_highlight_bg = { Color = "#ff9e64" },
      copy_mode_active_highlight_fg = { Color = "#1a1b26" },
    },
    command_palette_bg_color = "#24283b",
    command_palette_fg_color = "#a9b1d6",
  },
}

function M.apply_to_config(config)
  config.color_scheme = "Tokyo Night"
  for k, v in pairs(override[config.color_scheme]) do
    config[k] = v
  end
end

return M
