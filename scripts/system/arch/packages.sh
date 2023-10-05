#!/bin/bash
# shellcheck disable=SC1091

#==================================
# Source utilities
#==================================
. "$DOTFILES_DIR/scripts/utils/utils.sh"
. "$DOTFILES_DIR/scripts/utils/arch.sh"

#==================================
# Helpers
#==================================
install_aur_helper() {
  print_title "Install AUR Helper"
  if ! cmd_exists "yay"; then
    rm -rf ~/tmp/yay
    execute "git clone --quiet https://aur.archlinux.org/yay.git ~/tmp/yay" "Cloning yay"
    cd ~/tmp/yay || exit
    execute "makepkg -sfci --noconfirm --needed" "Building yay"
  else
    print_warning "An aur helper is already installed"
  fi
}

install_flatpack() {
  if ! cmd_exists "flatpak"; then
    print_title "Install Flatpak"
    pacman_install "flatpak" "flatpak"
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo >/dev/null 2>&1
  fi
}

rust_development() {
  print_title "Rust Development"
  create_directory "$HOME/.local/share/cargo"
  install_rustup
  install_rust_toolchain "stable"
}

install_pacman_packages() {
  print_title "Installing pacman packages"
  pacman_install "polkit" "polkit: Manages user policies."
  pacman_install "gnome-keyring" "gnome-keyring: Serves as the system keyring."
  pacman_install "bc" "bc: Mathematics language used for the dropdown calculator."
  pacman_install "calcurse" "calcurse: Terminal-based organizer"
  pacman_install "libnotify" "libnotify: Allows desktop notifications."
  pacman_install "dosfstools" "dosfstools: Allows your computer to access dos-like filesystems."
  pacman_install "exfat-utils" "exfat-utils: Allows management of FAT drives."
  pacman_install "atool" "atool: Manages and gives information about archives."
  pacman_install "unzip" "unzip: Unzips zips."
  pacman_install "ntfs-3g" "ntfs-3g: Allows accessing NTFS partitions."
  pacman_install "man-db" "man-db: Lets you read man pages of programs."
  pacman_install "ffmpeg" "ffmpeg: Can record and splice video and audio on the command line."
  pacman_install "ffmpegthumbnailer" "ffmpegthumbnailer: Creates thumbnail previews of video files."
  pacman_install "mpd" "mpd: Lightweight music daemon."
  pacman_install "mpc" "mpc: Is a terminal interface for mpd."
  pacman_install "mpv" "mpv: Is the patrician's choice video player."
  pacman_install "ncmpcpp" "ncmpcpp: TUI for music with multiple formats"
  pacman_install "mediainfo" "mediainfo: Shows audio and video information"
  pacman_install "newsboat" "newsboat: TUI RSS client."
  pacman_install "lynx" "lynx: TUI browser"
  pacman_install "yt-dlp" "yt-dlp: Can download any YouTube video (or playlist or channel)"
  pacman_install "zathura" "zathura: TUI pdf viewer with vim-like bindings."
  pacman_install "zathura-pdf-mupdf" "zathura-pdf-mupdf: Allows mupdf pdf compatibility in zathura."
  pacman_install "poppler" "poppler: Manipulates .pdfs and gives"
  pacman_install "fzf" "fzf: Fuzzy finder tool"
  pacman_install "eza" "eza: A modern replacement for ls (community fork of exa)"
  pacman_install "bat" "bat: Can highlight code output and display files"
  pacman_install "socat" "socat: Multipurpose relay"
  pacman_install "moreutils" "moreutils: Collection of useful unix tools."
  pacman_install "wireplumber" "wireplumber: Audio system."
  pacman_install "pipewire-pulse" "pipewire-pulse: Compatibility with PulseAudio programs."
  pacman_install "pulsemixer" "pulsemixer: Audio controller"
  pacman_install "imv" "imv: Minimalist image viewer."
  pacman_install "kitty" "kitty: A modern, hackable, featureful, OpenGL-based terminal emulator"
  pacman_install "dunst" "dunst: Suckless notification system."
  pacman_install "pass" "pass: Stores, retrieves, generates, and synchronizes passwords securely"
  pacman_install "curl" "curl: command line tool and library for transferring data with URLs"
  pacman_install "wget" "wget: Network utility to retrieve files from the Web"
  pacman_install "python3" "python3: Next generation python high level scripting language"
  pacman_install "jq" "jq: Command-line JSON processor"
  pacman_install "tmux" "tmux: Terminal multiplexer"
  pacman_install "less" "less: A terminal based program for viewing text files"
  pacman_install "fd" "fd: Simple, fast and user-friendly alternative to find"
  pacman_install "ripgrep" "ripgrep: A search tool that combines the usability of ag with the raw speed of grep"
  pacman_install "httpie" "httpie: human-friendly CLI HTTP client for the API era"
  pacman_install "tldr" "tldr: Command line client for tldr, a collection of simplified and community-driven man pages."
  pacman_install "neofetch" "neofetch: A CLI system information tool written in BASH that supports displaying images."
  pacman_install "transmission-cli" "transmission-cli: BitTorrent client (CLI tools, daemon and web client)"
  pacman_install "gammastep" "gammastep: Adjust the color temperature of your screen according to your surroundings."
  pacman_install "bemenu" "bemenu: Dynamic menu library and client program inspired by dmenu"
  pacman_install "zoxide" "zoxide: A smarter cd command for your terminal"
  pacman_install "wlroots" "wlroots: Modular Wayland compositor library"
  pacman_install "wtype" "wtype: Xdotool for wayland"
  pacman_install "wayland-protocols" "wayland-protocols: Specifications of extended wayland protocols"
  pacman_install "wl-clipboard" "wl-clipboard: Command-line copy/paste utilities for Wayland"
  pacman_install "foot" "foot: Fast, lightweight, and minimalistic Wayland terminal emulator"
  pacman_install "grim" "grim: Screenshot utility for Wayland"
  pacman_install "swappy" "swappy: A Wayland native snapshot editing tool"
  pacman_install "slurp" "slurp: Select a region in a Wayland compositor"
  pacman_install "light" "light: Program to easily change brightness on backlight-controllers."
  pacman_install "github-cli" "github-cli: Github cli"
  pacman_install "tllist" "tllist: A typed linked c header file (for dwlb )"
  pacman_install "sheldon" "sheldon: A fast and configurable shell pluggin manager"
  pacman_install "git-delta" "git-delta: Syntax highlighting pager for git and diff output"
  pacman_install "bob" "bob: A fast and configurable shell pluggin manager"
}

