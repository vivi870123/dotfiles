#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
install_plugin() {

    # Install plugin.
#    install_package "Cargo" "cargo"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

    if cmd_exists cargo; then
      cargo install stylua
      cargo install git-delta
      cargo install topgrade
      # cargo install cargo-update # requires libopenssl-dev on ubuntu

      if ! cmd_exists rg; then
        cargo install ripgrep
      fi
    fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {

    print_in_purple "\n   Rust & Cargo\n\n"

    install_plugin

}

main
