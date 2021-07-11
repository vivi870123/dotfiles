#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../utils.sh"

declare -r FZF_DIR="$HOME/.fzf"
declare -r FZF_GIT_REPO_URL="https://github.com/junegunn/fzf.git"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

download_fzf() {
    execute \
        "rm -rf $FZF_DIR \
            && git clone --depth 1 --quiet $FZF_GIT_REPO_URL $FZF_DIR" \
        "Downloading fzf"
}

install_fzf() {
    execute  ". $FZF_DIR/install"  "Installing fzf"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {

    print_in_purple "\n   n - fzf\n\n"

    if [ ! -d "$FZF_DIR" ]; then
      download_fzf
      install_fzf
    fi
}

main


