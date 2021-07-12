#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

create_directories() {
    declare -a DIRECTORIES=(
        "$HOME/Downloads/torrents"
        "$HOME/.local/bin"
	"$HOME/.config/alacritty"
	"$HOME/.config/composer"
	"$HOME/.config/kitty"
	"$HOME/.config/lazygit"
	"$HOME/.config/mpv/scripts"
	"$HOME/.config/newsboat"
	"$HOME/.config/nvim"
	"$HOME/.config/rg"
	"$HOME/.config/shell"
	"$HOME/.config/sxiv/exec"
	"$HOME/.config/tmux"
	"$HOME/.config/vifm"
	"$HOME/.config/zsh"
    )

    for i in "${DIRECTORIES[@]}"; do
        mkd "$i"
    done

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {
    print_in_purple "\n • Create directories\n\n"
    create_directories
}

main
