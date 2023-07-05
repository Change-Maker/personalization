#!/usr/bin/env bash

set -eo pipefail

declare -r VIMRC="$HOME/.vimrc"
declare -r VIMRC_BACKUP="$HOME/backup.vimrc"
declare -r VIM="$HOME/.vim"
declare -r VIM_BACKUP="$HOME/backup.vim"

declare -r VIM_FTPLUGIN="$HOME/.vim/ftplugin"
declare -r FTPLUGIN_GIT="$VIM_FTPLUGIN/git.vim"
declare -r FTPLUGIN_PYTHON="$VIM_FTPLUGIN/python.vim"
declare -r FTPLUGIN_JAVASCRIPT="$VIM_FTPLUGIN/javascript.vim"
declare -r FTPLUGIN_C="$VIM_FTPLUGIN/c.vim"

declare -r VIM_PLUGINS_START_DIR="$HOME/.vim/pack/plugins/start"
declare -r VIM_PLUGINS_OPT_DIR="$HOME/.vim/pack/plugins/opt"

declare -r ONEDARK='onedark.vim'
declare -r LIGHTLINE='lightline'
declare -r BETTER_WHITESPACE='vim-better-whitespace'
declare -r FUGITIVE='fugitive'
declare -r NERDTREE='NERDTree'
declare -r DEVICONS='vim-devicons'
declare -r EASYMOTION='vim-easymotion'
declare -r WHICHKEY='vim-which-key'
declare -r GITGUTTER='vim-gitgutter'
declare -r INDENTLINE='indentLine'

declare -r ONEDARK_GIT_URL='https://github.com/joshdick/onedark.vim.git'
declare -r LIGHTLINE_GIT_URL='https://github.com/itchyny/lightline.vim'
declare -r BETTER_WHITESPACE_GIT_URL='https://github.com/ntpeters/vim-better-whitespace.git'
declare -r FUGITIVE_GIT_URL='https://tpope.io/vim/fugitive.git'
declare -r NERDTREE_GIT_URL='https://github.com/preservim/nerdtree.git'
declare -r DEVICONS_GIT_URL='https://github.com/ryanoasis/vim-devicons.git'
declare -r EASYMOTION_GIT_URL='https://github.com/easymotion/vim-easymotion.git'
declare -r WHICHKEY_GIT_URL='https://github.com/liuchengxu/vim-which-key.git'
declare -r GITGUTTER_GIT_URL='https://github.com/airblade/vim-gitgutter.git'
declare -r INDENTLINE_GIT_URL='https://github.com/Yggdroot/indentLine.git'

declare -r ONEDARK_URL='https://github.com/joshdick/onedark.vim/tarball/main'
declare -r LIGHTLINE_URL='https://github.com/itchyny/lightline.vim/tarball/master'
declare -r BETTER_WHITESPACE_URL='https://github.com/ntpeters/vim-better-whitespace/tarball/master'
declare -r FUGITIVE_URL='https://github.com/tpope/vim-fugitive/tarball/master'
declare -r NERDTREE_URL='https://github.com/preservim/nerdtree/tarball/master'
declare -r DEVICONS_URL='https://github.com/ryanoasis/vim-devicons/tarball/master'
declare -r EASYMOTION_URL='https://github.com/easymotion/vim-easymotion/tarball/master'
declare -r WHICHKEY_URL='https://github.com/liuchengxu/vim-which-key/tarball/master'
declare -r GITGUTTER_URL='https://github.com/airblade/vim-gitgutter/tarball/master'
declare -r INDENTLINE_URL='https://github.com/Yggdroot/indentLine/tarball/master'

declare install_with_sudo=false
declare need_upgrade_vim=false
declare vim_is_upgraded=false

declare install_onedark=false
declare install_lightline=false
declare install_better_whitespace=false
declare install_fugitive=false
declare install_nerdtree=false
declare install_devicons=false
declare install_easymotion=false
declare install_whichkey=false
declare install_gitgutter=false
declare install_indentline=false

declare vim_plugins_installer=""

declare auto_switch_cursor_style=false
declare navigate_windows_easily=false
declare navigate_tabs_easily=false
declare use_rulers=false
declare avoid_escape_key=false
declare escape_keymap=""
declare nerdtree_win_pos=""

declare -a dependencies=()
declare -a vim_plugins=()

function confirm() {
  local question="$1"
  while true; do
    echo
    echo "$question"
    read -p "[y]es or [n]o (default: no): " -r answer
    case "$answer" in
      "y" | "Y" | "yes" | "YES" | "Yes")
        return 0
        ;;
      "n" | "N" | "no" | "NO" | "No" | *[[:blank:]]* | "")
        return 1
        ;;
      *)
        echo "[ERROR] Please answer [y]es or [n]o."
        ;;
    esac
  done
}

function confirm_exactly() {
  local question="$1"
  while true; do
    echo
    echo "$question"
    read -p "[y]es or [n]o: " -r answer
    case "$answer" in
      "y" | "Y" | "yes" | "YES" | "Yes")
        return 0
        ;;
      "n" | "N" | "no" | "NO" | "No")
        return 1
        ;;
      *)
        echo "[ERROR] Please answer [y]es or [n]o."
        ;;
    esac
  done
}

function verify_sudo() {
  if confirm "Would you like to install dependencies without sudo?"; then
    echo "[INFO] Run installation without sudo."
  else
    install_with_sudo=true
    if ! which sudo &> /dev/null; then
      echo
      echo "[ERROR] Please install sudo first if you want to install dependencies with sudo."
      exit 1
    fi
  fi
}

