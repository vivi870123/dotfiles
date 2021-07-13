#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_plugins() {

    declare -r N_URL="https://git.io/n-install"


    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    
    # Install plugin.
    if [ ! -f ~/n/bin/n ]; then
      curl $N_URL -L | bash -s -- -y
    fi

    execute "n lts" "Installing node"
    execute "npm install -g neovim" "Installing neovim"

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {

    print_in_purple "\n   n - node version manager\n\n"

    install_plugins

}

main


