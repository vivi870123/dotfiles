#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "./utils.sh"


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_plugin() {
    declare -r LAZYGIT_URL="github.com/jesseduffield/lazygit"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install plugin
    go get $LAZYGIT_URL
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


main() {
    print_in_purple "\n   n - Lazygit\n\n"

    install_plugin
}

main


