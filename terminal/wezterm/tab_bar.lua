local wezterm = require "wezterm"
local act = wezterm.action
local module = {}

-- This function returns the suggested title for a tab.
-- It prefers the title that was set via `tab:set_title()`
-- or `wezterm cli set-tab-title`, but falls back to the
-- title of the active pane in that tab.
local function tab_title(tab_info)
  local title = tab_info.tab_title
  -- if the tab title is explicitly set, take that
  if title and #title > 0 then
    return title
  end
  -- Otherwise, use the title from the active pane
  -- in that tab
  return tab_info.active_pane.title
end

local scheme = wezterm.get_builtin_color_schemes()["Tokyo Night"]
wezterm.on(
  "format-tab-title",
  function(tab, tabs, panes, cfg, hover, max_width)
    local edge_background = scheme.background
    local background = cfg.colors.tab_bar.inactive_tab.bg_color
    local foreground = cfg.colors.tab_bar.inactive_tab.fg_color

    if tab.is_active then
      background = cfg.colors.tab_bar.active_tab.bg_color
      foreground = cfg.colors.tab_bar.active_tab.fg_color
    elseif hover then
      background = cfg.colors.tab_bar.inactive_tab_hover.bg_color
      foreground = cfg.colors.tab_bar.inactive_tab_hover.fg_color
    end

    local edge_foreground = background

    local title = tab_title(tab)

    if tab.tab_index > 0 then
      -- ensure that the titles fit in the available space,
      -- and that we have room for the edges.
      if #title > max_width then
        title = wezterm.truncate_right(title, max_width - 5)
        title = string.format("%s…", title)
      end
      return {
        { Background = { Color = edge_background } },
        { Foreground = { Color = background } },
        { Text = wezterm.nerdfonts.ple_lower_right_triangle },
        { Background = { Color = background } },
        { Foreground = { Color = foreground } },
        { Text = " " .. title .. " " },
        { Background = { Color = edge_background } },
        { Foreground = { Color = edge_foreground } },
        { Text = wezterm.nerdfonts.ple_upper_left_triangle },
      }
    else
      -- ensure that the titles fit in the available space,
      -- and that we have room for the edges.
      if #title > max_width then
        title = wezterm.truncate_right(title, max_width - 4)
        title = string.format("%s…", title)
      end
      return {
        { Background = { Color = background } },
        { Foreground = { Color = foreground } },
        { Text = " " .. title .. " " },
        { Background = { Color = edge_background } },
        { Foreground = { Color = edge_foreground } },
        { Text = wezterm.nerdfonts.ple_upper_left_triangle },
      }
    end
  end
)

-- define a function in the module table.
-- Only functions defined in `module` will be exported to
-- code that imports this module.
-- The suggested convention for making modules that update
-- the config is for them to export an `apply_to_config`
-- function that accepts the config object, like this:
function module.apply_to_config(config)
  config.show_tab_index_in_tab_bar = false
  config.tab_max_width = 100
  config.tab_bar_at_bottom = true
  config.use_fancy_tab_bar = false
  config.show_new_tab_button_in_tab_bar = false
  config.hide_tab_bar_if_only_one_tab = true
end

-- return our module table
return module
