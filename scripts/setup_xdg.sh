#!/usr/bin/env bash

set -euo pipefail

declare -xr XDG_BIN_HOME="${XDG_BIN_HOME:-\$HOME/.local/bin}"
declare -xr XDG_DATA_HOME="${XDG_DATA_HOME:-\$HOME/.local/share}"
declare -xr XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-\$HOME/.config}"
declare -xr XDG_CACHE_HOME="${XDG_CACHE_HOME:-\$HOME/.cache}"

# TODO: Handle path of util scripts to allow user run this script anywhere.
source utils/logger_util.sh 2>/dev/null \
  || (printf '%s\n' '`./utils/logger_util.sh` is not found.' >&2 && exit 1)

function add_xdg_env() {
  local _shell="$1"
  local _shellconfig="$2"

  # TODO: Only add env vars which haven't been added.
  case "${_shell,,}" in
    "bash" | "zsh")
      echo '' >> "$_shellconfig"
      echo '# XDG Base Specification' >> "$_shellconfig"
      echo "export XDG_BIN_HOME=\"$XDG_BIN_HOME\"" >> "$_shellconfig"
      echo "export XDG_CONFIG_HOME=\"$XDG_CONFIG_HOME\"" >> "$_shellconfig"
      echo "export XDG_CACHE_HOME=\"$XDG_CACHE_HOME\"" >> "$_shellconfig"
      echo "export XDG_DATA_HOME=\"$XDG_DATA_HOME\"" >> "$_shellconfig"
      ;;
    "fish")
      local _configdir=$(dirname $_shellconfig)
      if [ ! -d "$_configdir" ]; then
        warn "Config folder doesn't exist. Create the folder: $_configdir"
        mkdir -p "$_configdir"
      fi
      echo '' >> "$_shellconfig"
      echo '# XDG Base Specification' >> "$_shellconfig"
      echo "set -gx XDG_BIN_HOME $XDG_BIN_HOME" >> "$_shellconfig"
      echo "set -gx XDG_CONFIG_HOME $XDG_CONFIG_HOME" >> "$_shellconfig"
      echo "set -gx XDG_CACHE_HOME $XDG_CACHE_HOME" >> "$_shellconfig"
      echo "set -gx XDG_DATA_HOME $XDG_DATA_HOME" >> "$_shellconfig"
      ;;
  esac
  completed "XDG environment variables have been added into '$_shellconfig'."
}

function main() {
  # TODO: Use configuration file instead of interactive prompt.
  local _question="Which shell do you want to add XDG base specification?"
  local _shell=""
  while [ -z "$_shell" ]; do
    echo -e "${BOLD}$_question${NO_COLOR}"
    read -p "  bash or zsh or fish (q to discard): " -r _answer

    case "${_answer,,}" in  # To lower case.
      "bash")
        _shell="bash"
        add_xdg_env "${_shell}" "$HOME/.bashrc"
        ;;
      "zsh")
        _shell="zsh"
        add_xdg_env "${_shell}" "${ZDOTDIR:-$HOME}/.zshrc"
        ;;
      "fish")
        _shell="fish"
        add_xdg_env "${_shell}" "$HOME/.config/fish/conf.d/00_config.fish"
        ;;
      "q" | "quit")
        return 0
        ;;
      *)
        error "Invalid answer: $_answer"
        ;;
    esac
  done
}

main
