local wezterm = require("wezterm")

local M = {}
local override = {
  ["Tokyo Night"] = {
    colors = {
      selection_fg = "none",
      split = "#7aa2f7",
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