function verify_vim() {
  if ! which vim &> /dev/null; then
    dependencies+=("vim")
  else
    if ! vim --cmd 'if v:version >= 800 | q | else | cq | fi' ; then
      if [ "$vim_is_upgraded" = true ]; then
        echo
        echo "[WARNING] The Vim version is still not up to date. You should upgrade Vim to 8.0+ manually."
      else
        need_upgrade_vim=true
        echo
        echo -n "[WARNING] The Vim version is not greater than 8.0."
        echo " This customization will try to upgrade your Vim to the latest version."
      fi
    fi
  fi
}

function verify_git() {
  if ! which git &> /dev/null; then
    dependencies+=("git")
  fi
}

function verify_wget() {
  if ! which wget &> /dev/null; then
    dependencies+=("wget")
  fi
}

function verify_curl() {
  if ! which curl &> /dev/null; then
    dependencies+=("curl")
  fi
}

function add_apt_repository() {
  if ! which add-apt-repository &> /dev/null; then
    if [ "$install_with_sudo" = true ]; then
      sudo DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common
    else
      DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common
    fi
  fi

  if [ "$vim_plugins_installer" = "git" ]; then
    if [ "$install_with_sudo" = true ]; then
      sudo add-apt-repository --yes ppa:git-core/ppa
    else
      add-apt-repository --yes ppa:git-core/ppa
    fi
  fi
}

function install_dependencies() {
  if [ "${#dependencies[@]}" -ne 0 ]; then
    echo
    echo "[INFO] Installing dependencies..."
    if [ "$install_with_sudo" = true ]; then
      sudo apt-get update
      for dependency in "${dependencies[@]}"; do
        sudo apt-get install -y "$dependency"
      done
    else
      apt-get update
      for dependency in "${dependencies[@]}"; do
        apt-get install -y "$dependency"
      done
    fi
  fi

  if [ "$need_upgrade_vim" = false ]; then
    vim_is_upgraded=true
  fi
}

function upgrade_vim() {
  if [ "$need_upgrade_vim" = true ]; then
    echo
    echo "[INFO] Upgrading Vim..."
    if [ "${#dependencies[@]}" -eq 0 ]; then
      if [ "$install_with_sudo" = true ]; then
        sudo apt-get update
        sudo apt-get install -y vim
      else
        apt-get update
        apt-get install -y vim
      fi
    else
      if [ "$install_with_sudo" = true ]; then
        sudo apt-get install -y vim
      else
        apt-get install -y vim
      fi
    fi
    vim_is_upgraded=true
  fi
}

