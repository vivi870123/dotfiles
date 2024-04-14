#!/bin/bash

#==================================
# Variables
#==================================
declare GITHUB_REPOSITORY="vivi870123/dotfiles"
declare DOTFILES_ORIGIN="git@github.com:$GITHUB_REPOSITORY.git"
declare DOTFILES_TARBALL_URL="https://github.com/$GITHUB_REPOSITORY/tarball/main"
declare DOTFILES_UTILS_URL="https://raw.githubusercontent.com/$GITHUB_REPOSITORY/main/scripts/utils/utils.sh"

#==================================
# Settings
#==================================
declare REPO_DIR="$HOME/.local/src"
declare DOTFILES_DIR="$HOME/.dotfiles"

declare skipQuestions=false

#==================================
# Helper Functions
#==================================
download() {
  local url="$1"
  local output="$2"

  if command -v "curl" &>/dev/null; then
    curl -LsSo "$output" "$url" &>/dev/null
    return $?
  elif command -v "wget" &>/dev/null; then
    wget -qO "$output" "$url" &>/dev/null
    return $?
  fi
  return 1
}

download_utils() {
  local tmpFile=""

  tmpFile="$(mktemp /tmp/XXXXX)"
  download "$DOTFILES_UTILS_URL" "$tmpFile" &&
    . "$tmpFile" &&
    rm -rf "$tmpFile" &&
    return 0

  return 1
}

verify_os() {
  local os_name="$(get_os)"

  # Check if the OS is `Artix` and supported
  if [ "$os_name" == "artix" ]; then
    print_success "$os_name $os_version is supported"
    return 0
  else
    # Exit if not supported OS
    print_error "$os_name is not supported. This dotfiles are intended for MacOS, Ubuntu and Arch"
  fi
  return 1
}

#==================================
# Main Setup
#==================================
main() {
  # Ensure that the following actions are made relative to this file's path.
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

  # Load utils
  if [ -x "utils/utils.sh" ]; then
    . "utils/utils.sh" || exit 1
  fi

  print_section "Dotfiles Setup"

  # Ask user for sudo
  print_title "Sudo Access"
  ask_for_sudo

  # Verify OS and OS version
  print_title "Verifying OS"
  verify_os || exit 1

  # Start installation
  . "$HOME/.dotfiles/scripts/system/arch/install.sh"
}

main "$@"
