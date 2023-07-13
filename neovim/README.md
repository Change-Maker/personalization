# Neovim Customization

![overview](https://user-images.githubusercontent.com/18575008/253169470-79677a68-2a57-488d-a712-1a8751dc7e45.png)

![overview easymotion](https://user-images.githubusercontent.com/18575008/253169478-ada67f69-c041-4eed-ab50-8edcec9c049b.png)

## Requirements

- Neovim >= 0.8.0 if use any of the following plugins:
  - nvim-tree
  - bufferline
  - gitsigns
- Neovim >= 0.7.0 if use any of the following plugins:
  - nvim-web-devicons
  - which-key
- Neovim >= 0.5 if use any of the following plugins:
  - lualine
  - indent-blankline
- Nerd Fonts >= 2.3 if use nvim-web-devicons, bufferline

## Run Customization

- Bash, Zsh

  ```bash
  bash <(curl -fsSL 'https://raw.githubusercontent.com/Change-Maker/customization/main/neovim/customize_neovim.sh')
  ```

- Fish

  ```fish
  bash (curl -fsSL 'https://raw.githubusercontent.com/Change-Maker/customization/main/neovim/customize_neovim.sh' | psub)
  ```

### Script Arguments

- `-h, --help`: Show help messages.
- `-nc, --no-color`: Disable color on log messages.
- `-y, --yes`: Accept all customization options.

To show help message:

- Bash, Zsh

  ```bash
  bash <(curl -fsSL URL) -h
  ```

- Fish

  ```fish
  bash (curl -fsSL URL | psub) -h
  ```

### Customization Options

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
> Would you like to install onedark - A dark color scheme?
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
> Would you like to install which-key - A popup with possible key bindings of
  the command you started typing?
  [y]es or [n]o (default: no): y
```

## Usage

A full customization (answer "yes" to every customization options) has the following features:

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

- [**vim-better-whitespace**](https://github.com/ntpeters/vim-better-whitespace)

  To change the highlight color of trailing whitespaces:

  ```lua
  vim.api.nvim_set_hl(0, "ExtraWhitespace", { ctermbg = 88, bg = "#8B0000" })
  ```

  ![vim-better-whitespace](https://user-images.githubusercontent.com/18575008/253169661-b8869a54-7639-45c2-a06a-303af1eb9230.png)

- [**lualine**](https://github.com/nvim-lualine/lualine.nvim)

  To change the theme:

  ```lua
  require("lualine").setup({
    options = { theme = "onedark" },
  })
  ```

  ![lualine](https://user-images.githubusercontent.com/18575008/253169744-0bcf3f50-6232-4570-af46-9dd4f9b0b651.png)

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
    - `c`: Copy.
    - `x`: Cut.
    - `p`: Paste.
    - `d`: Delete.
    - `?`: Open NvimTree help window.

  ![nvim-tree](https://user-images.githubusercontent.com/18575008/253169773-6b0c1ac0-3723-4f97-857b-553780058667.png)

- [**nvim-web-devicons**](https://github.com/nvim-tree/nvim-web-devicons)

  [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts) is required.

  ![nvim-web-devicons](https://user-images.githubusercontent.com/18575008/253169801-f8004435-28c6-4962-a341-c023de7db5a0.png)

- [**bufferline**](https://github.com/akinsho/bufferline.nvim)

  [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts) is required.

  ![bufferline](https://user-images.githubusercontent.com/18575008/253169832-3d8241de-616a-4819-afe8-be283b1e9a71.png)

- [**gitsigns**](https://github.com/lewis6991/gitsigns.nvim)

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

- [**which-key**](https://github.com/folke/which-key.nvim)

  Use `<Space>` to trigger which-key menu.

  ![which-key](https://user-images.githubusercontent.com/18575008/253169963-ee4c6608-b67f-485d-9122-5770397f187b.png)

## Known Issues

- `cursorline` is set to off after `:HopPattern`.

  - Steps to reproduce:

    1. Run `:HopPattern` in Neovim.
    2. Type anything and press `Enter`.

  ![cursorline highlight issuse](https://user-images.githubusercontent.com/18575008/253169995-1077a174-0e89-4494-8a1b-6941d6f1d0ee.png)

- It raise an error if you quit editor without saving when NvimTree is opening.

  - Steps to reproduce:

    1. Open a file and modify it (don't save it).
    2. Open NvimTree (run `:NvimTreeOpen`).
    3. Close the file without saving (run `:q`).

  ![nvim-tree auto close issue](https://user-images.githubusercontent.com/18575008/253170006-eaaacaef-3639-4e83-9d1f-bb8ecb5acb0a.png)