install_aur_packages() {
  print_title "Installing aur packages"
  aur_install "lf-git" "lf-git: Extensive TUI file manager that everyone likes."
  aur_install "librewolf-bin" "librewolf-bin: Community fork or firefox which also comes with ad-blocking and other sensible and necessary features by default."
  aur_install "arkenfox-user.js" "arkenfox-user.js: provides hardened security settings for Firefox and Librewolf to avoid Mozilla spyware and general web fingerprinting."
  aur_install "sc-im" "sc-im: Excel-like terminal spreadsheet manager."
  aur_install "abook" "abook: offline addressbook usable by neomutt."
  aur_install "task-spooler" "task-spooler: queues commands or files for download."
  aur_install "simple-mtpfs" "simple-mtpfs: enables the mounting of cell phones."
  aur_install "htop-vim" "htop-vim: graphical and colorful system monitor."
  aur_install "tremc-git" "tremc-git: Curses interface for transmission - python3 fork of transmission-remote-cli"
  aur_install "networkmanager-dmenu-git" "networkmanager-dmenu-git: Control NetworkManager via dmenu"
  aur_install "wbg" "wbg: Wallpaper application for wlroots based Wayland compositors"
  aur_install "pamixer" "pamixer: Pulseaudio command-line mixer like amixer"
  aur_install "clipman" "clipman: clipboard manager for Wayland"
  aur_install "wl-color-picker" "wl-color-picker: A wayland color picker that also works on wlroots"
  aur_install "wlr-randr" "wlr-randr: Utility to manage outputs of a Wayland compositor"
  aur_install "nvm" "nvm: Node Version Manager - bash script to manage multiple active node.js version"

  # Themes, Icons, Cursor & Fonts
  aur_install "gtk-theme-arc-gruvbox-git" "gtk-theme-arc-gruvbox-git: dark GTK theme"
  aur_install "whitesur-icon-theme" "whitesur-icon-theme: MacOS Big Sur like icon theme for linux desktops"
  aur_install "whitesur-cursor-theme-git" "whitesur-cursor-theme-git: WhiteSur cursors theme for linux desktops"
  aur_install "whitesur-gtk-theme" "whitesur-gtk-theme: A macOS BigSur-like theme for your GTK apps"
}

install_git_packages() {
  print_title "Installing build Packages"

  for x in dwl dwlb somebar someblocks; do
    local directory="$HOME/.local/src/$x"
    [ -d "$directory" ] && rm -rf "$directory"

    git_install "https://github.com/vivi870123/$x.git"
  done
}

### This is how everything happens in an intuitive format and order.

#==================================
# Main Flow
#==================================
print_section "Package installation"

# Refresh Keys
print_title "Refresh keys"
refresh_keys

# Update pacman
print_title "Updating packages"
pacman_synchronize

#==================================
# Package Installation
#==================================
install_pacman_packages
install_flatpack
install_aur_packages
install_git_packages
