#!/bin/bash
# shellcheck disable=SC1091

#==================================
# Source utilities
#==================================
. "$HOME/.dotfiles/scripts/utils/utils.sh"
. "$HOME/.dotfiles/scripts/utils/arch.sh"

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

# w3m: for html files

install_pacman_packages() {
    print_title "Installing pacman packages"

    pacman_install "libnotify" "libnotify: Allows desktop notifications."
    pacman_install "tllist" "tllist: A typed linked c header file"
    pacman_install "libgit2" "libgit - A linkable library for git"

    pacman_install "w3m" "Text-based Web browser as well as pager"
    pacman_install "lynx" "lynx: TUI browser"
    pacman_install "glow" "glow: Command-line markdown renderer"
    pacman_install "chafa" "chafa:  Image-to-text converter supporting a wide range of symbols and palettes, transparency, animations, etc."
    pacman_install "perl-image-exiftool" "Reader and rewriter of EXIF information that supports raw files"
    pacman_install "atool" "atool: Manages and gives information about archives."
    pacman_install "fontforge" "Full-featured outline and bitmap font editor."
    pacman_install "unrar" "unrar: the RAR uncompression program"
    pacman_install "tar" "tarL utility used to store, backup, and transport files"
    pacman_install "unzip" "unzip: Unzips zips."
    pacman_install "dosfstools" "dosfstools: Allows your computer to access dos-like filesystems."
    pacman_install "exfat-utils" "exfat-utils: Allows management of FAT drives."
    pacman_install "ntfs-3g" "ntfs-3g: Allows accessing NTFS partitions."
    pacman_install "man-db" "man-db: Lets you read man pages of programs."

    pacman_install "ffmpeg" "ffmpeg: Can record and splice video and audio on the command line."
    pacman_install "ffmpegthumbnailer" "ffmpegthumbnailer: Creates thumbnail previews of video files."
    pacman_install "mpd" "mpd: Lightweight music daemon."
    pacman_install "mpc" "mpc: Is a terminal interface for mpd."
    pacman_install "mpv" "mpv: Is the patrician's choice video player."
    pacman_install "polkit" "polkit: Manages user policies."
    pacman_install "gnome-keyring" "gnome-keyring: Serves as the system keyring."

    pacman_install "bc" "bc: Mathematics language used for the dropdown calculator."
    pacman_install "calcurse" "calcurse: Terminal-based organizer"
    pacman_install "ncmpcpp" "ncmpcpp: TUI for music with multiple formats"
    pacman_install "newsboat" "newsboat: TUI RSS client."
    pacman_install "zathura" "zathura: TUI pdf viewer with vim-like bindings."
    pacman_install "zathura-pdf-mupdf" "zathura-pdf-mupdf: Allows mupdf pdf compatibility in zathura."
    pacman_install "poppler" "poppler: Manipulates .pdfs and gives"
    pacman_install "ninja" "ninja - Small build system with a focus on speed"
    pacman_install "meson" "meson - High productivity build system"
    # pacman_install "socat" "socat: Multipurpose relay"
    pacman_install "moreutils" "moreutils: Collection of useful unix tools."
    pacman_install "wireplumber" "wireplumber: Audio system."
    pacman_install "wireplumber-openrc" "wireplumber: Audio system."
    pacman_install "pipewire-pulse" "pipewire-pulse: Compatibility with PulseAudio programs."
    pacman_install "pulsemixer" "pulsemixer: Audio controller"
    pacman_install "imv" "imv: Minimalist image viewer."
    pacman_install "kitty" "kitty: A modern, hackable, featureful, OpenGL-based terminal emulator"
    pacman_install "mako" "mako: Suckless notification system."
    pacman_install "pass" "pass: Stores, retrieves, generates, and synchronizes passwords securely"
    pacman_install "curl" "curl: command line tool and library for transferring data with URLs"
    pacman_install "wget" "wget: Network utility to retrieve files from the Web"
    pacman_install "python3" "python3: Next generation python high level scripting language"
    pacman_install "jq" "jq: Command-line JSON processor"
    pacman_install "tmux" "tmux: Terminal multiplexer"
    pacman_install "less" "less: A terminal based program for viewing text files"
    pacman_install "httpie" "httpie: human-friendly CLI HTTP client for the API era"
    pacman_install "neofetch" "neofetch: A CLI system information tool written in BASH that supports displaying images."
    pacman_install "transmission-cli" "transmission-cli: BitTorrent client (CLI tools, daemon and web client)"
    pacman_install "gammastep" "gammastep: Adjust the color temperature of your screen according to your surroundings."
    pacman_install "bemenu" "bemenu: Dynamic menu library and client program inspired by dmenu"
    pacman_install "bemenu-wayland" "bemenu-wayland: Wayland (wlroots-based compositors) renderer for bemenu"
    pacman_install "wlroots" "wlroots: Modular Wayland compositor library"
    pacman_install "wtype" "wtype: Xdotool for wayland"
    pacman_install "wayland-protocols" "wayland-protocols: Specifications of extended wayland protocols"
    pacman_install "wl-clipboard" "wl-clipboard: Command-line copy/paste utilities for Wayland"
    pacman_install "foot" "foot: Fast, lightweight, and minimalistic Wayland terminal emulator"
    pacman_install "grim" "grim: Screenshot utility for Wayland"
    pacman_install "swappy" "swappy: A Wayland native snapshot editing tool"
    pacman_install "slurp" "slurp: Select a region in a Wayland compositor"
    pacman_install "xdg-utils" "xdg-utils - command line tools that assist application with a variety of desktop integration tasks"
    pacman_install "xdg-user-dirs" "xdg-user-dirs - manage user directories"
    pacman_install "yq" "yq - Command-line YAML, XML, TOML processor - jq wrapper for YAML/XML/TOML documents"
    pacman_install "cargo-update" "yq - A cargo subcommand for checking and applying updates to installed executables"
    pacman_install "fzf" "fzf: Fuzzy finder tool"
    pacman_install "github-cli" "gh - The GitHub CLI"
    pacman_install "swaybg" "swaybg:  Wallpaper tool for Wayland compositors"
    pacman_install "pamixer" "pamixer: Pulseaudio command-line mixer like amixer"
    pacman_install "go" "go: Core compiler tools for the Go programming language"
    pacman_install "htop" "htop-vim: graphical and colorful system monitor."
}