function config_vim() {
  echo
  echo "[INFO] Create '$VIMRC'."

  echo '""" Colorscheme.' >> $VIMRC
  echo '""" You could get the list of built-in colorschemes by running:' >> $VIMRC
  echo "\"\"\"   \`ls \$VIMRUNTIME/colors | grep '.vim'\`" >> $VIMRC
  echo "\"\"\"   which \`\$VIMRUNTIME\` is something like '/usr/share/vim/vim81'." >> $VIMRC
  echo 'set termguicolors' >> $VIMRC
  if [ "$install_onedark" = true ]; then
    echo "packadd! $ONEDARK" >> $VIMRC
    echo 'colorscheme onedark' >> $VIMRC
  else
    echo 'colorscheme desert' >> $VIMRC
  fi
  echo '' >> $VIMRC

  echo '""" Enable syntax.' >> $VIMRC
  echo 'syntax on' >> $VIMRC
  echo '' >> $VIMRC

  echo '""" Disable compatible with vi.' >> $VIMRC
  echo 'set nocompatible' >> $VIMRC
  echo '' >> $VIMRC

  echo '""" Enable line number.' >> $VIMRC
  echo 'set number' >> $VIMRC
  echo '' >> $VIMRC

  echo '""" Enable mouse.' >> $VIMRC
  echo 'set mouse=a' >> $VIMRC
  echo '' >> $VIMRC

  echo '""" Check filetype and indent of file automatically.' >> $VIMRC
  echo 'filetype plugin indent on' >> $VIMRC
  echo '' >> $VIMRC

  echo '""" The size of actual tab characters in the buffer.' >> $VIMRC
  echo 'set tabstop=2' >> $VIMRC
  echo '' >> $VIMRC

  echo '""" The number of "spaces" inserted when hitting the tab key.' >> $VIMRC
  echo 'set softtabstop=2' >> $VIMRC
  echo '' >> $VIMRC

  echo '""" The size of indents.' >> $VIMRC
  echo 'set shiftwidth=2' >> $VIMRC
  echo '' >> $VIMRC

  echo '""" `cindent` is based on smartindent.' >> $VIMRC
  echo '""" `smartindent` is based on autoindent.' >> $VIMRC
  echo 'set cindent' >> $VIMRC
  echo '' >> $VIMRC

  echo '""" Enable insert spaces when passing Tab.' >> $VIMRC
  echo 'set expandtab' >> $VIMRC
  echo '' >> $VIMRC

  echo "\"\"\" '·' symbol need utf-8 encoding" >> $VIMRC
  echo 'set encoding=utf-8' >> $VIMRC

  echo '""" Use C-j and C-k to move up and down in autocomplete menu (popup menu).' >> $VIMRC
  echo '""" And C-j will open keyword completion in Insert Mode.' >> $VIMRC
  echo 'inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<C-x>\<C-n>"' >> $VIMRC
  echo 'inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<C-k>"' >> $VIMRC

  echo '""" Use Tab to accept current selected match and stop completion.' >> $VIMRC
  echo 'inoremap <expr> <Tab> pumvisible() ? "\<C-y>" : "\<Tab>"' >> $VIMRC

  if [ "$install_better_whitespace" = false ]; then
    echo '""" Display all trailing whitespaces.' >> $VIMRC
    echo 'set list' >> $VIMRC
    echo 'set listchars=trail:·' >> $VIMRC
  fi
  echo '' >> $VIMRC

  echo '""" hlsearch enable high light of searching result.' >> $VIMRC
  echo 'set hlsearch' >> $VIMRC
  echo '""" Highlight searching result when typing.' >> $VIMRC
  echo 'set incsearch' >> $VIMRC
  echo '' >> $VIMRC

  echo '""" Set background color.' >> $VIMRC
  echo 'hi Normal ctermbg=233 guibg=#121212' >> $VIMRC
  echo '' >> $VIMRC

  echo '""" Set the color of un-used block which is at the bottom of editor.' >> $VIMRC
  echo 'hi NonText ctermfg=238 ctermbg=233 guifg=#444444 guibg=#121212' >> $VIMRC
  echo '' >> $VIMRC

  echo '""" Set the color of line numbers.' >> $VIMRC
  echo 'hi LineNr ctermfg=242 guifg=#6C6C6C' >> $VIMRC
  echo '' >> $VIMRC

  echo '""" Set the color of the current line number.' >> $VIMRC
  echo 'hi CursorLineNr ctermfg=214 guifg=orange' >> $VIMRC
  echo '' >> $VIMRC

  echo '""" Highlight pair bracket.' >> $VIMRC
  echo 'set showmatch' >> $VIMRC
  echo '' >> $VIMRC

  if [ "$use_rulers" = true ]; then
    echo '""" Setup rulers.' >> $VIMRC
    echo 'hi ColorColumn ctermbg=234 guibg=#1C1C1C' >> $VIMRC
    echo 'let &colorcolumn="101,".join(range(121,999),",")' >> $VIMRC
    echo '' >> $VIMRC
  fi

  echo $'""" Enable hybrid line numbers (Ctrl-C won\'t toggle).' >> $VIMRC
  echo 'augroup toggle_relative_line_numbers' >> $VIMRC
  echo '  autocmd!' >> $VIMRC
  echo '  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif' >> $VIMRC
  echo '  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif' >> $VIMRC
  echo 'augroup END' >> $VIMRC
  echo '' >> $VIMRC

  if [ "$auto_switch_cursor_style" = true ]; then
    echo '""" Use a line cursor within insert mode and a block cursor everywhere else.' >> $VIMRC
    echo '"""' >> $VIMRC
    echo '""" Reference chart of values:' >> $VIMRC
    echo '"""   Ps = 0  -> blinking block.' >> $VIMRC
    echo '"""   Ps = 1  -> blinking block (default).' >> $VIMRC
    echo '"""   Ps = 2  -> steady block.' >> $VIMRC
    echo '"""   Ps = 3  -> blinking underline.' >> $VIMRC
    echo '"""   Ps = 4  -> steady underline.' >> $VIMRC
    echo '"""   Ps = 5  -> blinking bar (xterm).' >> $VIMRC
    echo '"""   Ps = 6  -> steady bar (xterm).' >> $VIMRC
    echo 'let &t_SI = "\e[6 q"' >> $VIMRC
    echo 'let &t_EI = "\e[2 q"' >> $VIMRC
    echo '' >> $VIMRC
  fi

  if [ "$navigate_windows_easily" = true ]; then
    echo '""" Use Ctrl-[hjkl] to navigate between windows (panes).' >> $VIMRC
    echo 'nmap <silent> <C-k> :wincmd k<CR>' >> $VIMRC
    echo 'nmap <silent> <C-j> :wincmd j<CR>' >> $VIMRC
    echo 'nmap <silent> <C-h> :wincmd h<CR>' >> $VIMRC
    echo 'nmap <silent> <C-l> :wincmd l<CR>' >> $VIMRC
    echo '' >> $VIMRC
  fi

  if [ "$navigate_tabs_easily" = true ]; then
    echo '""" Use Tab and Shift-Tab to navigate tabs.' >> $VIMRC
    echo 'nmap <silent> <Tab> :tabnext<CR>' >> $VIMRC
    echo 'nmap <silent> <S-Tab> :tabprevious<CR>' >> $VIMRC
    echo '' >> $VIMRC
  fi

  if [ "$avoid_escape_key" = true ]; then
    echo "\"\"\" Use $escape_keymap to escape from insert mode." >> $VIMRC
    echo "imap <silent> $escape_keymap <ESC>" >> $VIMRC
    echo '' >> $VIMRC
  fi

  if [ "${#vim_plugins[@]}" -ne 0 ]; then
    echo '' >> $VIMRC
    echo '""" Plugins Configuration' >> $VIMRC
    echo '' >> $VIMRC
  fi

  if [ "$install_indentline" = true ]; then
    echo "\"\"\" $INDENTLINE" >> $VIMRC
    echo 'let g:indentLine_char = "▏"' >> $VIMRC
    echo 'let g:indentLine_color_term = 236' >> $VIMRC
    echo 'let g:indentLine_color_gui = "#303030"' >> $VIMRC
    echo '' >> $VIMRC
  fi

  if [ "$install_better_whitespace" = true ]; then
    echo "\"\"\" $BETTER_WHITESPACE" >> $VIMRC
    echo 'highlight ExtraWhitespace ctermbg=88 guibg=#8B0000' >> $VIMRC
    echo '' >> $VIMRC
  fi

  if [ "$install_gitgutter" = true ]; then
    echo "\"\"\" $GITGUTTER" >> $VIMRC
    echo 'set updatetime=200' >> $VIMRC
    echo 'set signcolumn=yes' >> $VIMRC
    echo 'hi SignColumn ctermbg=233 guibg=#121212' >> $VIMRC
    echo 'hi GitGutterAdd ctermfg=71 guifg=#7E955E' >> $VIMRC
    echo 'hi GitGutterChange ctermfg=68 guifg=#566FA3' >> $VIMRC
    echo 'hi GitGutterDelete ctermfg=1 guifg=#990000' >> $VIMRC
    echo 'let g:gitgutter_sign_added = "▌"' >> $VIMRC
    echo 'let g:gitgutter_sign_modified = "▌"' >> $VIMRC
    echo 'let g:gitgutter_sign_removed = "▁"' >> $VIMRC
    echo 'let g:gitgutter_sign_removed_first_line = "▔"' >> $VIMRC
    echo 'let g:gitgutter_sign_removed_above_and_below = "▌"' >> $VIMRC
    echo 'let g:gitgutter_sign_modified_removed = "▌"' >> $VIMRC
    echo 'function! GitGutterGitStatus()' >> $VIMRC
    echo '  let [a,m,r] = GitGutterGetHunkSummary()' >> $VIMRC
    if [ "$install_fugitive" = true ]; then
      echo 'if !get(g:, "gitgutter_enabled", 0)' >> $VIMRC
      echo '      \ || empty(FugitiveHead())' >> $VIMRC
      echo '      \ || winwidth(".") <= 75' >> $VIMRC
      echo '  return ""' >> $VIMRC
      echo 'endif' >> $VIMRC
    else
      echo 'if !get(g:, "gitgutter_enabled", 0)' >> $VIMRC
      echo '      \ || (a == 0 && m == 0 && r == 0)' >> $VIMRC
      echo '      \ || winwidth(".") <= 75' >> $VIMRC
      echo '  return ""' >> $VIMRC
      echo 'endif' >> $VIMRC
    fi
    echo '  return printf("+%d ~%d -%d", a, m, r)' >> $VIMRC
    echo 'endfunction' >> $VIMRC
    echo '' >> $VIMRC
  fi

  if [ "$install_lightline" = true ]; then
    echo "\"\"\" $LIGHTLINE" >> $VIMRC
    echo 'set laststatus=2' >> $VIMRC
    echo 'set noshowmode' >> $VIMRC
    echo 'let g:lightline = {' >> $VIMRC
    echo '      \ "active": {' >> $VIMRC
    echo '      \   "left": [["mode", "paste"],' >> $VIMRC

    if [ "$install_gitgutter" = true ]; then
      if [ "$install_fugitive" = true ]; then
        echo '      \            ["gitstatus", "gitbranch", "readonly", "filename", "modified"]],' >> $VIMRC
      else
        echo '      \            ["gitstatus", "readonly", "filename", "modified"]],' >> $VIMRC
      fi
    else
      if [ "$install_fugitive" = true ]; then
        echo '      \            ["gitbranch", "readonly", "filename", "modified"]],' >> $VIMRC
      else
        echo '      \            ["readonly", "filename", "modified"]],' >> $VIMRC
      fi
    fi
    echo '      \ },' >> $VIMRC

    echo '      \ "component_function": {' >> $VIMRC
    if [ "$install_fugitive" = true ]; then
      echo '      \   "gitbranch": "FugitiveHead",' >> $VIMRC
    fi
    if [ "$install_gitgutter" = true ]; then
      echo '      \   "gitstatus": "GitGutterGitStatus",' >> $VIMRC
    fi
    echo '      \ },' >> $VIMRC

    if [ "$install_onedark" = true ]; then
      echo '      \ "colorscheme": "onedark",' >> $VIMRC
    fi

    echo '      \ }' >> $VIMRC
    echo '' >> $VIMRC
  fi

  if [ "$install_easymotion" = true ]; then
    echo "\"\"\" $EASYMOTION" >> $VIMRC
    echo '""" Disable default mappings.' >> $VIMRC
    echo 'let g:EasyMotion_do_mapping = 0' >> $VIMRC
    echo '""" Search character.' >> $VIMRC
    echo 'map <Leader><Leader>s <Plug>(easymotion-s)' >> $VIMRC
    echo '""" Search 2 characters overwin.' >> $VIMRC
    echo 'map <Leader><Leader>S <Plug>(easymotion-overwin-f2)' >> $VIMRC
    echo '""" Search n-character.' >> $VIMRC
    echo 'map <Leader><Leader>/ <Plug>(easymotion-sn)' >> $VIMRC
    echo '""" Find character forwards.' >> $VIMRC
    echo 'map <Leader><Leader>f <Plug>(easymotion-f)' >> $VIMRC
    echo '""" Find character backwards.' >> $VIMRC
    echo 'map <Leader><Leader>F <Plug>(easymotion-F)' >> $VIMRC
    echo '""" Til character forwards.' >> $VIMRC
    echo 'map <Leader><Leader>t <Plug>(easymotion-t)' >> $VIMRC
    echo '""" Til character backwards.' >> $VIMRC
    echo 'map <Leader><Leader>T <Plug>(easymotion-T)' >> $VIMRC
    echo '""" Start of word forwards.' >> $VIMRC
    echo 'map <Leader><Leader>w <Plug>(easymotion-w)' >> $VIMRC
    echo '""" Start of WORD forwards.' >> $VIMRC
    echo 'map <Leader><Leader>W <Plug>(easymotion-W)' >> $VIMRC
    echo '""" Start of word backwards.' >> $VIMRC
    echo 'map <Leader><Leader>b <Plug>(easymotion-b)' >> $VIMRC
    echo '""" Start of WORD backwards.' >> $VIMRC
    echo 'map <Leader><Leader>B <Plug>(easymotion-B)' >> $VIMRC
    echo '""" End of word forwards.' >> $VIMRC
    echo 'map <Leader><Leader>e <Plug>(easymotion-e)' >> $VIMRC
    echo '""" End of WORD forwards.' >> $VIMRC
    echo 'map <Leader><Leader>E <Plug>(easymotion-E)' >> $VIMRC
    echo '""" End of word backwards.' >> $VIMRC
    echo 'map <Leader><Leader>ge <Plug>(easymotion-ge)' >> $VIMRC
    echo '""" End of WORD backwards.' >> $VIMRC
    echo 'map <Leader><Leader>gE <Plug>(easymotion-gE)' >> $VIMRC
    echo '""" Start of line forwards.' >> $VIMRC
    echo 'map <Leader><Leader>j <Plug>(easymotion-j)' >> $VIMRC
    echo '""" Start of line backwards.' >> $VIMRC
    echo 'map <Leader><Leader>k <Plug>(easymotion-k)' >> $VIMRC
    echo '""" Til character.' >> $VIMRC
    echo 'map <Leader><Leader><Leader>bdt <Plug>(easymotion-bd-t)' >> $VIMRC
    echo '""" Start of WORD.' >> $VIMRC
    echo 'map <Leader><Leader><Leader>bdw <Plug>(easymotion-bd-W)' >> $VIMRC
    echo '""" End of WORD.' >> $VIMRC
    echo 'map <Leader><Leader><Leader>bde <Plug>(easymotion-bd-E)' >> $VIMRC
    echo '""" Start of line.' >> $VIMRC
    echo 'map <Leader><Leader>bdjk <Plug>(easymotion-bd-bdjk)' >> $VIMRC
    echo '' >> $VIMRC
  fi

  if [ "$install_nerdtree" = true ]; then
    echo "\"\"\" $NERDTREE" >> $VIMRC
    echo '""" Use Ctrl-Shift-b to toggle NERDTree.' >> $VIMRC
    echo 'nmap <silent> <C-S-b> :NERDTreeToggle<CR>' >> $VIMRC
    echo '""" Exit Vim if NERDTree is the only window remaining in the only tab.' >> $VIMRC
    echo 'autocmd BufEnter * if tabpagenr("$") == 1 && winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree() | quit | endif' >> $VIMRC
    echo '""" Close the tab if NERDTree is the only window remaining in it.' >> $VIMRC
    echo 'autocmd BufEnter * if winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree() | quit | endif' >> $VIMRC
    if [ "$nerdtree_win_pos" = "right" ]; then
      echo '""" Put NERDTree window on the right side.' >> $VIMRC
      echo 'let NERDTreeWinPos="right"' >> $VIMRC
    fi
    echo '""" Remap keybindings.' >> $VIMRC
    echo 'let NERDTreeMapActivateNode="l"' >> $VIMRC
    echo 'let NERDTreeMapCloseDir="h"' >> $VIMRC
    echo 'let NERDTreeMapOpenSplit="s"' >> $VIMRC
    echo 'let NERDTreeMapOpenVSplit="v"' >> $VIMRC
    echo '' >> $VIMRC
  fi

  if [ "$install_whichkey" = true ]; then
    echo "\"\"\" $WHICHKEY" >> $VIMRC
    echo 'autocmd VimEnter * call which_key#register("<Space>", "g:which_key_map")' >> $VIMRC
    echo 'nmap <silent> <Space> :<C-u>WhichKey "<Space>"<CR>' >> $VIMRC
    echo 'let g:which_key_map = {' >> $VIMRC
    if [ "$install_nerdtree" = true ]; then
      echo '      \ "e": [":NERDTreeToggle", "Toggle NERDTree"],' >> $VIMRC
    fi
    echo '      \ "h": ["<C-w>s", "Split horizontally"],' >> $VIMRC
    echo '      \ "v": ["<C-w>v", "Split vertically"],' >> $VIMRC
    echo '      \ }' >> $VIMRC
    echo 'let g:which_key_map.w = {' >> $VIMRC
    echo '      \ "name": "Window...",' >> $VIMRC
    echo '      \ "=": ["<C-w>=", "Balance window"],' >> $VIMRC
    echo '      \ "d": ["<C-w>c", "Delete window"],' >> $VIMRC
    echo '      \ "h": ["<C-w>h", "Navigate window left"],' >> $VIMRC
    echo '      \ "j": ["<C-w>j", "Navigate window below"],' >> $VIMRC
    echo '      \ "k": ["<C-w>k", "Navigate window above"],' >> $VIMRC
    echo '      \ "l": ["<C-w>l", "Navigate window right"],' >> $VIMRC
    echo '      \ "H": ["<C-w>5<", "Expand window left"],' >> $VIMRC
    echo '      \ "J": [":resize +5", "Expand window down"],' >> $VIMRC
    echo '      \ "K": [":resize -5", "Expand window up"],' >> $VIMRC
    echo '      \ "L": ["<C-w>5>", "Expand window right"],' >> $VIMRC
    echo '      \ }' >> $VIMRC
    echo '' >> $VIMRC
  fi

  if [ "$use_rulers" = true ]; then
    echo
    echo "[INFO] Setup rulers for git, python, javascript and cpp."
    mkdir -p $VIM_FTPLUGIN
    # For git.
    echo 'hi ColorColumn ctermbg=234 guibg=#1C1C1C' >> $FTPLUGIN_GIT
    echo 'let &colorcolumn="51,".join(range(73,999),",")' >> $FTPLUGIN_GIT
    # For python.
    echo 'hi ColorColumn ctermbg=234 guibg=#1C1C1C' >> $FTPLUGIN_PYTHON
    echo 'let &colorcolumn="73,".join(range(80,999),",")' >> $FTPLUGIN_PYTHON
    # For javascript.
    echo 'hi ColorColumn ctermbg=234 guibg=#1C1C1C' >> $FTPLUGIN_JAVASCRIPT
    echo 'set colorcolumn=101' >> $FTPLUGIN_JAVASCRIPT
    # For cpp.
    echo 'hi ColorColumn ctermbg=234 guibg=#1C1C1C' >> $FTPLUGIN_C
    echo 'set colorcolumn=121' >> $FTPLUGIN_C
  fi
}

