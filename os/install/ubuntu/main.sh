#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

update
upgrade


./install_packages.sh

./n_install.sh
./rust.sh
./fzf.sh
./zplug.sh


./cleanup.sh

