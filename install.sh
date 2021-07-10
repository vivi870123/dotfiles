#!/bin/sh

# add required dependencies
# * GCC
# * python
# * delta
# * bat
# * thefuck

packages=(
  "libxml2-utils",
  "dateutils",
  "ripgrep".
  "bat",
  "thefuck",
  "delta",
  "lazygit",
  "zoxide",
  "exa",
  "python",
  "python-pip",
  "python3-pip",
  "wget",
  "curl",
  "git",
  "trash-cli",
  "tmux",
  "tmux-plugin-manager",
  "ripgr",
  "dosfstools",
  "exfat-utils",
  "sxiv ",
  "ffmpeg",
  "mpv",
  "newsboat",
  "pulsemixer",
  "unzip",
  "unrar",
  "zathura",
  "zathura-cb",
  "zathura-pdf-poppler",
  "mediainfo",
  "poppler-utils",
  "atool",
  "highlight",
  "task-spooler",
  "transmission-gtk",
  "cmus",
  "jq",
  "composer",
  "odttotext",
  "docxtotext",
  "antiword"
  "preload",
  "ufw",
  "zsh",
  "gcc",
  "g++",
  "build-essential",
  "make",
  "sed",
  "cmake",
  "exuberant-ctags",
  "shellcheck",
  "rsync",
  "ninja-build",
  "autoconf",
  "automake",
  "software-properties-common"
)

exists() {
  type "$1" &> /dev/null;
}

install_missing_packages() {
  for p in "${packages[@]}"; do
    if hash "$p" 2>/dev/null; then
      echo "$p is installed"
    else
      echo "$p is not installed"
      # Detect the platform (similar to $OSTYPE)
      OS="`uname`"
      case $OS in
        'Linux')
          apt install "$1" || echo "$p failed to install"
          ;;
        *) ;;
      esac
      echo "---------------------------------------------------------"
      echo "Done "
      echo "---------------------------------------------------------"
    fi
  done
}


create_dir() {
  if [ ! -d "$1" ]; then
    echo "Creating $1"
    mkdir -p $1
  fi
}

# Might as well ask for password up-front, right?
echo "Starting install script, please grant me sudo access..."
sudo -v

# Keep-alive: update existing sudo time stamp if set, otherwise do nothing.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &


install_missing_packages || echo "failed to install missing packages"

# Clone my dotfiles repo into ~/.dotfiles/ if needed
echo "dotfiles -------------------------------------------------"

export DOTFILES="$HOME/.dotfiles"

if [ -f "$DOTFILES" ]; then
  echo "Dotfiles have already been cloned into the home dir"
else
  echo "Cloning dotfiles"
  git clone https://github.com/vivi870123/dotfiles.git ~/.dotfiles
fi

cd "$DOTFILES" || "Didn't cd into dotfiles this will be bad :("
git submodule update --init --recursive

cd "$HOME" || exit
echo "---------------------------------------------------------"

echo "You'll need to log out for this to take effect"

echo "running other defaults"
echo "this may take a while.. as well"
echo "---------------------------------------------------------"


# Install n node version manager program
curl -L https://git.io/n-install | bash

# Install rust
curl https://sh.rustup.rs -sSf | sh

if exists cargo; then
  cargo install stylua
  cargo install git-delta
  cargo install topgrade
  # cargo install cargo-update # requires libopenssl-dev on ubuntu

  # install ripgrep via cargo in case it failed via apt or brew
  if ! exists rg; then
    cargo install ripgrep
  fi
fi

# TODO install
# * lazygit for linux

# TODO pip3 dependencies
# * pip3 install neovim --upgrade
# * pip3 install --user neovim-remote

# Install fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

echo "---------------------------------------------------------"
echo "Changing to zsh"
echo "---------------------------------------------------------"
chsh -s "$(which zsh)"

$DOTFILES/install

echo 'done'
echo "---------------------------------------------------------"
echo "All done!"
echo "Cheers"
echo "---------------------------------------------------------"

exit 0
