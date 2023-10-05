#!/bin/bash

#==================================
# SOURCE UTILS
#==================================
cd "$(dirname "${BASH_SOURCE[0]}")" && . "utils.sh"

manual_install() {
  # Installs $1 manually. Used only for AUR helper here.
  # Should be run after repodir is created and var is set.
  sudo pacman -Qq "$1" && return 0
  print_section "Installing \"$1\" manually."

  create_directory "$REPO_DIR/$1"

  git -C "$REPO_DIR" clone --depth 1 --single-branch --no-tags -q "https://aur.archlinux.org/$1.git" "$REPO_DIR/$1" ||
    {
      cd "$REPO_DIR/$1" || return 1
      git pull --force origin main
    }
  cd "$REPO_DIR/$1" || exit 1
  sudo makepkg --noconfirm -si >/dev/null 2>&1 || return 1
}

#==================================
# PACMAN
#==================================

refresh_keys() {
  execute "sudo pacman --noconfirm -S archlinux-keyring" "Refreshing keys"
}

pacman_install() {
  declare -r EXTRA_ARGUMENTS="$3"
  declare -r PACKAGE_READABLE_NAME="$2"
  declare -r PACKAGE="$1"

  if ! pacman_installed "$PACKAGE"; then
    execute "sudo pacman -S --noconfirm --needed $EXTRA_ARGUMENTS $PACKAGE" "$PACKAGE_READABLE_NAME"
  else
    print_success "$PACKAGE_READABLE_NAME"
  fi
}

pacman_synchronize() {
  execute "sudo pacman -Sy" "Synchronize packages"
}

pacman_installed() {
  pacman -Q "$1" &>/dev/null
}

aur_install() {
  declare -r PACKAGE="$2"
  declare -r PACKAGE_READABLE_NAME="$1"

  if ! pacman_installed "$PACKAGE"; then
    execute "yay -S --noconfirm $PACKAGE" "$PACKAGE_READABLE_NAME"
  else
    print_success "$PACKAGE_READABLE_NAME"
  fi
}

#==================================
# FLATPAK
#==================================
flatpak_install() {
  declare -r PACKAGE="$2"
  declare -r PACKAGE_READABLE_NAME="$1"

  if ! flatpak_installed "$PACKAGE"; then
    execute "flatpak install -y flathub $PACKAGE" "$PACKAGE_READABLE_NAME"
  else
    print_success "$PACKAGE_READABLE_NAME"
  fi
}

flatpak_installed() {
  flatpak list --columns=name,application | grep -i "$1" &>/dev/null
}

#==================================
# Git
#==================================
git_install() {
  progname="${1##*/}"
  progname="${progname%.git}"
  dir="$REPO_DIR/$progname"

  git -C "$REPO_DIR" clone --depth 1 --single-branch --no-tags -q "$1" "$dir"
  cd "$dir" || exit 1

  if [ ! -f "$dir/meson.build" ]; then
    execute "
    make
    sudo make install" "Installing \`$progname\` via \`git\` and \`make\`. $(basename "$1") $2"
  else
    execute "
    meson setup build
    ninja -C build
    sudo ninja -C build install" "Installing \`$progname\` via \`git\` and \`meson\`. $(basename "$1") $2"
  fi
}

install_pyenv() {
  if check_directory "$HOME/.pyenv" "pyenv is already installed. Reinstall?"; then
    execute "curl https://pyenv.run | bash" "Install pyenv and friends"
  fi
  symlink "pyenv/pyenv-virtualenv-after.bash" ".pyenv/plugins/pyenv-virtualenv/etc/pyenv.d/virtualenv/after.bash"
}

install_pyenv_python3() {
  local version
  version=$("$HOME/.pyenv/bin/pyenv" install --list | grep '^\s\+3.11.\d' | tail -1 | xargs)
  execute "$HOME/.pyenv/bin/pyenv install --skip-existing $version" "Python $version"
}

create_pyenv_virtualenv() {
  local version
  if [ -f "$HOME/.pyenv/versions/global" ] && ! confirm "Global virtualenv already exists. Reinstall?"; then
    return
  fi
  version=$("$HOME/.pyenv/bin/pyenv" install --list | grep '^\s\+3.11.\d' | tail -1 | xargs)
  execute \
    "$HOME/.pyenv/bin/pyenv virtualenv --force $version global && $HOME/.pyenv/bin/pyenv global global" \
    "Global virtualenv"
}

install_python_package() {
  local msg=${2:-$1}
  execute "PYENV_VERSION=global $HOME/.pyenv/bin/pyenv exec pip install --upgrade $1" "$msg"
}

install_rustup() {
  execute "curl https://sh.rustup.rs -sSf | bash -s - -y --no-modify-path" "Rustup"
}

install_rust_toolchain() {
  local toolchain=$1
  execute "$HOME/.local/share/cargo/bin/rustup update $toolchain" "Rust toolchain ($toolchain)"
}

install_cargo_package() {
  local msg=${2:-$1}
  execute "$HOME/.local/share/cargo/bin/cargo install $1" "$msg"
}

install_crate() {
  local repo=$1
  local name=${repo#*/}
  shift
  execute "curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh | \
      bash -s -- --repo $repo --to $HOME/.local/bin --force $*" "$name"
}