function install_vim_plugin() {
  local via="$1"
  local url="$2"
  local vim_plugins_dir="$3"
  local plugin_dirname="$4"
  local add_helptags="$5"

  cd "$vim_plugins_dir"
  case "$via" in
    "git")
      git clone "$url" "$vim_plugins_dir/$plugin_dirname"
    ;;
    "wget")
      wget --no-check-certificate --content-disposition "$url" -O "$plugin_dirname.tar.gz"
      mkdir -p "$vim_plugins_dir/$plugin_dirname"
      tar -xzf "$plugin_dirname.tar.gz" -C "$plugin_dirname" --strip-components=1
      rm "$plugin_dirname.tar.gz"
    ;;
    "curl")
      curl -LJ "$url" -o "$plugin_dirname.tar.gz"
      mkdir -p "$vim_plugins_dir/$plugin_dirname"
      tar -xzf "$plugin_dirname.tar.gz" -C "$plugin_dirname" --strip-components=1
      rm "$plugin_dirname.tar.gz"
    ;;
  esac
  if [ "$add_helptags" = true ]; then
    vim -u NONE -c "helptags $vim_plugins_dir/$plugin_dirname/doc" -c q
  fi
}

function install_vim_plugins_via() {
  local via="$1"

  if [ "$via" = "git" ]; then
    if [ "$install_onedark" = true ]; then
      echo
      echo "[INFO] Installing Vim plugin: $ONEDARK..."
      install_vim_plugin "$via" "$ONEDARK_GIT_URL" "$VIM_PLUGINS_OPT_DIR" "$ONEDARK" false
    fi

    if [ "$install_lightline" = true ]; then
      echo
      echo "[INFO] Installing Vim plugin: $LIGHTLINE..."
      install_vim_plugin "$via" "$LIGHTLINE_GIT_URL" "$VIM_PLUGINS_START_DIR" "$LIGHTLINE" false
    fi

    if [ "$install_indentline" = true ]; then
      echo
      echo "[INFO] Installing Vim plugin: $INDENTLINE..."
      install_vim_plugin "$via" "$INDENTLINE_GIT_URL" "$VIM_PLUGINS_START_DIR" "$INDENTLINE" false
    fi

    if [ "$install_easymotion" = true ]; then
      echo
      echo "[INFO] Installing Vim plugin: $EASYMOTION..."
      install_vim_plugin "$via" "$EASYMOTION_GIT_URL" "$VIM_PLUGINS_START_DIR" "$EASYMOTION" true
    fi

    if [ "$install_whichkey" = true ]; then
      echo
      echo "[INFO] Installing Vim plugin: $WHICHKEY..."
      install_vim_plugin "$via" "$WHICHKEY_GIT_URL" "$VIM_PLUGINS_START_DIR" "$WHICHKEY" true
    fi

    if [ "$install_gitgutter" = true ]; then
      echo
      echo "[INFO] Installing Vim plugin: $GITGUTTER..."
      install_vim_plugin "$via" "$GITGUTTER_GIT_URL" "$VIM_PLUGINS_START_DIR" "$GITGUTTER" true
    fi

    if [ "$install_fugitive" = true ]; then
      echo
      echo "[INFO] Installing Vim plugin: $FUGITIVE..."
      install_vim_plugin "$via" "$FUGITIVE_GIT_URL" "$VIM_PLUGINS_START_DIR" "$FUGITIVE" true
    fi

    if [ "$install_better_whitespace" = true ]; then
      echo
      echo "[INFO] Installing Vim plugin: $BETTER_WHITESPACE..."
      install_vim_plugin "$via" "$BETTER_WHITESPACE_GIT_URL" "$VIM_PLUGINS_START_DIR" "$BETTER_WHITESPACE" false
    fi

    if [ "$install_nerdtree" = true ]; then
      echo
      echo "[INFO] Installing Vim plugin: $NERDTREE..."
      install_vim_plugin "$via" "$NERDTREE_GIT_URL" "$VIM_PLUGINS_START_DIR" "$NERDTREE" true
    fi

    if [ "$install_devicons" = true ]; then
      echo
      echo "[INFO] Installing Vim plugin: $DEVICONS..."
      install_vim_plugin "$via" "$DEVICONS_GIT_URL" "$VIM_PLUGINS_START_DIR" "$DEVICONS" false
    fi
  else
    if [ "$install_onedark" = true ]; then
      echo
      echo "[INFO] Installing Vim plugin: $ONEDARK..."
      install_vim_plugin "$via" "$ONEDARK_URL" "$VIM_PLUGINS_OPT_DIR" "$ONEDARK" false
    fi

    if [ "$install_lightline" = true ]; then
      echo
      echo "[INFO] Installing Vim plugin: $LIGHTLINE..."
      install_vim_plugin "$via" "$LIGHTLINE_URL" "$VIM_PLUGINS_START_DIR" "$LIGHTLINE" false
    fi

    if [ "$install_indentline" = true ]; then
      echo
      echo "[INFO] Installing Vim plugin: $INDENTLINE..."
      install_vim_plugin "$via" "$INDENTLINE_URL" "$VIM_PLUGINS_START_DIR" "$INDENTLINE" false
    fi

    if [ "$install_easymotion" = true ]; then
      echo
      echo "[INFO] Installing Vim plugin: $EASYMOTION..."
      install_vim_plugin "$via" "$EASYMOTION_URL" "$VIM_PLUGINS_START_DIR" "$EASYMOTION" true
    fi

    if [ "$install_whichkey" = true ]; then
      echo
      echo "[INFO] Installing Vim plugin: $WHICHKEY..."
      install_vim_plugin "$via" "$WHICHKEY_URL" "$VIM_PLUGINS_START_DIR" "$WHICHKEY" true
    fi

    if [ "$install_gitgutter" = true ]; then
      echo
      echo "[INFO] Installing Vim plugin: $GITGUTTER..."
      install_vim_plugin "$via" "$GITGUTTER_URL" "$VIM_PLUGINS_START_DIR" "$GITGUTTER" true
    fi

    if [ "$install_fugitive" = true ]; then
      echo
      echo "[INFO] Installing Vim plugin: $FUGITIVE..."
      install_vim_plugin "$via" "$FUGITIVE_URL" "$VIM_PLUGINS_START_DIR" "$FUGITIVE" true
    fi

    if [ "$install_better_whitespace" = true ]; then
      echo
      echo "[INFO] Installing Vim plugin: $BETTER_WHITESPACE..."
      install_vim_plugin "$via" "$BETTER_WHITESPACE_URL" "$VIM_PLUGINS_START_DIR" "$BETTER_WHITESPACE" false
    fi

    if [ "$install_nerdtree" = true ]; then
      echo
      echo "[INFO] Installing Vim plugin: $NERDTREE..."
      install_vim_plugin "$via" "$NERDTREE_URL" "$VIM_PLUGINS_START_DIR" "$NERDTREE" true
    fi

    if [ "$install_devicons" = true ]; then
      echo
      echo "[INFO] Installing Vim plugin: $DEVICONS..."
      install_vim_plugin "$via" "$DEVICONS_URL" "$VIM_PLUGINS_START_DIR" "$DEVICONS" false
    fi
  fi
}

