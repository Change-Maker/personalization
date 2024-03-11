# Neovim Personalization

![overview](https://user-images.githubusercontent.com/18575008/253444992-bdba7261-98ff-49e3-b9d7-d4ace6dff1c0.png)

![overview easymotion](https://user-images.githubusercontent.com/18575008/253445002-db0902a3-4487-472e-b9d8-92087449105c.png)

## Requirements

- Neovim >= 0.8.0 if using any of the following plugins:
  - nvim-tree
  - bufferline
  - gitsigns
- Neovim >= 0.7.0 if using any of the following plugins:
  - nvim-web-devicons
  - which-key
- Neovim >= 0.5 if using any of the following plugins:
  - lualine
  - indent-blankline
- Nerd Fonts >= 2.3 if using nvim-web-devicons, bufferline.
- Git if using lualine, gitsigns.

## Run Script

- Bash, Zsh

  ```bash
  bash <(curl -fsSL 'https://raw.githubusercontent.com/Change-Maker/personalization/main/scripts/neovim/personalize_nvim.sh')
  ```

- Fish

  ```fish
  bash (curl -fsSL 'https://raw.githubusercontent.com/Change-Maker/personalization/main/scripts/neovim/personalize_nvim.sh' | psub)
  ```

### Script Arguments

- `-h, --help`: Show help messages.
- `-nc, --no-color`: Disable color on log messages.
- `-y, --yes`: Accept all options.

To show help messages:

- Bash, Zsh

  ```bash
  bash <(curl -fsSL URL) -h
  ```

- Fish

  ```fish
  bash (curl -fsSL URL | psub) -h
  ```

### Personalization Options

```text
[Configuration of Neovim]
> Would you like to navigate between windows (panes) by using Ctrl-[hjkl]?
  [y]es or [n]o (default: no): y
> Would you like to navigate tabs by using Tab and Shift-Tab?
  [y]es or [n]o (default: no): y
> Would you like to use rulers (column guides)?
  [y]es or [n]o (default: no): y
> Would you like to use the following key mappings for autocomplete menu?
  - Ctrl-j: open autocomplete menu
  - Ctrl-[jk]: select matches
  - Tab: accept current selected match
  [y]es or [n]o (default: no): y
> Would you like to prevent exiting when indenting?
  [y]es or [n]o (default: no): y

[Neovim Plugins]
> Would you like to install kanagawa - A dark color scheme?
  [y]es or [n]o (default: no): y
> Would you like to install vim-better-whitespace - Highlight trailing
  whitespaces?
  [y]es or [n]o (default: no): y
> Would you like to install lualine - A blazing fast and easy to configure
  neovim statusline?
  [y]es or [n]o (default: no): y
> Would you like to install nvim-tree - A file explorer tree?
  [y]es or [n]o (default: no): y
> Which side would you like to put the nvim-tree window?
   [l]eft or [r]ight (default: right):
> Would you like to install nvim-web-devicons - File icons?
  [y]es or [n]o (default: no): y
> Would you like to install bufferline - A snazzy buffer line (with tabpage
  integration)?
  [y]es or [n]o (default: no): y
> Would you like to install gitsigns - Git integration: signs, hunk actions,
  blame, etc.?
  [y]es or [n]o (default: no): y
> Would you like to install indent-blankline - Indentation guides?
  [y]es or [n]o (default: no): y
> Would you like to install hop - An EasyMotion-like plugin allowing you to jump
  anywhere in a document?
  [y]es or [n]o (default: no): y
> Would you like to install comment - Smart and powerful comment plugin?
  [y]es or [n]o (default: no): y
> Would you like to install which-key - A popup with possible key bindings of
  the command you started typing?
  [y]es or [n]o (default: no): y
```

## Usage

A full personalization (answer "yes" to every personalization options) has the following features:

### Neovim

- **Navigate between windows in Normal mode**
  - `Ctrl` + `h`: Navigate to window left of current one.
  - `Ctrl` + `j`: Navigate to window below of current one.
  - `Ctrl` + `k`: Navigate to window above of current one.
  - `Ctrl` + `l`: Navigate to window right of current one.

- **Navigate tab pages in Normal mode**
  - `Tab`: Navigate to next tab page.
  - `Shift` + `Tab`: Navigate to previous tab page.

- **Rulers (Column guides)**

  Mark columns with slightly light background:
  - C, Cpp: 121 column.
  - Git-commit: 51 and 73~999 columns.
  - JavaScript: 101 column.
  - Python: 73 and 80~999 columns.
  - Others: 101 and 121~999 columns.

  ![rulers](https://user-images.githubusercontent.com/18575008/253169633-7ac8a721-719a-42a1-bbd8-2906d378f22b.png)

- **Popup menu keymappings in Insert mode**

  - When the popup menu is closing:
    - `Ctrl` + `j`: Open keyword completion popup menu.

  - When the popup menu is opening:
    - `Ctrl` + `j`: Select next match in popup menu.
    - `Ctrl` + `k`: Select previous match in popup menu.
    - `Tab`: Accept current selected match and close popup menu.
    - `Ctrl` + `e`: Discard completion and close popup menu.

- **Prevent exiting Visual mode while indenting**

  It will not exiting Visual mode when you doing indentation with `<` and `>`
  until pressing `Esc`.

### Neovim Plugins

The configuration of plugins is written in `$HOME/.config/nvim/plugin_settings.lua`.

- [**kanagawa**](https://github.com/rebelot/kanagawa.nvim)

  ![kanagawa_official](https://user-images.githubusercontent.com/36300441/222913073-22b95f11-8c08-4b2b-867c-19072c921de1.png)

- [**vim-better-whitespace**](https://github.com/ntpeters/vim-better-whitespace)

  To change the highlight color of trailing whitespaces:

  ```lua
  vim.api.nvim_set_hl(0, "ExtraWhitespace", { ctermbg = 88, bg = "#8B0000" })
  ```

  ![vim-better-whitespace](https://user-images.githubusercontent.com/18575008/253169661-b8869a54-7639-45c2-a06a-303af1eb9230.png)

- [**lualine**](https://github.com/nvim-lualine/lualine.nvim)

  Git is required.

  To change the theme:

  ```lua
  require("lualine").setup({
    options = { theme = "onedark" },
  })
  ```

  ![lualine](https://user-images.githubusercontent.com/18575008/257671556-0c26e407-2c32-46fa-a588-07b5454572af.png)

- [**nvim-tree**](https://github.com/nvim-tree/nvim-tree.lua)

  Key mappings (Normal mode):
  - Global
    - `Ctrl` + `b`: Toggle NvimTree.
  - In NvimTree
    - `>`: Run a command.
    - `.`: Toggle dotfiles (whose filename start with `.`).
    - `h`: Collapse parent directory.
    - `Shift` + `h`: Collapse all directories.
    - `l`: Open/Edit file at current cursor line.
    - `s`: Open in split horizontally.
    - `v`: Open in split vertically.
    - `y`: Copy.
    - `x`: Cut.
    - `p`: Paste.
    - `d`: Delete.
    - `c`: Copy name.
    - `?`: Open NvimTree help window.

  ![nvim-tree](https://user-images.githubusercontent.com/18575008/253169773-6b0c1ac0-3723-4f97-857b-553780058667.png)

- [**nvim-web-devicons**](https://github.com/nvim-tree/nvim-web-devicons)

  [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts) is required.

  ![nvim-web-devicons](https://user-images.githubusercontent.com/18575008/253169801-f8004435-28c6-4962-a341-c023de7db5a0.png)

- [**bufferline**](https://github.com/akinsho/bufferline.nvim)

  [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts) is required.

  ![bufferline](https://user-images.githubusercontent.com/18575008/253169832-3d8241de-616a-4819-afe8-be283b1e9a71.png)

- [**gitsigns**](https://github.com/lewis6991/gitsigns.nvim)

  Git is required.

  ![gitsigns](https://user-images.githubusercontent.com/18575008/253169905-016cb1e9-83a9-4056-90f2-06c1520666df.png)

- [**indent-blankline**](https://github.com/lukas-reineke/indent-blankline.nvim)

  ![indent-blankline](https://user-images.githubusercontent.com/18575008/253169929-f94eb789-2608-4b5e-b6ff-a74726a18cde.png)

- [**hop**](https://github.com/phaazon/hop.nvim)

  The default key of `<Leader>` is `\`.

  Key sequences (Normal mode):
  - `<Leader><Leader>s`: Search 1 character.
  - `<Leader><Leader>S`: Search 2 characters over-windows.
  - `<Leader><Leader>/`: Search N characters.

  ![hop search 2 chars overwin](https://user-images.githubusercontent.com/18575008/253169946-735d6129-aeb6-48b7-abb5-29303750739c.png)

- [**comment**](https://github.com/numToStr/Comment.nvim)

  Use `Ctrl` + `/` to toggle line comment in Normal mode and Visual mode.

- [**which-key**](https://github.com/folke/which-key.nvim)

  Use `<Space>` to trigger which-key menu.

  ![which-key](https://user-images.githubusercontent.com/18575008/253169963-ee4c6608-b67f-485d-9122-5770397f187b.png)

## Todo List

- [x] Convert configuration from Vim script to lua.
- [ ] Verify Neovim carefully.
- [ ] Check Neovim version before personalizing.
- [ ] Setup [todo-comments](https://github.com/folke/todo-comments.nvim) plugin.
- [ ] Setup [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) plugin.
- [ ] Setup [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) plugin.
- [ ] Setup [lazy.nvim](https://github.com/folke/lazy.nvim) plugin.
- [ ] Setup [rest.nvim](https://github.com/rest-nvim/rest.nvim) plugin.
- [ ] Setup [nvim-dap](https://github.com/mfussenegger/nvim-dap) plugin.
- [ ] Setup [nvim-notify](https://github.com/rcarriga/nvim-notify) plugin.
- [ ] Pick [smartcolumn.nvim](https://github.com/m4xshen/smartcolumn.nvim) plugin
  or [deadcolumn.nvim](https://github.com/Bekaboo/deadcolumn.nvim) plugin.

## Known Issues

- `cursorline` is set to off after `:HopPattern`.

  - Steps to reproduce:

    1. Run `:HopPattern` in Neovim.
    2. Type anything and press `Enter`.

  ![cursorline highlight issuse](https://user-images.githubusercontent.com/18575008/253169995-1077a174-0e89-4494-8a1b-6941d6f1d0ee.png)

- It raises an error if quits editor without saving when NvimTree is opening.

  - Steps to reproduce:

    1. Open a file and modify it (don't save it).
    2. Open NvimTree (run `:NvimTreeOpen`).
    3. Close the file without saving (run `:q`).

  ![nvim-tree auto close issue](https://user-images.githubusercontent.com/18575008/253170006-eaaacaef-3639-4e83-9d1f-bb8ecb5acb0a.png)

- It raises an error if runs `:HopWordAC` or `:HopWordBC` on a blank line.

  You could check [this issue](https://github.com/phaazon/hop.nvim/issues/361) for more information.

  - Steps to reproduce:

    1. Open a file and move cursor to a blank line.
    2. Run `:HopWordAC` or `:HopWordBC`. Or press `\\w` or `\\b` key sequences
      if you are using **hop.nvim** with my configuration.

  ![hop word issue](https://user-images.githubusercontent.com/18575008/254177591-9510c317-f832-4243-a6d4-df6c8bcc7c14.png)
