local wezterm = require("wezterm")

local M = {}
local override = {
  ["Tokyo Night"] = {
    selection_fg = "none",
    split = "#7aa2f7",
  },
}


function M.apply_to_config(config)
  config.color_scheme = "Tokyo Night"
  config.colors = override[config.color_scheme]
end


return M
