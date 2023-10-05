#!/bin/bash

#==================================
# Source utilities
#==================================
. "$DOTFILES_DIR/scripts/utils/utils.sh"

create_gitconfig_local() {
  declare -r FILE_PATH="$HOME/.config/git/config.local"

  if [ ! -e "$FILE_PATH" ] || [ -z "$FILE_PATH" ]; then
    printf "%s\n" \
      "[commit]
    # Sign commits using GPG.
    # https://help.github.com/articles/signing-commits-using-gpg/
    # gpgsign = true
[init]
  defaultBranch = main
[user]
    name =
    email =
    # signingkey =" \
      >>"$FILE_PATH"
  fi

  print_result $? "$FILE_PATH"
}

print_title "Create local giconfig file"
create_gitconfig_local
