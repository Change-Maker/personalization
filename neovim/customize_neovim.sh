#!/usr/bin/env bash

set -eo pipefail

readonly SELF="$(basename $0)"  # The filename of this script.
readonly OS="$(uname -s)"

# Verify OS.
if [ "$OS" = "Linux" ]; then
  if [ -f "/etc/os-release" ]; then
    if [ "$(awk -F= '/^NAME/{print $2}' /etc/os-release)" != '"Ubuntu"' ]; then
      echo "This script only supports Ubuntu now."
      exit 1
    fi
  else
    echo "Couldn't get distro of Linux: 'etc/os-release' not found"
    echo "Maybe this script doesn't support your OS."
    exit 1
  fi
else
  echo "This script only supports Linux now."
  exit 1
fi

# Shell colors.
readonly NOCOLOR="\033[0m"
readonly RED="\033[0;31m"
readonly GREEN="\033[0;32m"
readonly YELLOW="\033[0;33m"
readonly BLUE="\033[0;34m"
# Bold.
readonly BNOCOLOR="\033[1m"
readonly BRED="\033[1;31m"
readonly BGREEN="\033[1;32m"
readonly BYELLOW="\033[1;33m"
readonly BBLUE="\033[1;34m"

declare -xr XDG_DATA_HOME="${XDG_DATA_HOME:-"$HOME/.local/share"}"
declare -xr XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-"$HOME/.config"}"
declare -xr XDG_CACHE_HOME="${XDG_CACHE_HOME:-"$HOME/.cache"}"

readonly NVIM_RELEASE_URL='https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz'
# Neovim folders.
readonly NVIM_RELEASE_DIR="$XDG_DATA_HOME/nvim"
readonly NVIM_RELEASE_BACKUP="$XDG_DATA_HOME/nvim.backup"
readonly NVIM_CONFIG_DIR="$XDG_CONFIG_HOME/nvim"
readonly NVIM_CONFIG_BACKUP="$XDG_CONFIG_HOME/nvim.backup"
readonly NVIM_CONFIG="$NVIM_CONFIG_DIR/init.vim"
readonly NVIM_KEYMAPPING="$NVIM_CONFIG_DIR/keymappings.lua"
readonly PLUGIN_CONFIG="$NVIM_CONFIG_DIR/plugin_settings.lua"
readonly PLUGIN_START_DIR="$NVIM_CONFIG_DIR/pack/myplugins/start"
readonly PLUGIN_OPT_DIR="$NVIM_CONFIG_DIR/pack/myplugins/opt"
readonly NVIM_FTPLUGIN_DIR="$NVIM_CONFIG_DIR/ftplugin"
readonly FTPLUGIN_C="$NVIM_FTPLUGIN_DIR/c.vim"
readonly FTPLUGIN_GIT="$NVIM_FTPLUGIN_DIR/gitcommit.vim"
readonly FTPLUGIN_JAVASCRIPT="$NVIM_FTPLUGIN_DIR/javascript.vim"
readonly FTPLUGIN_PYTHON="$NVIM_FTPLUGIN_DIR/python.vim"

# Neovim plugins.
readonly KANAGAWA='kanagawa'
readonly BETTER_WHITESPACE='vim-better-whitespace'
readonly LUALINE='lualine'
readonly NVIMTREE='nvim-tree'
readonly DEVICONS='nvim-web-devicons'
readonly BUFFERLINE='bufferline'
readonly GITSIGNS='gitsigns'
readonly INDENT_BLANKLINE='indent-blankline'
readonly HOP='hop'
readonly WHICHKEY='which-key'
# TODO: The following plugins are not added into customization.
readonly COMMENT='comment'
readonly TODO_COMMENTS='todo-comments'
readonly TOGGLETERM='toggleterm'

declare -rA GIT_URL=(
  ["$KANAGAWA"]='https://github.com/rebelot/kanagawa.nvim'
  ["$BETTER_WHITESPACE"]='https://github.com/ntpeters/vim-better-whitespace.git'
  ["$LUALINE"]='https://github.com/nvim-lualine/lualine.nvim'
  ["$NVIMTREE"]='https://github.com/nvim-tree/nvim-tree.lua'
  ["$DEVICONS"]='https://github.com/nvim-tree/nvim-web-devicons'
  ["$BUFFERLINE"]='https://github.com/akinsho/bufferline.nvim'
  ["$GITSIGNS"]='https://github.com/lewis6991/gitsigns.nvim'
  ["$INDENT_BLANKLINE"]='https://github.com/lukas-reineke/indent-blankline.nvim'
  ["$HOP"]='https://github.com/phaazon/hop.nvim'
  ["$WHICHKEY"]='https://github.com/folke/which-key.nvim'
  ["$COMMENT"]='https://github.com/numToStr/Comment.nvim'
  ["$TODO_COMMENTS"]='https://github.com/folke/todo-comments.nvim'
  ["$TOGGLETERM"]='https://github.com/akinsho/toggleterm.nvim'
)

declare -rA URL=(
  ["$KANAGAWA"]='https://github.com/rebelot/kanagawa.nvim/tarball/master'
  ["$BETTER_WHITESPACE"]='https://github.com/ntpeters/vim-better-whitespace/tarball/master'
  ["$LUALINE"]='https://github.com/nvim-lualine/lualine.nvim/tarball/master'
  ["$NVIMTREE"]='https://github.com/nvim-tree/nvim-tree.lua/tarball/master'
  ["$DEVICONS"]='https://github.com/nvim-tree/nvim-web-devicons/tarball/master'
  ["$BUFFERLINE"]='https://github.com/akinsho/bufferline.nvim/tarball/main'
  ["$GITSIGNS"]='https://github.com/lewis6991/gitsigns.nvim/tarball/main'
  ["$INDENT_BLANKLINE"]='https://github.com/lukas-reineke/indent-blankline.nvim/tarball/master'
  ["$HOP"]='https://github.com/phaazon/hop.nvim/tarball/master'
  ["$WHICHKEY"]='https://github.com/folke/which-key.nvim/tarball/main'
  ["$COMMENT"]='https://github.com/numToStr/Comment.nvim/tarball/master'
  ["$TODO_COMMENTS"]='https://github.com/folke/todo-comments.nvim/tarball/main'
  ["$TOGGLETERM"]='https://github.com/akinsho/toggleterm.nvim/tarball/main'
)

declare disable_color=false
declare use_sudo=false
declare accept_all=false
declare nvim_plugin_installer=""
declare need_installing_nvim=false
declare need_installing_spc=false  # spc means software-properties-common.
declare need_adding_nvim_path=false
declare shell=""
declare shellconfig=""

# Neovim configuration options.
navigate_windows_keymapping=false
navigate_tabs_keymapping=false
use_rulers=false
autocomplete_menu_keymapping=false
dont_exit_when_indenting=false
nvimtree_side=""

declare -A dependency=()
declare -a ppas=()
declare -A nvim_plugin=()


function show_help() {
  echo "Usage: ./customize_neovim.sh [<opts>]"
  echo "Options:"
  echo "    -h, --help"
  echo "        Show help messages."
  echo "    -nc, --no-color"
  echo "        Disable color on log messages."
  echo "    -y, --yes"
  echo "        Accept all customization options."
  echo
}


