
#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
install_plugins() {

    declare -r CARGO_URL="https://sh.rustup.rs"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install plugin.

    execute "curl $CARGO_URL -sSf | sh" "Install plugins" || return 1

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

    "./$(get_os)/rust.sh"
    install_plugins

}

main
