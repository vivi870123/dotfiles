#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Build Essentials\n\n"

# Install tools for compiling/building software from source.
install_package "Build Essential" "build-essential"

# GnuPG archive keys of the Debian archive.
install_package "GnuPG archive keys" "debian-archive-keyring"

# Software which is not included by default
# in Ubuntu due to legal or copyright reasons.
# install_package "Ubuntu Restricted Extras" "ubuntu-restricted-extras"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Installing Packages\n\n"

install_package "Python" "python"
install_package "Python pip" "python-pip"
install_package "python3 pip" "python3-pip"
install_package "Preload" "preload"
install_package "gcc" "gcc"
install_package "g++" "g++"
install_package "make" "make"
install_package "cmake" "cmake"
install_package "sed" "sed"
install_package "ninja-build" "ninja-build"
install_package "rsync" "rsync"
install_package "libxml2-utils" "libxml2-utils"
install_package "dateutils" "dateutils"
install_package "autoconf" "autoconf"
install_package "automake" "automake"
install_package "software-properties-common" "software-properties-common"
install_package "delta" "delta"
install_package "git" "git"
install_package "lazygit" "lazygit"
install_package "wget" "wget"
install_package "curl" "curl"
install_package "xclip" "xclip"
install_package "ripgrep" "ripgrep"
install_package "bat" "bat"
install_package "thefuck" "thefuck"
install_package "zoxide" "zoxide"
install_package "exa" "exa"
install_package "unzip" "unzip"
install_package "unrar" "unrar"
install_package "atool" "atool"
install_package "trash" "trash-cli"
install_package "ufw" "ufw"
install_package "zsh" "zsh"
install_package "tmux" "tmux"
install_package "tmux-plugin-manager"
install_package "sxiv" "sxiv"
install_package "newsboat" "newsboat"
install_package "ffmpeg" "ffmpeg"
install_package "mediainfo" "mediainfo"
install_package "mpv" "mpv"
install_package "zathura" "zathura"
install_package "zathura pdf plugin" "zathura-pdf-poppler"
install_package "poppler utils" "poppler-utils"
install_package "highlight" "highlight"
install_package "task spooler" "task-spooler"
install_package "transmission" "transmission-gtk"
install_package "cmus" "cmus"
install_package "jq" "jq"
install_package "composer" "composer"
install_package "odttotext" "odttotext"
install_package "docxtotext" "docxtotext"
install_package "ctags" "exuberant-ctags"
install_package "shellcheck" "shellcheck"