function confirm_vim_config() {
  if confirm "Would you like to accept Vim switch cursor style automatically (line when insert and block when others)?"; then
    auto_switch_cursor_style=true
  fi

  if confirm "Would you like to navigate between windows (panes) by using Ctrl-[hjkl]?"; then
    navigate_windows_easily=true
  fi

  if confirm "Would you like to navigate tabs by using Tab and Shift-Tab?"; then
    navigate_tabs_easily=true
  fi

  if confirm "Would you like to use rulers (column guides)?"; then
    use_rulers=true
  fi

  if confirm "Would you like to use jk, jj or kj to escape from insert mode?"; then
    while [ -z "$escape_keymap" ]; do
      echo
      echo "Which keymap would you like to use to escape from insert mode?"
      read -p "jk, jj or kj (default will not map any key to the escape key): " -r answer
      case "$answer" in
        "jk" | "jj" | "kj")
          avoid_escape_key=true
          escape_keymap="$answer"
        ;;
        *[[:blank:]]* | "")
          avoid_escape_key=false
          escape_keymap="no"
        ;;
        *)
          echo "[ERROR] Not supported: $answer"
        ;;
      esac
    done
  fi
}

function confirm_vim_plugin() {
  if confirm "Would you like to install $ONEDARK - A dark color scheme for Vim?"; then
    install_onedark=true
    vim_plugins+=("$ONEDARK")
  fi

  if confirm "Would you like to install $LIGHTLINE - A configurable statusline plugin for Vim?"; then
    install_lightline=true
    vim_plugins+=("$LIGHTLINE")
  fi

  if confirm "Would you like to install $INDENTLINE - Displays the indention levels with vertical line?"; then
    install_indentline=true
    vim_plugins+=("$INDENTLINE")
  fi

  if confirm "Would you like to install $EASYMOTION - Provides simpler way to use some motion in Vim?"; then
    install_easymotion=true
    vim_plugins+=("$EASYMOTION")
  fi

  if confirm "Would you like to install $WHICHKEY - Dispalys available keybindings in popup?"; then
    install_whichkey=true
    vim_plugins+=("$WHICHKEY")
  fi

  if confirm "Would you like to install $GITGUTTER - Shows a git diff in the sign column?"; then
    install_gitgutter=true
    vim_plugins+=("$GITGUTTER")
  fi

  if confirm "Would you like to install $FUGITIVE - A plugin to work with Git in Vim?"; then
    install_fugitive=true
    vim_plugins+=("$FUGITIVE")
  fi

  if confirm "Would you like to install $BETTER_WHITESPACE - Highlight trailing whitespaces?"; then
    install_better_whitespace=true
    vim_plugins+=("$BETTER_WHITESPACE")
  fi

  if confirm "Would you like to install $NERDTREE - A file system explorer for Vim editor?"; then
    install_nerdtree=true
    vim_plugins+=("NERDTree")
    while [ -z "$nerdtree_win_pos" ]; do
      echo
      echo "Where to put the NERDTree window?"
      read -p "[l]eft or [r]ight (default: right): " -r answer
      case "$answer" in
        "l" | "L" | "left" | "Left" | "LEFT")
          nerdtree_win_pos="left"
        ;;
        "r" | "R" | "right" | "Right" | "RIGHT" | *[[:blank:]]* | "")
          nerdtree_win_pos="right"
        ;;
        *)
          echo "[ERROR] Not supported: $answer"
        ;;
      esac
    done
    # Plugins for NERDTree.
    if confirm "Would you like to install $DEVICONS - Adds file type icons to NERDTree?"; then
      install_devicons=true
      vim_plugins+=("$DEVICONS")
    fi
  fi
}

