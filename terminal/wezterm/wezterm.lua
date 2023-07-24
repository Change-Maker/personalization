local wezterm = require "wezterm"
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.audible_bell = "Disabled"
config.inactive_pane_hsb = {
  saturation = 1,
  brightness = 0.6,
}
launch_menu = {}

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
  table.insert(launch_menu, {
    label = "PowerShell",
    args = { "powershell.exe", "-NoLogo" },
  })
  config.wsl_domains = {
    {
      -- The name of this specific domain.  Must be unique amonst all types
      -- of domain in the configuration file.
      name = "WSL:Ubuntu-20.04",

      -- The name of the distribution.  This identifies the WSL distribution.
      -- It must match a valid distribution from your `wsl -l -v` output in
      -- order for the domain to be useful.
      distribution = "Ubuntu-20.04",

      -- The username to use when spawning commands in the distribution.
      -- If omitted, the default user for that distribution will be used.

      -- username = "hunter",

      -- The current working directory to use when spawning commands, if
      -- the SpawnCommand doesn"t otherwise specify the directory.

      default_cwd = "~",

      -- The default command to run, if the SpawnCommand doesn"t otherwise
      -- override it.  Note that you may prefer to use `chsh` to set the
      -- default shell for your user inside WSL to avoid needing to
      -- specify it here

      default_prog = { "fish" },
    },
  }
  config.default_domain = "WSL:Ubuntu-20.04"
end
config.launch_menu = launch_menu

config.color_scheme = "Tokyo Night"
config.colors = {
  selection_fg = "none",
}
config.force_reverse_video_cursor = true

config.font = wezterm.font {
  family = "FiraCode Nerd Font Mono",
  harfbuzz_features = { "ss03", "cv04", "calt=0" },
}

config.initial_cols = 120
config.initial_rows = 30

-- Tab Bar
local tab_bar = require "tab_bar"
tab_bar.apply_to_config(config)

-- Keybindings
local keybindings = require "keybindings"
keybindings.apply_to_config(config)

return config
