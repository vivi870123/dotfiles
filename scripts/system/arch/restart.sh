#!/bin/bash
# shellcheck disable=SC1091

#==================================
# Source utilities
#==================================
. "$DOTFILES_DIR/scripts/utils/utils.sh"

main() {
  print_section "Restart"

  ask_for_confirmation "Do you want to restart?"
  printf "\n"

  if answer_is_yes; then
    sudo reboot &>/dev/null
  fi
}

main