function init() {
  verify_sudo
  verify_vim
  confirm_vim_config
  confirm_vim_plugin

  if [ "${#vim_plugins[@]}" -ne 0 ]; then
    while [ -z "$vim_plugins_installer" ]; do
      echo
      echo "Which tool would you like to use to install Vim plugins?"
      read -p "git, wget or curl (default: git): " -r answer
      case "$answer" in
        "git" | "Git" | "GIT" | *[[:blank:]]* | "")
          verify_git
          vim_plugins_installer="git"
        ;;
        "wget" | "Wget" | "WGET")
          verify_wget
          vim_plugins_installer="wget"
        ;;
        "curl" | "Curl" | "CURL")
          verify_curl
          vim_plugins_installer="curl"
        ;;
        *)
          echo "[ERROR] Not supported: $answer"
        ;;
      esac
    done
  fi
}

function show_comments() {
  if [ "$install_easymotion" = true ]; then
    echo
    echo "vim-easymotion - Provides simpler way to use some motion in Vim"
    echo "==============================================================="
    echo "The leader key is '\'."
    echo "- <Leader><Leader>s: search by a character."
    echo "- <Leader><Leader>S: search by two characters over window."
    echo "- <Leader><Leader>/: search by n-character."
    echo "- <Leader><Leader>j: start of line forwards."
    echo "- <Leader><Leader>k: start of line backwards."
    echo "- <Leader><Leader><Leader>bdw: start of WORD."
    echo "- <Leader><Leader><Leader>bde: end of WORD."
    echo "See the '$EASYMOTION' section in $VIMRC to get more information."
  fi

  if [ "$install_nerdtree" = true ]; then
    echo
    echo "NERDTree - A file system explorer for Vim editor"
    echo "================================================"
    echo "- Use Ctrl-Shift-b to toggle explorer in normal mode."
    echo "- In NERDTree window:"
    echo "  - l: open a file or open/close a directory."
    echo "  - h: close the parent directory."
    echo "  - s: open a file in a new split window horizontally."
    echo "  - v: open a file in a new split window vertically."
    echo "  - t: open in a new tab."
    echo "  - p: go to parent"
    echo "  - C: change tree root to the selected directory."
    echo "  - u: move tree root up a directory."
    echo "  - I: toggle whether hidden files are displayed."
    echo "  - q: close the NERDTree window."
    echo "  - m: show menu"
    echo "    - a: add a file or directory. Directory should end with a '/'."
    echo "    - m: move/rename the current file or directory."
    echo "    - d: delete the current file or directory."
    echo "    - c: copy the current file or directory."
    echo "Press '?' in NERDTree window to get more information."
  fi

  if [ "$install_whichkey" = true ]; then
    echo
    echo "vim-which-key - Dispalys available keybindings in popup"
    echo "======================================================="
    echo "- Press 'Space' to open popup."
    echo "  Then press the following key (Ctrl-c to cancel):"
    if [ "$install_nerdtree" = true ]; then
      echo "  - e: toggle NERDTree."
    fi
    echo "  - h: split horizontally."
    echo "  - v: split vertically."
    echo "  - w: window..."
    echo "    - =: balance window"
    echo "    - d: delete window"
    echo "Open vim-which-key popup to get more information."
  fi
}

