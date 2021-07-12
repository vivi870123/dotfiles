#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_plugins() {

    declare -r N_URL="https://git.io/n-install"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install plugin.
    curl $N_URL -L | bash -s -- -y
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {

    print_in_purple "\n   n - node version manager\n\n"

    install_plugins

}

main


