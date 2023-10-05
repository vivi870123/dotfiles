#!/bin/bash
# shellcheck disable=SC1091

#==================================
# Source utilities
#==================================
. "$DOTFILES_DIR/scripts/utils/utils.sh"
. "$DOTFILES_DIR/scripts/utils/arch.sh"

#==================================
# Print Section Title
#==================================
print_section "Running Artix Dotfiles Setup"

# Setup symlinks
. "$DOTFILES_DIR/scripts/system/symlink.sh"

# Git: Local config
. "$DOTFILES_DIR/scripts/system/git-local-config.sh"

# Setup packages
. "$DOTFILES_DIR/scripts/system/arch/packages.sh"

# if cmd_exists "git"; then
#   if [ "$(git config --get remote.origin.url)" != "$DOTFILES_ORIGIN" ]; then
#     . "$DOTFILES_DIR/scripts/system/git-initialize-repository.sh" "$DOTFILES_ORIGIN"
#   fi
#
#   # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
#   if ! $skipQuestions; then
#     . "$DOTFILES_DIR/scripts/system/git-update-content.sh"
#   fi
# fi
#
# if ! $skipQuestions; then
#   . "$DOTFILES_DIR/scripts/system/arch/restart.sh"
# fi
