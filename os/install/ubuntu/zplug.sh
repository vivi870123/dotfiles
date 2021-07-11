#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
install_plugins() {

    declare -r ZPLUG_DIR="$HOME/.zplug"
    declare -r ZPLUG_GIT_REPO_URL="https://github.com/zplug/zplug.git"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install plugins.

    execute \
        "rm -rf $ZPLUG_DIR \
            && git clone --quiet $ZPLUG_GIT_REPO_URL $ZPLUG_DIR" \
        "Install plugins"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {

    print_in_purple "\n   ZPlug\n\n"

    "./$(get_os)/zplug.sh"
    install_plugins

}

main
