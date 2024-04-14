#!/bin/bash
# shellcheck disable=SC1091

#==================================
# Source utilities
#==================================
. "$HOME/.dotfiles/scripts/utils/utils.sh"

os_name="$(get_os)"

#==================================
# Helpers
#==================================
create_symlink() {
  declare -r IS_HIDDEN="$3"
  declare -r DIRECTORY="$2"
  declare -r SYMLINK="$1"

  local sourceFile=""
  local targetFile=""

  sourceFile="$(cd ../../src/ && pwd)/$SYMLINK"

  if $IS_HIDDEN "==" true; then
    targetFile="$DIRECTORY/.$SYMLINK"
  else
    targetFile="$DIRECTORY/$SYMLINK"
  fi

  if [ ! -e "$targetFile" ]; then
    execute "ln -fs $sourceFile $targetFile" "$targetFile → $sourceFile"
  elif [ "$(readlink "$targetFile")" == "$sourceFile" ]; then
    print_success "$targetFile → $sourceFile"
  else
    ask_for_confirmation "'$targetFile' already exists, do you want to overwrite it?"
    if answer_is_yes; then
      rm -rf "$targetFile"
      execute "ln -fs $sourceFile $targetFile" "$targetFile → $sourceFile"
    else
      print_error "$targetFile → $sourceFile"
    fi
  fi
}

create_directories() {
  declare -a DIRECTORIES=(
    "$HOME/.config"
    "$HOME/.ssh"
    "$HOME/.local/bin"
    "$HOME/.local/bin/statusbar"
    "$HOME/.local/bin/dmenu"
    "$HOME/.local/src"
    "$HOME/.local/share"
    "$HOME/.local/share/lyrics"
    "$HOME/.cache/mpd"
    "$HOME/.local/share/mpd"
    "$HOME/.local/share/mines"
    "$HOME/.cache/zsh"
    "$HOME/projects"
    "$HOME/projects/laravel"
    "$HOME/Downloads/torrents"
    "$HOME/Pictures/screenshots"
  )

  for i in "${DIRECTORIES[@]}"; do
    execute "mkd $i" "create $i"
  done
}

local_bin_symlink() {
  declare -a LOCAL_FILES_TO_SYMLINK=(
    "bin/ext"
    "bin/get_chars"
    "bin/getkeys"
    "bin/ifinstalled"
    "bin/pauseallmpv"
    "bin/rotdir"
    "bin/rssadd"
    "bin/setbg"
    "bin/shortcuts"
    "bin/startw"
    "bin/transadd"
    "bin/unix"

    "bin/dmenu/mounter"
    "bin/dmenu/sysact"
    "bin/dmenu/td-toggle"
    "bin/dmenu/torwrap"
    "bin/dmenu/unmounter"
    "bin/dmenu/handler"
    "bin/dmenu/mountcifs"
    "bin/dmenu/bemenupass"
    "bin/dmenu/unicode"
    "bin/dmenu/wifi"
    "bin/dmenu/screenshot"
    "bin/dmenu/prompt"

    "bin/statusbar/sb-battery"
    "bin/statusbar/sb-clock"
    "bin/statusbar/sb-cpu"
    "bin/statusbar/sb-internet"
    "bin/statusbar/sb-memory"
    "bin/statusbar/sb-mpdup"
    "bin/statusbar/sb-music"
    "bin/statusbar/sb-packages"
    "bin/statusbar/sb-torrent"
    "bin/statusbar/sb-volume"

    "share/wallpapers"
    "share/fonts"
    "share/themes"
    "share/mines/chars"
    "share/mines/getkeys"
  )

  for i in "${LOCAL_FILES_TO_SYMLINK[@]}"; do
    create_symlink "$i" "$HOME/.local" false
  done
}

config_symlink() {
  declare -a CONFIG_FILES_TO_SYMLINK=(
    "config/bat"
    "config/bemenu"
    "config/fd"
    "config/firefox"
    "config/fontconfig"
    "config/foot"
    "config/gammastep"
    "config/gh"
    "config/git"
    "config/gtk-2.0"
    "config/gtk-3.0"
    "config/htop"
    "config/imv"
    "config/lf"
    "config/mako"
    "config/mpd"
    "config/mpv"
    "config/ncmpcpp"
    "config/networkmanager-dmenu"
    "config/newsboat"
    "config/nvim"
    "config/pipewire"
    "config/pulse"
    "config/rg"
    "config/shell"
    "config/swappy"
    "config/swaylock"
    "config/tmux"
    "config/topgrade"
    "config/ttyper"
    "config/wget"
    "config/zathura"
    "config/zsh"
    "config/mimeapps.list"
  )

  for i in "${CONFIG_FILES_TO_SYMLINK[@]}"; do
    create_symlink "$i" "$HOME" true
  done
}

desktop_symlink() {
  execute "rm -rf \
	  $HOME/.zshenv \
	  $HOME/.luarc.json \
	  $HOME/.gitignore \
	  $HOME/.stylua.toml \
	  $HOME/.editorconfig \
	  $HOME/.gitconfig \
	  $HOME/.gitconfig.local"

  execute "ln -sf $HOME/.dotfiles/src/config/zsh/zshenv $HOME/.zshenv"
  execute "ln -sf $HOME/.dotfiles/src/luarc.json $HOME/.luarc.json"
  execute "ln -sf $HOME/.dotfiles/src/stylua.toml $HOME/.stylua.toml"
  execute "ln -sf $HOME/.dotfiles/src/ignore $HOME/.ignore"
  execute "ln -sf $HOME/.dotfiles/src/editorconfig $HOME/.editorconfig"
  execute "ln -sf $HOME/.config/git/config $HOME/.gitconfig"
  execute "ln -sf $HOME/.config/git/config.local $HOME/.gitconfig.local"

  execute "source $HOME/.config/zsh/zshenv"
  execute "source $HOME/.config/zsh/.zshrc"
}

#==================================
# Main
#==================================
print_title 'Creating directories'
create_directories

print_title "local symlink"
local_bin_symlink

print_title "config symlink"
config_symlink

print_title "home directory symlink"
desktop_symlink

print_title "create mpd file"
execute "touch $HOME/.local/share/mpd/mpd.db" "create mpd file"
