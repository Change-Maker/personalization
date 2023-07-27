local wezterm = require("wezterm")

local M = {}
local launch_menu = {
  {
    label = "PowerShell",
    args = { "powershell.exe", "-NoLogo" },
  },
}

local wsl_domains = {
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

function M.apply_to_config(config)
  config.default_domain = "WSL:Ubuntu-20.04"
  config.launch_menu = launch_menu
  config.wsl_domains = wsl_domains
end

return M