install_aur_packages() {
    print_title "Installing aur packages"
    aur_install "task-spooler" "task-spooler: queues commands or files for download."
    aur_install "simple-mtpfs" "simple-mtpfs: enables the mounting of cell phones."
    aur_install "clipman" "clipman: clipboard manager for Wayland"
    aur_install "wlr-randr" "wlr-randr: Utility to manage outputs of a Wayland compositor"
    aur_install "light" "light: Program to easily change brightness on backlight-controllers."
    aur_install "tremc-git" "tremc-git: Curses interface for transmission - python3 fork of transmission-remote-cli"
    aur_install "ctpv" "ctpv: Image previews for lf file manager"

    # Themes, Icons, Cursor & Fonts
    # aur_install "gtk-theme-arc-gruvbox-git" "gtk-theme-arc-gruvbox-git: dark GTK theme"
    # aur_install "whitesur-icon-theme" "whitesur-icon-theme: MacOS Big Sur like icon theme for linux desktops"
    # aur_install "whitesur-cursor-theme-git" "whitesur-cursor-theme-git: WhiteSur cursors theme for linux desktops"
    # aur_install "whitesur-gtk-theme" "whitesur-gtk-theme: A macOS BigSur-like theme for your GTK apps"
}

install_cargo_packages() {
    print_title "Installing cargo packages"
    install_cargo_package "ripgrep"
    install_cargo_package "zoxide"
    install_cargo_package "eza"
    install_cargo_package "navi"
    install_cargo_package "tealdeer"
    install_cargo_package "bat"
    install_cargo_package "topgrade"
    install_cargo_package "tokei"
    install_cargo_package "git-delta"
    install_cargo_package "fnm"
    install_cargo_package "sheldon"
    install_cargo_package "bob-nvim"
    install_cargo_package "ttyper"
}

install_git_packages() {
    print_title "Installing build Packages"

    for x in dwl dwlb someblocks; do
        local directory="$HOME/.local/src/$x"
        [ -d "$directory" ] && rm -rf "$directory"

        git_install "https://github.com/vivi870123/$x.git"
    done
}

install_modified_lf() {
    print_title "Installing LF"

    execute "Core compiler tools for the Go programming language" "Install LF mod w/ pixsel support"
}

install_flapack_programs() {
    print_title "Installing LF"

    execute "Core compiler tools for the Go programming language" "Install LF mod w/ pixsel support"
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
# install_aur_helper
# install_flatpack
# rust_development
# install_pacman_packages

# install_cargo_packages
# install_aur_packages
 install_git_packages
 install_modified_lf