function parse_cli_args() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      "-h" | "--help")
        show_help
        exit 0
        ;;
      "-nc" | "--no-color")
        disable_color=true
        shift
        ;;
      "-y" | "--yes")
        accept_all=true
        shift
        ;;
      *)
        echo "Unknow options: $1"
        show_help
        exit 1
        ;;
    esac
  done
}


function log() {
  local msg="$1"
  local level="${2:-INFO}"
  if [ "$disable_color" = true ]; then
    echo -e "[$level] $msg"
  else
    case $level in
      "WARNING")
        echo -e "${BYELLOW}[$level]${YELLOW} $msg${NOCOLOR}"
        ;;
      "ERROR")
        echo -e "${BRED}[$level]${RED} $msg${NOCOLOR}"
        ;;
      "DEBUG")
        echo -e "${BBLUE}[$level]${BLUE} $msg${NOCOLOR}"
        ;;
      *)
        echo -e "${BGREEN}[$level]${GREEN} $msg${NOCOLOR}"
        ;;
    esac
  fi
}


function confirm() {
  local question="$1"
  local is_required="${2:-false}"

  if [ "$is_required" = false ] && [ "$accept_all" = true ]; then
    return 0
  fi

  while true; do
    if [ "$disable_color" = true ]; then
      echo "> $question"
    else
      echo -e "${BNOCOLOR}> $question${NOCOLOR}"
    fi
    read -p "  [y]es or [n]o (default: no): " -r answer
    case "${answer,,}" in
      "y" | "yes")
        return 0  # 0 is true.
        ;;
      "n" | "no" | *[[:blank:]]* | "")
        return 1  # 1 is false.
        ;;
      *)
        log "Please answer [y]es or [n]o." "ERROR"
        ;;
    esac
  done
}


function confirm_without_default() {
  local question="$1"
  while true; do
    if [ "$disable_color" = true ]; then
      echo "> $question"
    else
      echo -e "${BNOCOLOR}> $question${NOCOLOR}"
    fi
    read -p "  [y]es or [n]o: " -r answer
    case "${answer,,}" in
      "y" | "yes")
        return 0  # 0 is true.
        ;;
      "n" | "no")
        return 1  # 1 is false.
        ;;
      *)
        log "Please answer [y]es or [n]o." "ERROR"
        ;;
    esac
  done
}


# Get the latest release version of the repository on GitHub.
# Refer to: https://gist.github.com/lukechilds/a83e1d7127b78fef38c2914c4ececc3c
function get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" |  # Get latest release from GitHub api
    grep '"tag_name":' |  # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'  # Pluck JSON value
}


function confirm_sudo() {
  echo
  if confirm "Would you like to accept using sudo in this customization?" true; then
    if ! command -v sudo &> /dev/null; then
      log "Please install and setup sudo first if you accept using sudo in this customization" "ERROR"
      exit 1
    fi
    use_sudo=true
    log "Install dependencies with sudo"
  else
    log "Install dependencies without sudo"
  fi
  echo
}


function verify_add_apt_repository() {
  if ! command -v add-apt-repository &> /dev/null; then
    need_installing_spc=true
  fi
}


