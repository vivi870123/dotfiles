#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

update
upgrade


./build-essentials.sh
./install_packages.sh

./lazygit.sh
./n_install.sh
./rust.sh
./fzf.sh
./zplug.sh


./cleanup.sh

