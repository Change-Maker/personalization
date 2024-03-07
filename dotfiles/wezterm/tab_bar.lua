local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

-- This function returns the suggested title for a tab.
-- It prefers the title that was set via `tab:set_title()`
-- or `wezterm cli set-tab-title`, but falls back to the
-- title of the active pane in that tab.
local function tab_title(tab_info)
  local zoomed = ""
  if tab_info.active_pane.is_zoomed then
    zoomed = "[Z] "
  end
  local title = tab_info.tab_title
  -- if the tab title is explicitly set, take that
  if title and #title > 0 then
    return zoomed..title
  end
  -- Otherwise, use the title from the active pane
  -- in that tab
  return zoomed..tab_info.active_pane.title
end

local scheme = wezterm.get_builtin_color_schemes()["Tokyo Night"]
local colors = {
  active = {
    bg = "#ff9e64",
    fg = "#1a1b26",
  },
  inactive = {
    bg = "#7aa2f7",
    fg = "#1a1b26",
  },
  separator = "#1a1b26",
  right_status = {
    bg = "#2ac3de",
    fg = "#1a1b26",
  },
}

local function bubble(tab, tabs, panes, cfg, hover, max_width)
  local edge_bg = colors.separator
  local bg = colors.inactive.bg
  local fg = colors.inactive.fg

  if tab.is_active then
    bg = colors.active.bg
    fg = colors.active.fg
  end

  local edge_fg = bg

  local title = tab_title(tab)
  title = " "..title

  -- ensure that the titles fit in the available space,
  -- and that we have room for the edges.
  if #title > max_width then
    title = wezterm.truncate_right(title, max_width - 3)
    title = string.format("%s…", title)
  end

  return {
    { Background = { Color = edge_bg } },
    { Foreground = { Color = bg } },
    { Text = wezterm.nerdfonts.ple_left_half_circle_thick },
    { Background = { Color = bg } },
    { Foreground = { Color = fg } },
    { Text = title:sub(2) },
    { Background = { Color = edge_bg } },
    { Foreground = { Color = edge_fg } },
    { Text = wezterm.nerdfonts.ple_right_half_circle_thick },
  }
end

local function powerline_slant(tab, tabs, panes, cfg, hover, max_width)
  local edge_bg = colors.separator
  local bg = colors.inactive.bg
  local fg = colors.inactive.fg

  if tab.is_active then
    bg = colors.active.bg
    fg = colors.active.fg
  end

  local edge_fg = bg

  local title = tab_title(tab)
  title = " "..title.." "

  if tab.tab_index > 0 then
    -- ensure that the titles fit in the available space,
    -- and that we have room for the edges.
    if #title > max_width then
      title = wezterm.truncate_right(title, max_width - 4)
      title = string.format("%s… ", title)
    end
    return {
      { Background = { Color = edge_bg } },
      { Foreground = { Color = bg } },
      { Text = wezterm.nerdfonts.ple_lower_right_triangle },
      { Background = { Color = bg } },
      { Foreground = { Color = fg } },
      { Text = title },
      { Background = { Color = edge_bg } },
      { Foreground = { Color = edge_fg } },
      { Text = wezterm.nerdfonts.ple_upper_left_triangle },
    }
  else
    -- ensure that the titles fit in the available space,
    -- and that we have room for the edges.
    if #title > max_width then
      title = wezterm.truncate_right(title, max_width - 3)
      title = string.format("%s… ", title)
    end
    return {
      { Background = { Color = bg } },
      { Foreground = { Color = fg } },
      { Text = title },
      { Background = { Color = edge_bg } },
      { Foreground = { Color = edge_fg } },
      { Text = wezterm.nerdfonts.ple_upper_left_triangle },
    }
  end
end

local function flexbox_left_sep(tab, tabs, panes, cfg, hover, max_width)
  local edge_fg = colors.separator
  local bg = colors.inactive.bg
  local fg = colors.inactive.fg

  if tab.is_active then
    bg = colors.active.bg
    fg = colors.active.fg
  end

  local edge_bg = bg

  local title = tab_title(tab)
  title = title.." "

  -- ensure that the titles fit in the available space,
  -- and that we have room for the edges.
  if #title > max_width then
    title = wezterm.truncate_right(title, max_width - 3)
    title = string.format("%s… ", title)
  end

  return {
    { Background = { Color = edge_bg } },
    { Foreground = { Color = edge_fg } },
    { Text = "▏" },
    { Background = { Color = bg } },
    { Foreground = { Color = fg } },
    { Text = title },
  }
end

local function flexbox_right_sep(tab, tabs, panes, cfg, hover, max_width)
  local edge_fg = colors.separator
  local bg = colors.inactive.bg
  local fg = colors.inactive.fg

  if tab.is_active then
    bg = colors.active.bg
    fg = colors.active.fg
  end

  local edge_bg = bg

  local title = tab_title(tab)
  title = " "..title

  -- ensure that the titles fit in the available space,
  -- and that we have room for the edges.
  if #title > max_width then
    title = title:sub(2, -1)
    title = wezterm.truncate_right(title, max_width - 3)
    title = string.format(" %s…", title)
  end

  return {
    { Background = { Color = bg } },
    { Foreground = { Color = fg } },
    { Text = title },
    { Background = { Color = edge_bg } },
    { Foreground = { Color = edge_fg } },
    { Text = "▕" },
  }
end

wezterm.on("format-tab-title", flexbox_left_sep)

local function update_right_status(window, pane)
  local key_table = window:active_key_table()
  if key_table then
    window:set_right_status(wezterm.format({
      { Background = { Color = colors.right_status.bg } },
      { Foreground = { Color = colors.separator } },
      { Text = wezterm.nerdfonts.ple_upper_left_triangle },
      { Background = { Color = colors.right_status.bg } },
      { Foreground = { Color = colors.right_status.fg } },
      { Text = " TABLE: "..key_table.." " },
    }))
  else
    window:set_right_status("")
  end
end

wezterm.on("update-right-status", update_right_status)

function M.apply_to_config(config)
  config.show_new_tab_button_in_tab_bar = false
  config.show_tab_index_in_tab_bar = false
  config.tab_max_width = 100
  config.tab_bar_at_bottom = true
  config.use_fancy_tab_bar = false
end

return M