function verify_nvim_ppa() {
  if ! grep -sq '^deb .*neovim-ppa/stable' /etc/apt/sources.list /etc/apt/sources.list.d/*; then
    ppas+=("neovim")
    verify_add_apt_repository
  fi
}


function path_contains_nvim() {
  if [[ ":$PATH:" == *":$NVIM_RELEASE_DIR/bin:"* ]]; then
    return 0
  else
    return 1
  fi
}


function verify_curl() {
  if ! command -v curl &> /dev/null; then
    if [ -z "${dependency['curl']}" ]; then
      dependency["curl"]=1
    fi
  fi
}


function verify_nvim() {
  # TODO: Verify Neovim version.
  if ! command -v nvim &> /dev/null; then
    need_installing_nvim=true
  else
    if path_contains_nvim && [ -f "$NVIM_RELEASE_DIR/bin/nvim" ]; then
      need_installing_nvim=true
    fi
  fi

  if [ "$need_installing_nvim" = true ] && [ -z "${dependency['curl']}" ]; then
    verify_curl
  fi
}


function confirm_adding_nvim_path() {
  if confirm "Would you like to add '$NVIM_RELEASE_DIR/bin' into PATH?"; then
    need_adding_nvim_path=true

    local question="> Which shell do you use?"
    while [ -z "$shell" ]; do
      if [ "$disable_color" = true ]; then
        echo $question
      else
        echo -e "${BNOCOLOR}$question${NOCOLOR}"
      fi
      read -p "  bash or zsh or fish (q to discard): " -r answer

      case "${answer,,}" in  # To lower case.
        "bash")
          shell="bash"
          shellconfig="$HOME/.bashrc"
          ;;
        "zsh")
          shell="zsh"
          shellconfig="${ZDOTDIR:-$HOME}/.zshrc"
          ;;
        "fish")
          shell="fish"
          shellconfig="$HOME/.config/fish/conf.d/nvim.fish"
          ;;
        "q" | "quit")
          need_adding_nvim_path=false
          return 0
          ;;
        *)
          log "Invalid answer: $answer" "ERROR"
          ;;
      esac
    done

  fi
}


function confirm_nvim_config() {
  if [ "$accept_all" = false ]; then
    if [ "$disable_color" = true ]; then
      echo '[Configuration of Neovim]'
    else
      echo -e "${BNOCOLOR}[Configuration of Neovim]${NOCOLOR}"
    fi
  fi

  if confirm "Would you like to navigate between windows (panes) by using Ctrl-[hjkl]?"; then
    navigate_windows_keymapping=true
  fi

  if confirm "Would you like to navigate tabs by using Tab and Shift-Tab?"; then
    navigate_tabs_keymapping=true
  fi

  if confirm "Would you like to use rulers (column guides)?"; then
    use_rulers=true
  fi

  if confirm "Would you like to use the following key mappings for autocomplete menu?
  - Ctrl-j: open autocomplete menu
  - Ctrl-[jk]: select matches
  - Tab: accept current selected match"; then
    autocomplete_menu_keymapping=true
  fi

  if confirm "Would you like to prevent exiting when indenting?"; then
    dont_exit_when_indenting=true
  fi
}


function confirm_nvim_plugin() {
  if [ "$accept_all" = false ]; then
    if [ "$disable_color" = true ]; then
      echo '[Neovim Plugins]'
    else
      echo -e "${BNOCOLOR}[Neovim Plugins]${NOCOLOR}"
    fi
  fi

  if confirm "Would you like to install $KANAGAWA - A dark color scheme?"; then
    nvim_plugin["$KANAGAWA"]=1
  fi

  if confirm "Would you like to install $BETTER_WHITESPACE - Highlight trailing whitespaces?"; then
    nvim_plugin["$BETTER_WHITESPACE"]=1
  fi

  if confirm "Would you like to install $LUALINE - A blazing fast and easy to configure neovim statusline?"; then
    nvim_plugin["$LUALINE"]=1
  fi

  if confirm "Would you like to install $NVIMTREE - A file explorer tree?"; then
    nvim_plugin["$NVIMTREE"]=1

    local question="> Which side would you like to put the $NVIMTREE window?"
    while [ -z "$nvimtree_side" ]; do
      if [ "$disable_color" = true ]; then
        echo $question
      else
        echo -e "${BNOCOLOR}$question${NOCOLOR}"
      fi
      read -p "  [l]eft or [r]ight (default: right): " -r answer

      case "${answer,,}" in  # To lower case.
        "right" | "r" | *[[:blank:]]* | "")
          nvimtree_side="right"
          ;;
        "left" | "l")
          nvimtree_side="left"
          ;;
        *)
          log "Invalid answer: $answer" "ERROR"
          ;;
      esac
    done

  fi

  if confirm "Would you like to install $DEVICONS - File icons?"; then
    nvim_plugin["$DEVICONS"]=1
  fi

  if confirm "Would you like to install $BUFFERLINE - A snazzy buffer line?"; then
    nvim_plugin["$BUFFERLINE"]=1
  fi

  if confirm "Would you like to install $GITSIGNS - Git integration: signs, hunk actions, blame, etc.?"; then
    nvim_plugin["$GITSIGNS"]=1
  fi

  if confirm "Would you like to install $INDENT_BLANKLINE - Indentation guides?"; then
    nvim_plugin["$INDENT_BLANKLINE"]=1
  fi

  if confirm "Would you like to install $HOP - An EasyMotion-like plugin allowing you to jump anywhere in a document?"; then
    nvim_plugin["$HOP"]=1
  fi

  if confirm "Would you like to install $WHICHKEY - A popup with possible key bindings of the command you started typing?"; then
    nvim_plugin["$WHICHKEY"]=1
  fi
}


function verify_git_ppa() {
  if ! grep -sq '^deb .*git-core/ppa' /etc/apt/sources.list /etc/apt/sources.list.d/*; then
    ppas+=("git")
    verify_add_apt_repository
  fi
}


function verify_git() {
  if ! command -v git &> /dev/null; then
    dependency["git"]=1
    verify_git_ppa
  fi
}


function verify_wget() {
  if ! command -v wget &> /dev/null; then
    dependency["wget"]=1
  fi
}


function confirm_nvim_plugin_installer() {
  echo
  local question="> Which tool would you like to use to install Neovim plugins?"
  while [ -z "$nvim_plugin_installer" ]; do
    if [ "$disable_color" = true ]; then
      echo $question
    else
      echo -e "${BNOCOLOR}$question${NOCOLOR}"
    fi
    read -p "  git, wget or curl (default: git): " -r answer

    case "${answer,,}" in  # To lower case.
      "git" | *[[:blank:]]* | "")
        verify_git
        nvim_plugin_installer="git"
        ;;
      "wget")
        verify_wget
        nvim_plugin_installer="wget"
        ;;
      "curl")
        verify_curl
        nvim_plugin_installer="curl"
        ;;
      *)
        log "Invalid answer: $answer" "ERROR"
        ;;
    esac
  done
}


function confirm_continue() {
  local title="This customization will do the following things:"
  echo
  if [ "$disable_color" = true ]; then
    echo "$title"
  else
    echo -e "${BNOCOLOR}$title${NOCOLOR}"
  fi

  if [ "$need_installing_spc" = true ]; then
    echo "  - Install the package for adding PPAs: software-properties-common"
  fi
  if [ "${#ppas[@]}" -ne 0 ]; then
    echo "  - Add PPAs: ${ppas[*]}"
  fi
  if [ "${#dependency[@]}" -ne 0 ]; then
    echo "  - Install dependencies: ${!dependency[*]}"
  fi

  if [ "$need_installing_nvim" = true ]; then
    if [ -d "$NVIM_RELEASE_DIR" ] && [ -d "$NVIM_RELEASE_BACKUP" ]; then
      echo "  - Remove Neovim release backup folder: rm -rf $NVIM_RELEASE_BACKUP"
    fi
    if [ -d "$NVIM_RELEASE_DIR" ]; then
      echo "  - Backup Neovim release folder: mv $NVIM_RELEASE_DIR $NVIM_RELEASE_BACKUP"
    fi
    echo "  - Create Neovim release folder: $NVIM_RELEASE_DIR"
    echo "  - Install Neovim from GitHub release."
  fi

  if [ -d "$NVIM_CONFIG_DIR" ] && [ -d "$NVIM_CONFIG_BACKUP" ]; then
    echo "  - Remove Neovim config backup folder: rm -rf $NVIM_CONFIG_BACKUP"
  fi
  if [ -d "$NVIM_CONFIG_DIR" ]; then
    echo "  - Backup Neovim config folder: mv $NVIM_CONFIG_DIR $NVIM_CONFIG_BACKUP"
  fi
  echo "  - Create Neovim config folder: $NVIM_CONFIG_DIR"
  echo "  - Create configuration files:"
  echo "    - $NVIM_CONFIG"
  echo "    - $NVIM_KEYMAPPING"
  echo "    - $PLUGIN_CONFIG"
  echo "    - $FTPLUGIN_C"
  echo "    - $FTPLUGIN_GIT"
  echo "    - $FTPLUGIN_JAVASCRIPT"
  echo "    - $FTPLUGIN_PYTHON"
  if [ "${#nvim_plugin[@]}" -ne 0 ]; then
    echo "  - Install Neovim plugins: ${!nvim_plugin[*]}"
  fi
  if [ "$need_adding_nvim_path" = true ]; then
    echo "  - Add '$NVIM_RELEASE_DIR/bin' into PATH environment variable."
  fi

  if ! confirm_without_default "Would you like to run this customization?"; then
    exit 0
  fi
}


function apt_get_update() {
  if [ "$use_sudo" = true ]; then
    sudo apt-get update
  else
    apt-get update
  fi
  log "Package infromation updated."
}


function install_spc() {
  if [ "$use_sudo" = true ]; then
    sudo DEBIAN_FRONTEND=noninteractive apt-get install --yes software-properties-common
  else
    DEBIAN_FRONTEND=noninteractive apt-get install --yes software-properties-common
  fi
  log "software-properties-common installed."
}


function add_nvim_ppa() {
  if [ "$use_sudo" = true ]; then
    sudo add-apt-repository --yes --no-update ppa:neovim-ppa/stable
  else
    add-apt-repository --yes --no-update ppa:neovim-ppa/stable
  fi
  log "ppa:neovim-ppa/stable added."
}


function add_git_ppa() {
  if [ "$use_sudo" = true ]; then
    sudo add-apt-repository --yes --no-update ppa:git-core/ppa
  else
    add-apt-repository --yes --no-update ppa:git-core/ppa
  fi
  log "ppa:git-core/ppa added."
}


function add_ppas() {
  for ppa in "${ppas[@]}"; do
    case "$ppa" in
      "neovim")
        add_nvim_ppa
        ;;
      "git")
        add_git_ppa
        ;;
    esac
  done
  apt_get_update
}


function install_dependencies() {
  if [ "$use_sudo" = true ]; then
    DEBIAN_FRONTEND=noninteractive command sudo apt-get install --yes "${!dependency[@]}"
  else
    DEBIAN_FRONTEND=noninteractive command apt-get install --yes "${!dependency[@]}"
  fi
  log "Dependencies installed: ${!dependency[*]}"
}


function remove_nvim_release_backup() {
  rm -rf "$NVIM_RELEASE_BACKUP"
  log "Neovim release backup folder removed: $NVIM_RELEASE_BACKUP"
}


function backup_nvim_release_dir() {
  mv "$NVIM_RELEASE_DIR" "$NVIM_RELEASE_BACKUP"
  log "Neovim release folder backed up: $NVIM_RELEASE_DIR -> $NVIM_RELEASE_BACKUP"
}


function remove_nvim_config_backup() {
  rm -rf "$NVIM_CONFIG_BACKUP"
  log "Neovim config backup folder removed: $NVIM_CONFIG_BACKUP"
}


function backup_nvim_config_dir() {
  mv "$NVIM_CONFIG_DIR" "$NVIM_CONFIG_BACKUP"
  log "Neovim config folder backed up: $NVIM_CONFIG_DIR -> $NVIM_CONFIG_BACKUP"
}


function create_nvim_release_dir() {
  mkdir -p "$NVIM_RELEASE_DIR"
  log "Neovim release folder created: $NVIM_RELEASE_DIR"
}


function install_nvim_from_github() {
  cd "$NVIM_RELEASE_DIR"
  local neovim_targz='neovim.tar.gz'
  curl -LJ "$NVIM_RELEASE_URL" -o "$neovim_targz"
  tar -xzf "$neovim_targz" --strip-components=1
  rm "$neovim_targz"
  if ! path_contains_nvim; then
    export PATH="$NVIM_RELEASE_DIR/bin:$PATH"
  fi
  log "Neovim installed."
}


function create_nvim_config_dir() {
  mkdir -p "$NVIM_CONFIG_DIR" "$PLUGIN_START_DIR" "$PLUGIN_OPT_DIR" "$NVIM_FTPLUGIN_DIR"
  log "Neovim config folder created: $NVIM_CONFIG_DIR"
}


function create_configs() {
  touch "$NVIM_CONFIG"
  touch "$NVIM_KEYMAPPING"
  touch "$PLUGIN_CONFIG"
  touch "$FTPLUGIN_C"
  touch "$FTPLUGIN_GIT"
  touch "$FTPLUGIN_JAVASCRIPT"
  touch "$FTPLUGIN_PYTHON"
  log "Empty configuration files created:
         - $NVIM_CONFIG
         - $NVIM_KEYMAPPING
         - $PLUGIN_CONFIG
         - $FTPLUGIN_C
         - $FTPLUGIN_GIT
         - $FTPLUGIN_JAVASCRIPT
         - $FTPLUGIN_PYTHON"
}


function write_nvim_config() {
  echo "$1" >> "$NVIM_CONFIG"
}


function config_nvim_settings() {
  # TODO: Convert vim script into lua.
  if [ -n "${nvim_plugin[$NVIMTREE]}" ]; then
    write_nvim_config '""" Disable netrw.'
    write_nvim_config 'let g:loaded_netrw = 1'
    write_nvim_config 'let g:loaded_netrwPlugin = 1'
    write_nvim_config ''
  fi
  write_nvim_config '""" Colorscheme.'
  write_nvim_config '""" You could get the list of built-in colorschemes by running:'
  write_nvim_config "\"\"\" \`ls \$VIMRUNTIME/colors | grep '.vim'\`"
  write_nvim_config "\"\"\" \$VIMRUNTIME is something like '/usr/share/nvim/runtime'."
  write_nvim_config "\"\"\" Run \`:echo \$VIMRUNTIME\` in Neovim to get \$VIMRUNTIME."
  write_nvim_config 'set termguicolors'
  if [ -z "${nvim_plugin[$KANAGAWA]}" ]; then
    write_nvim_config 'color desert'
  fi
  write_nvim_config ''

  write_nvim_config '""" Enable syntax.'
  write_nvim_config 'syntax on'
  write_nvim_config ''

  write_nvim_config '""" Disable compatible with vi.'
  write_nvim_config 'set nocompatible'
  write_nvim_config ''

  write_nvim_config '""" Enable line number.'
  write_nvim_config 'set number'
  write_nvim_config ''

  write_nvim_config '""" Enable mouse.'
  write_nvim_config 'set mouse=a'
  write_nvim_config ''

  write_nvim_config '""" Check filetype and indent of files automatically.'
  write_nvim_config 'filetype plugin indent on'
  write_nvim_config ''

  write_nvim_config '""" Setup the size of actual tab characters in the buffer.'
  write_nvim_config 'set tabstop=2'
  write_nvim_config ''

  write_nvim_config '""" Setup the number of whitespaces inserted when hitting the tab key.'
  write_nvim_config 'set softtabstop=2'
  write_nvim_config ''

  write_nvim_config '""" Setup the size of indents.'
  write_nvim_config 'set shiftwidth=2'
  write_nvim_config ''

  write_nvim_config "\"\"\" 'cindent' is based on 'smartindent'."
  write_nvim_config "\"\"\" 'smartindent' is based on 'autoindent'."
  write_nvim_config 'set cindent'
  write_nvim_config ''

  write_nvim_config '""" Enable insert whitespaces when passing Tab.'
  write_nvim_config 'set expandtab'
  write_nvim_config ''

  write_nvim_config "\"\"\" '·' symbol need utf-8 encoding."
  write_nvim_config 'set encoding=utf-8'
  write_nvim_config ''

  if [ -z "${nvim_plugin[$BETTER_WHITESPACE]}" ]; then
    write_nvim_config '""" Display all trailing whitespaces.'
    write_nvim_config 'set list'
    write_nvim_config 'set listchars=trail:·'
    write_nvim_config ''
  fi

  write_nvim_config '""" hlsearch enable highlight of searching result.'
  write_nvim_config 'set hlsearch'
  write_nvim_config '""" Highlight searching result when typing.'
  write_nvim_config 'set incsearch'
  write_nvim_config ''

  write_nvim_config '""" Make horizontal split default to below.'
  write_nvim_config 'set splitbelow'
  write_nvim_config '""" Make vertical split default to right.'
  write_nvim_config 'set splitright'

  write_nvim_config '""" Disable word wrap.'
  write_nvim_config 'set nowrap'

  write_nvim_config '""" Highlight pair bracket.'
  write_nvim_config 'set showmatch'
  write_nvim_config ''

  if [ "$use_rulers" = true ]; then
    write_nvim_config '""" Setup rulers.'
    write_nvim_config 'let &colorcolumn="101,".join(range(121,999),",")'
    write_nvim_config ''
  fi

  write_nvim_config "\"\"\" Enable hybrid line numbers (Ctrl-C won't toggle)."
  write_nvim_config 'augroup toggle_relative_line_numbers'
  write_nvim_config '  autocmd!'
  write_nvim_config '  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif'
  write_nvim_config '  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif'
  write_nvim_config 'augroup END'
  write_nvim_config ''

  write_nvim_config '""" Highlight yank area when yanking.'
  write_nvim_config 'augroup highlight_on_yank'
  write_nvim_config '    autocmd!'
  write_nvim_config '    au TextYankPost * silent! lua vim.highlight.on_yank({higroup="IncSearch", timeout=150})'
  write_nvim_config 'augroup END'
  write_nvim_config ''

  write_nvim_config "source $NVIM_KEYMAPPING"
  write_nvim_config "source $PLUGIN_CONFIG"
  log "Neovim configuration file created: $NVIM_CONFIG"
}


function write_nvim_keymapping() {
  echo "$1" >> "$NVIM_KEYMAPPING"
}


function config_nvim_keymappings() {
  if [ "$navigate_windows_keymapping" = true ]; then
    write_nvim_keymapping '-- Use Ctrl-[hjkl] to navigate between windows (panes).'
    write_nvim_keymapping 'vim.keymap.set("n", "<C-h>", "<CMD>wincmd h<CR>", { silent = true, desc = "Navigate left" })'
    write_nvim_keymapping 'vim.keymap.set("n", "<C-j>", "<CMD>wincmd j<CR>", { silent = true, desc = "Navigate down" })'
    write_nvim_keymapping 'vim.keymap.set("n", "<C-k>", "<CMD>wincmd k<CR>", { silent = true, desc = "Navigate up" })'
    write_nvim_keymapping 'vim.keymap.set("n", "<C-l>", "<CMD>wincmd l<CR>", { silent = true, desc = "Navigate right" })'
    write_nvim_keymapping ''
  fi

  if [ "$navigate_tabs_keymapping" = true ]; then
    write_nvim_keymapping '-- Use Tab and Shift-Tab to navigate tabs.'
    write_nvim_keymapping 'vim.keymap.set("n", "<Tab>", "<CMD>tabnext<CR>", { silent = true, desc = "Next tab" })'
    write_nvim_keymapping 'vim.keymap.set("n", "<S-Tab>", "<CMD>tabprevious<CR>", { silent = true, desc = "Previous tab" })'
    write_nvim_keymapping ''
  fi

  if [ "$autocomplete_menu_keymapping" = true ]; then
    write_nvim_keymapping '-- Use Ctrl-j to open keyword autocomplete menu in Insert Mode.'
    write_nvim_keymapping '-- Use Ctrl-j and Ctrl-k to select matches in autocomplete menu (popup menu).'
    write_nvim_keymapping 'local function autocomplete_select_down()'
    write_nvim_keymapping '  return vim.fn.pumvisible() == 1 and "<C-n>" or "<C-x><C-n>"'
    write_nvim_keymapping 'end'
    write_nvim_keymapping 'local function autocomplete_select_up()'
    write_nvim_keymapping '  return vim.fn.pumvisible() == 1 and "<C-p>" or "<C-k>"'
    write_nvim_keymapping 'end'
    write_nvim_keymapping 'vim.keymap.set("i", "<C-j>", autocomplete_select_down, { expr = true, noremap = true })'
    write_nvim_keymapping 'vim.keymap.set("i", "<C-k>", autocomplete_select_up, { expr = true, noremap = true })'
    write_nvim_keymapping '-- Use Tab to accept current selected match and stop completion.'
    write_nvim_keymapping 'local function accept_autocomplete()'
    write_nvim_keymapping '  return vim.fn.pumvisible() == 1 and "<C-y>" or "<Tab>"'
    write_nvim_keymapping 'end'
    write_nvim_keymapping 'vim.keymap.set("i", "<Tab>", accept_autocomplete, { expr = true, noremap = true })'
    write_nvim_keymapping ''
  fi

  if [ "$dont_exit_when_indenting" = true ]; then
    write_nvim_keymapping '-- Prevent exiting when indenting.'
    write_nvim_keymapping 'vim.keymap.set("x", "<", "<gv", { silent = true, noremap = true })'
    write_nvim_keymapping 'vim.keymap.set("x", ">", ">gv", { silent = true, noremap = true })'
    write_nvim_keymapping ''
  fi

  log "Neovim keymapping set up: $NVIM_KEYMAPPING"
}


function write_plugin_config() {
  echo "$1" >> "$PLUGIN_CONFIG"
}


function config_colorscheme() {
  write_plugin_config "-- $KANAGAWA"
  write_plugin_config 'vim.cmd("packadd! kanagawa")'
  write_plugin_config 'local kanagawa = require("kanagawa")'
  write_plugin_config 'local function override_kanagawa(colors)'
  write_plugin_config '  local theme = colors.theme'
  write_plugin_config '  return {'
  write_plugin_config '    Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 },  -- add `blend = vim.o.pumblend` to enable transparency'
  write_plugin_config '    PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },'
  write_plugin_config '    PmenuSbar = { bg = theme.ui.bg_m1 },'
  write_plugin_config '    PmenuThumb = { bg = theme.ui.bg_p2 },'
  write_plugin_config '  }'
  write_plugin_config 'end'
  write_plugin_config 'kanagawa.setup({'
  write_plugin_config '  colors = {'
  write_plugin_config '    theme = {'
  write_plugin_config '      all = {'
  write_plugin_config '        ui = {'
  write_plugin_config '          bg_gutter = "none",'
  write_plugin_config '          bg_p2 = "none",'
  write_plugin_config '        },'
  write_plugin_config '      },'
  write_plugin_config '    },'
  write_plugin_config '  },'
  write_plugin_config '  overrides = override_kanagawa,'
  write_plugin_config '})'
  write_plugin_config 'kanagawa.load("wave")'
  write_plugin_config 'vim.o.cursorline = true'
  write_plugin_config ''
}


function config_better_whitespace() {
  write_plugin_config "-- $BETTER_WHITESPACE"
  write_plugin_config 'vim.api.nvim_set_hl(0, "ExtraWhitespace", { ctermbg = 88, bg = "#8B0000" })'
  write_plugin_config ''
}


function config_lualine() {
  write_plugin_config "-- $LUALINE"
  write_plugin_config 'require("lualine").setup({ })'
  write_plugin_config ''
}


function config_nvimtree() {
  write_plugin_config "-- $NVIMTREE"
  write_plugin_config 'local function my_on_attach(bufnr)'
  write_plugin_config '  local ok, api = pcall(require, "nvim-tree.api")'
  write_plugin_config '  local function opts(desc)'
  write_plugin_config '    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }'
  write_plugin_config '  end'
  write_plugin_config '  assert(ok, "api module is not found")'
  write_plugin_config '  -- Apply default mappings.'
  write_plugin_config '  api.config.mappings.default_on_attach(bufnr)'
  write_plugin_config '  -- Remove certain default mappings.'
  write_plugin_config '  vim.keymap.del("n", "<Tab>", { buffer = bufnr })'
  write_plugin_config '  -- Override default mappings.'
  write_plugin_config '  vim.keymap.set("n", ">", api.node.run.cmd, opts("Run Command"))'
  write_plugin_config '  vim.keymap.set("n", ".", api.tree.toggle_hidden_filter, opts("Toggle Dotfiles"))'
  write_plugin_config '  vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close Directory"))'
  write_plugin_config '  vim.keymap.set("n", "H", api.tree.collapse_all, opts("Collapse All"))'
  write_plugin_config '  vim.keymap.set("n", "J", api.node.navigate.sibling.next, opts("Next Sibling"))'
  write_plugin_config '  vim.keymap.set("n", "K", api.node.navigate.sibling.prev, opts("Previous Sibling"))'
  write_plugin_config '  vim.keymap.set("n", "l", api.node.open.tab_drop, opts("Tab drop"))'
  write_plugin_config '  vim.keymap.set("n", "s", api.node.open.horizontal, opts("Open: Horizontal Split"))'
  write_plugin_config '  vim.keymap.set("n", "v", api.node.open.vertical, opts("Open: Vertical Split"))'
  write_plugin_config '  vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))'
  write_plugin_config 'end'
  write_plugin_config 'require("nvim-tree").setup({'
  write_plugin_config '  disable_netrw = true,'
  write_plugin_config '  git = {'
  write_plugin_config '    ignore = false,'
  write_plugin_config '  },'
  write_plugin_config '  on_attach = my_on_attach,'
  write_plugin_config '  renderer = {'
  write_plugin_config '    highlight_git = true,'
  write_plugin_config '    icons = {'
  write_plugin_config '      glyphs = {'
  write_plugin_config '        git = {'
  write_plugin_config '          unstaged = "M",'
  write_plugin_config '          staged = "A",'
  write_plugin_config '          renamed = "R",'
  write_plugin_config '          untracked = "U",'
  write_plugin_config '          deleted = "D",'
  write_plugin_config '          ignored = " ",'
  write_plugin_config '        },'
  write_plugin_config '      },'
  write_plugin_config '    },'
  write_plugin_config '  },'
  write_plugin_config '  tab = {'
  write_plugin_config '    sync = {'
  write_plugin_config '      open = true,'
  write_plugin_config '      close = true,'
  write_plugin_config '    },'
  write_plugin_config '  },'
  write_plugin_config '  view = {'
  if [ "$nvimtree_side" = "right" ]; then
    write_plugin_config '    side = "right",'
  fi
  write_plugin_config '  },'
  write_plugin_config '})'
  write_plugin_config '-- Close the tab if nvim-tree is the last buffer in the tab (after closing a buffer).'
  write_plugin_config '-- Close vim if nvim-tree is the last buffer (after closing a buffer).'
  write_plugin_config '-- Close nvim-tree across all tabs when one nvim-tree buffer is manually closed if and only if tabs.sync.close is set.'
  write_plugin_config 'local function tab_win_closed(winnr)'
  write_plugin_config '  local api = require"nvim-tree.api"'
  write_plugin_config '  local tabnr = vim.api.nvim_win_get_tabpage(winnr)'
  write_plugin_config '  local bufnr = vim.api.nvim_win_get_buf(winnr)'
  write_plugin_config '  local buf_info = vim.fn.getbufinfo(bufnr)[1]'
  write_plugin_config '  local tab_wins = vim.tbl_filter(function(w) return w~=winnr end, vim.api.nvim_tabpage_list_wins(tabnr))'
  write_plugin_config '  local tab_bufs = vim.tbl_map(vim.api.nvim_win_get_buf, tab_wins)'
  write_plugin_config '  if buf_info.name:match(".*NvimTree_%d*$") then  -- close buffer was nvim tree'
  write_plugin_config '    -- Close all nvim tree on :q'
  write_plugin_config '    if not vim.tbl_isempty(tab_bufs) then  -- and was not the last window (not closed automatically by code below)'
  write_plugin_config '      api.tree.close()'
  write_plugin_config '    end'
  write_plugin_config '  else  -- else closed buffer was normal buffer'
  write_plugin_config '    if #tab_bufs == 1 then  -- if there is only 1 buffer left in the tab'
  write_plugin_config '      local last_buf_info = vim.fn.getbufinfo(tab_bufs[1])[1]'
  write_plugin_config '      if last_buf_info.name:match(".*NvimTree_%d*$") then  -- and that buffer is nvim tree'
  write_plugin_config '        vim.schedule(function ()'
  write_plugin_config '          if #vim.api.nvim_list_wins() == 1 then  -- if its the last buffer in vim'
  write_plugin_config '            vim.cmd "quit"  -- then close all of vim'
  write_plugin_config '          else  -- else there are more tabs open'
  write_plugin_config '            vim.api.nvim_win_close(tab_wins[1], true)  -- then close only the tab'
  write_plugin_config '          end'
  write_plugin_config '        end)'
  write_plugin_config '      end'
  write_plugin_config '    end'
  write_plugin_config '  end'
  write_plugin_config 'end'
  write_plugin_config 'vim.api.nvim_create_autocmd("WinClosed", {'
  write_plugin_config '  callback = function ()'
  write_plugin_config '    local winnr = tonumber(vim.fn.expand("<amatch>"))'
  write_plugin_config '    vim.schedule_wrap(tab_win_closed(winnr))'
  write_plugin_config '  end,'
  write_plugin_config '  nested = true'
  write_plugin_config '})'
  write_plugin_config "-- Use Ctrl-b to toggle $NVIMTREE."
  write_plugin_config 'vim.keymap.set("n", "<C-b>", ":NvimTreeToggle<CR>", { silent = true, noremap = true })'
  write_plugin_config ''
}


function config_devicons() {
  write_plugin_config "-- $DEVICONS"
  write_plugin_config 'require("nvim-web-devicons").setup({ })'
  write_plugin_config ''
}


function config_bufferline() {
  write_plugin_config "-- $BUFFERLINE"
  write_plugin_config 'local bufferline = require("bufferline")'
  write_plugin_config 'bufferline.setup({'
  write_plugin_config '  highlights = {'
  write_plugin_config '    fill = {'
  write_plugin_config '      bg = "#363646",'
  write_plugin_config '    },'
  write_plugin_config '    separator = {'
  write_plugin_config '      fg = "#363646",'
  write_plugin_config '    },'
  write_plugin_config '    separator_selected = {'
  write_plugin_config '      fg = "#363646",'
  write_plugin_config '    },'
  write_plugin_config '    separator_visible = {'
  write_plugin_config '      fg = "#363646",'
  write_plugin_config '    },'
  write_plugin_config '  },'
  write_plugin_config '  options = {'
  write_plugin_config '    offsets = {'
  write_plugin_config '      {'
  write_plugin_config '        filetype = "NvimTree",'
  write_plugin_config '        text = "File Explorer",'
  write_plugin_config '        highlight = "Directory",'
  write_plugin_config '        separator = true,'
  write_plugin_config '      },'
  write_plugin_config '    },'
  write_plugin_config '    separator_style = "slant",'
  write_plugin_config '    show_close_icon = false,'
  write_plugin_config '    show_tab_indicators = false,'
  write_plugin_config '    style_preset = bufferline.style_preset.no_italic,'
  write_plugin_config '  },'
  write_plugin_config '})'
  write_plugin_config ''
}


function config_gitsigns() {
  write_plugin_config "-- $GITSIGNS"
  write_plugin_config 'require("gitsigns").setup({'
  write_plugin_config '  signs = {'
  write_plugin_config '    add = { text = "▌" },'
  write_plugin_config '    change = { text = "▌" },'
  write_plugin_config '    changedelete = { text = "▌" },'
  write_plugin_config '    untracked = { text = "║" },'
  write_plugin_config '  },'
  write_plugin_config '})'
  write_plugin_config ''
}


function config_indent_blankline() {
  write_plugin_config "-- $INDENT_BLANKLINE"
  write_plugin_config 'require("indent_blankline").setup({'
  write_plugin_config '  char = "▏",'
  write_plugin_config '  indent_level = 60,'
  write_plugin_config '})'
  write_plugin_config 'vim.api.nvim_set_hl(0, "IndentBlanklineChar", { ctermfg = 236, fg = "#303030", nocombine = true })'
  write_plugin_config ''
}


function config_hop() {
  write_plugin_config "-- $HOP"
  write_plugin_config 'local hop = require("hop")'
  write_plugin_config 'local directions = require("hop.hint").HintDirection'
  write_plugin_config 'hop.setup({ })'
  write_plugin_config 'local function easymotion_s()'
  write_plugin_config '  hop.hint_char1()'
  write_plugin_config 'end'
  write_plugin_config 'local function easymotion_overwin_f2()'
  write_plugin_config '  hop.hint_char2({ multi_windows = true })'
  write_plugin_config 'end'
  write_plugin_config 'local function easymotion_sn()'
  write_plugin_config '  hop.hint_patterns()'
  write_plugin_config 'end'
  write_plugin_config 'local function easymotion_w()'
  write_plugin_config '  hop.hint_words({ direction = directions.AFTER_CURSOR })'
  write_plugin_config 'end'
  write_plugin_config 'local function easymotion_b()'
  write_plugin_config '  hop.hint_words({ direction = directions.BEFORE_CURSOR })'
  write_plugin_config 'end'
  write_plugin_config 'local function easymotion_j()'
  write_plugin_config '  hop.hint_lines_skip_whitespace({ direction = directions.AFTER_CURSOR })'
  write_plugin_config 'end'
  write_plugin_config 'local function easymotion_k()'
  write_plugin_config '  hop.hint_lines_skip_whitespace({ direction = directions.BEFORE_CURSOR })'
  write_plugin_config 'end'
  write_plugin_config 'vim.keymap.set("", "<Leader><Leader>s", easymotion_s, { desc = "Search character" })'
  write_plugin_config 'vim.keymap.set("", "<Leader><Leader>S", easymotion_overwin_f2, { desc = "Search characters overwin" })'
  write_plugin_config 'vim.keymap.set("", "<Leader><Leader>/", easymotion_sn, { desc = "Search n-character" })'
  write_plugin_config 'vim.keymap.set("", "<Leader><Leader>w", easymotion_w, { desc = "Search word forward" })'
  write_plugin_config 'vim.keymap.set("", "<Leader><Leader>b", easymotion_b, { desc = "Search word backward" })'
  write_plugin_config 'vim.keymap.set("", "<Leader><Leader>j", easymotion_j, { desc = "Search line forward" })'
  write_plugin_config 'vim.keymap.set("", "<Leader><Leader>k", easymotion_k, { desc = "Search line backward" })'
  write_plugin_config ''
}


function config_whichkey() {
  write_plugin_config "-- $WHICHKEY"
  write_plugin_config 'local whichkey = require("which-key")'
  write_plugin_config 'whichkey.setup({'
  write_plugin_config '  layout = {'
  write_plugin_config '    height = { max = 20 },'
  write_plugin_config '    spacing = 2,'
  write_plugin_config '  },'
  write_plugin_config '  plugins = {'
  write_plugin_config '    presets = {'
  write_plugin_config '      operators = false,'
  write_plugin_config '    },'
  write_plugin_config '  },'
  write_plugin_config '})'
  write_plugin_config 'local wk_mappings = {'
  write_plugin_config '  b = {'
  write_plugin_config '    name = "Buffers...",'
  write_plugin_config '    ["="] = { "<CMD>wincmd =<CR>", "Balance splits size" },'
  if [ -n "${nvim_plugin[$BUFFERLINE]}" ]; then
    write_plugin_config '    [">"] = { "<CMD>BufferLineMoveNext<CR>", "Move buffer right" },'
    write_plugin_config '    ["<"] = { "<CMD>BufferLineMovePrev<CR>", "Move buffer left" },'
    write_plugin_config '    b = { "<CMD>BufferLinePick<CR>", "Pick a buffer" },'
  fi
  write_plugin_config '    d = { "<CMD>bd<CR>", "Close active buffer" },'
  write_plugin_config '    H = { "<CMD>wincmd 5<<CR>", "Make current split smaller horizontally" },'
  write_plugin_config '    J = { "<CMD>resize -5<CR>", "Make current split smaller vertically" },'
  write_plugin_config '    K = { "<CMD>resize +5<CR>", "Make current split larger vertically" },'
  write_plugin_config '    L = { "<CMD>wincmd 5><CR>", "Make current split larger horizontally" },'
  write_plugin_config '  },'
  if [ -n "${nvim_plugin[$NVIMTREE]}" ]; then
    write_plugin_config '  e = { "<CMD>NvimTreeToggle<CR>", "Toggle file explorer" },'
  fi
  write_plugin_config '  h = { "<CMD>wincmd s<CR>", "Split horizontally" },'
  write_plugin_config '  q = { "<CMD>qa<CR>", "Quit Neovim" },'
  write_plugin_config '  Q = { "<CMD>qa!<CR>", "Quit Neovim without saving" },'
  write_plugin_config '  v = { "<CMD>wincmd v<CR>", "Split vertically" },'
  write_plugin_config '}'
  write_plugin_config 'local wk_opts = {'
  write_plugin_config '  mode = "n",'
  write_plugin_config '  prefix = "<Space>",'
  write_plugin_config '  buffer = nil,'
  write_plugin_config '  silent = true,'
  write_plugin_config '  noremap = true,'
  write_plugin_config '  nowait = true,'
  write_plugin_config '}'
  write_plugin_config 'whichkey.register(wk_mappings, wk_opts)'
  write_plugin_config 'vim.opt.timeoutlen = 150'
  write_plugin_config ''
}


function config_plugins() {
  if [ -n "${nvim_plugin[$KANAGAWA]}" ]; then
    config_colorscheme
  fi

  if [ -n "${nvim_plugin[$BETTER_WHITESPACE]}" ]; then
    config_better_whitespace
  fi

  if [ -n "${nvim_plugin[$LUALINE]}" ]; then
    config_lualine
  fi

  if [ -n "${nvim_plugin[$NVIMTREE]}" ]; then
    config_nvimtree
  fi

  if [ -n "${nvim_plugin[$DEVICONS]}" ]; then
    config_devicons
  fi

  if [ -n "${nvim_plugin[$BUFFERLINE]}" ]; then
    config_bufferline
  fi

  if [ -n "${nvim_plugin[$GITSIGNS]}" ]; then
    config_gitsigns
  fi

  if [ -n "${nvim_plugin[$INDENT_BLANKLINE]}" ]; then
    config_indent_blankline
  fi

  if [ -n "${nvim_plugin[$HOP]}" ]; then
    config_hop
  fi

  if [ -n "${nvim_plugin[$WHICHKEY]}" ]; then
    config_whichkey
  fi

  log "Neovim plugins' configuration files created: $PLUGIN_CONFIG"
}


function config_ftplugins() {
  if [ "$use_rulers" = true ]; then
    # For cpp.
    echo 'set colorcolumn=121' >> $FTPLUGIN_C
    # For Git.
    echo 'let &colorcolumn="51,".join(range(73,999),",")' >> $FTPLUGIN_GIT
    # For JavaScript.
    echo 'set colorcolumn=101' >> $FTPLUGIN_JAVASCRIPT
    # For Python.
    echo 'let &colorcolumn="73,".join(range(80,999),",")' >> $FTPLUGIN_PYTHON
  fi

  local ftplugins=$(ls "$NVIM_FTPLUGIN_DIR" | tr "\n" " ")
  log "Neovim ftplugin configured: $ftplugins"
}


function install_plugin() {
  local pack_dir="$1"
  local plugin_name="$2"
  local add_helptags="$3"

  cd "$pack_dir"
  case "$nvim_plugin_installer" in
    "curl")
      curl -LJ "${URL[$plugin_name]}" -o "$plugin_name.tar.gz"
      mkdir -p "$pack_dir/$plugin_name"
      tar -xzf "$plugin_name.tar.gz" -C "$plugin_name" --strip-components=1
      rm "$plugin_name.tar.gz"
      ;;
    "git")
      git clone "${GIT_URL[$plugin_name]}" "$pack_dir/$plugin_name"
      ;;
    "wget")
      wget --no-check-certificate --content-disposition "${URL[$plugin_name]}" -O "$plugin_name.tar.gz"
      mkdir -p "$pack_dir/$plugin_name"
      tar -xzf "$plugin_name.tar.gz" -C "$plugin_name" --strip-components=1
      rm "$plugin_name.tar.gz"
      ;;
  esac

  # TODO: Make adding helptags automatically by verifying if "doc" folder exists.
  if [ "$add_helptags" = true ]; then
    nvim -u NONE --headless --cmd "helptags $pack_dir/$plugin_name/doc" +q
  fi
}


function install_nvim_plugins() {
  for plugin in "${!nvim_plugin[@]}"; do
    case "$plugin" in
      "$KANAGAWA")
        install_plugin "$PLUGIN_OPT_DIR" "$KANAGAWA" false
        ;;
      "$BETTER_WHITESPACE")
        install_plugin "$PLUGIN_START_DIR" "$BETTER_WHITESPACE" false
        ;;
      "$LUALINE")
        install_plugin "$PLUGIN_START_DIR" "$LUALINE" false
        ;;
      "$NVIMTREE")
        install_plugin "$PLUGIN_START_DIR" "$NVIMTREE" true
        ;;
      "$DEVICONS")
        install_plugin "$PLUGIN_START_DIR" "$DEVICONS" false
        ;;
      "$BUFFERLINE")
        install_plugin "$PLUGIN_START_DIR" "$BUFFERLINE" true
        ;;
      "$GITSIGNS")
        install_plugin "$PLUGIN_START_DIR" "$GITSIGNS" true
        ;;
      "$INDENT_BLANKLINE")
        install_plugin "$PLUGIN_START_DIR" "$INDENT_BLANKLINE" true
        ;;
      "$HOP")
        install_plugin "$PLUGIN_START_DIR" "$HOP" true
        ;;
      "$WHICHKEY")
        install_plugin "$PLUGIN_START_DIR" "$WHICHKEY" true
        ;;
    esac
  done

  log "Neovim plugins installed: ${!nvim_plugin[*]}"
}


function add_nvim_path() {
  local msg=()
  case "$shell" in
    "bash")
      echo '' >> "$shellconfig"
      echo '# Neovim' >> "$shellconfig"
      echo 'command -v nvim &> /dev/null || export PATH="'"$NVIM_RELEASE_DIR"'/bin:$PATH"' >> "$shellconfig"
      msg=(
        "The following lines are added into $shellconfig:\n\n"
        "        # Neovim\n"
        '        command -v nvim &> /dev/null || export PATH="'"$NVIM_RELEASE_DIR"'/bin:$PATH"\n'
      )
      ;;
    "zsh")
      echo '' >> "$shellconfig"
      echo '# Neovim' >> "$shellconfig"
      echo 'command -v nvim &> /dev/null || export PATH="'"$NVIM_RELEASE_DIR"'/bin:$PATH"' >> "$shellconfig"
      msg=(
        "The following lines are added into $shellconfig:\n\n"
        "        # Neovim\n"
        '        command -v nvim &> /dev/null || export PATH="'"$NVIM_RELEASE_DIR"'/bin:$PATH"\n'
      )
      ;;
    "fish")
      if [ ! -d "$HOME/.config/fish/conf.d" ]; then
        log "Config folder doesn't exist. Create the folder: $HOME/.config/fish/conf.d"
        mkdir -p "$HOME/.config/fish/conf.d"
      fi
      echo '' >> "$shellconfig"
      echo '# Neovim' >> "$shellconfig"
      echo 'command -v nvim &> /dev/null || set -gx PATH '"$NVIM_RELEASE_DIR"'/bin $PATH' >> "$shellconfig"
      msg=(
        "The following lines are added into $shellconfig:\n\n"
        "        # Neovim\n"
        '        command -v nvim &> /dev/null || set -gx PATH '"$NVIM_RELEASE_DIR"'/bin $PATH\n'
      )
      ;;
  esac
  log "${msg[*]}"

  msg=(
    "To apply the changes, open a new terminal or reload your shell by running:\n\n"
    "        source $shellconfig\n"
  )
  log "${msg[*]}"
}


function main() {
  confirm_sudo
  verify_nvim

  if ! path_contains_nvim && [ "$need_installing_nvim" = true ]; then
    confirm_adding_nvim_path
  fi

  confirm_nvim_config
  confirm_nvim_plugin

  if [ "${#nvim_plugin[@]}" -ne 0 ]; then
    confirm_nvim_plugin_installer
  fi

  confirm_continue

  if [ "$need_installing_spc" = true ] || [ "${#dependency[@]}" -ne 0 ]; then
    apt_get_update
  fi

  if [ "$need_installing_spc" = true ]; then
    install_spc
  fi

  if [ "${#ppas[@]}" -ne 0 ]; then
    add_ppas
  fi

  if [ "${#dependency[@]}" -ne 0 ]; then
    install_dependencies
  fi

  if [ "$need_installing_nvim" = true ]; then
    if [ -d "$NVIM_RELEASE_DIR" ] && [ -d "$NVIM_RELEASE_BACKUP" ]; then
      remove_nvim_release_backup
    fi
    if [ -d "$NVIM_RELEASE_DIR" ]; then
      backup_nvim_release_dir
    fi
    create_nvim_release_dir
    install_nvim_from_github
  fi

  if [ -d "$NVIM_CONFIG_DIR" ] && [ -d "$NVIM_CONFIG_BACKUP" ]; then
    remove_nvim_config_backup
  fi
  if [ -d "$NVIM_CONFIG_DIR" ]; then
    backup_nvim_config_dir
  fi
  create_nvim_config_dir
  create_configs
  config_nvim_settings
  config_nvim_keymappings
  config_plugins
  config_ftplugins

  if [ "${#nvim_plugin[@]}" -ne 0 ]; then
    install_nvim_plugins
  fi

  if [ "$need_adding_nvim_path" = true ]; then
    add_nvim_path
  fi
}


parse_cli_args $@
main