function run() {
  init

  # Show what will this customization do to user.
  echo
  echo "This customization will do the following things:"
  if [ "${#dependencies[@]}" -ne 0 ]; then
    echo "  - Install dependencies: ${dependencies[*]}"
  fi
  if [ "$need_upgrade_vim" = true ]; then
    echo "  - Upgrade dependencies: vim"
  fi
  if [ -d "$VIM" ] && [ -d "$VIM_BACKUP" ]; then
    echo "  - Remove 'backup.vim' folder: rm -rf $VIM_BACKUP"
  fi
  if [ -f "$VIMRC" ] && [ -f "$VIMRC_BACKUP" ]; then
    echo "  - Remove 'backup.vimrc' file: rm $VIMRC_BACKUP"
  fi
  if [ -d "$VIM" ]; then
    echo "  - Backup '.vim' folder: mv $VIM $VIM_BACKUP"
  fi
  if [ -f "$VIMRC" ]; then
    echo "  - Backup Vim configuration file: mv $VIMRC $VIMRC_BACKUP"
  fi
  if [ "${#vim_plugins[@]}" -ne 0 ]; then
    echo "  - Create directory: $VIM"
  fi
  echo "  - Create Vim configuration file: $VIMRC"
  if [ "${#vim_plugins[@]}" -ne 0 ]; then
    echo "  - Install Vim plugins: ${vim_plugins[*]}"
  fi

  # Confirm if user want to run this customization.
  if confirm_exactly "Would you like to run this customization?"; then
    # Install dependencies.
    install_dependencies

    # Upgrade Vim.
    upgrade_vim

    # Remove old backup.
    if [ -d "$VIM" ] && [ -d "$VIM_BACKUP" ]; then
      echo
      echo "[INFO] Remove old backup: $VIM_BACKUP"
      rm -rf $VIM_BACKUP
    fi
    if [ -f "$VIMRC" ] && [ -f "$VIMRC_BACKUP" ]; then
      echo
      echo "[INFO] Remove old backup: $VIMRC_BACKUP"
      rm -f $VIMRC_BACKUP
    fi

    # Backup.
    if [ -d "$VIM" ]; then
      echo
      echo "[INFO] Backup: mv $VIM $VIM_BACKUP"
      mv $VIM $VIM_BACKUP
    fi
    if [ -f "$VIMRC" ]; then
      echo
      echo "[INFO] Backup: mv $VIMRC $VIMRC_BACKUP"
      mv $VIMRC $VIMRC_BACKUP
    fi

    # Create '.vim' folder.
    echo
    echo "[INFO] Create '$VIM'."
    if [ "${#vim_plugins[@]}" -ne 0 ]; then
      mkdir -p "$VIM_PLUGINS_START_DIR"
      mkdir -p "$VIM_PLUGINS_OPT_DIR"
    fi

    # Configure Vim.
    config_vim

    # Install Vim plugins.
    if [ "${#vim_plugins[@]}" -ne 0 ]; then
      install_vim_plugins_via "$vim_plugins_installer"
    fi
  fi

  show_comments
  verify_vim
  echo
}

run
