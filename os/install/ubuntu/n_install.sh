#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_plugins() {

    declare -r CARGO_URL="https://git.io/n-install"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install plugin.
    execute "curl $CARGO_URL -sSf | bash" "Install plugins" || return 1
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {

    print_in_purple "\n   n - node version manager\n\n"

    "./$(get_os)/n_install.sh"
    install_plugins

}

main


