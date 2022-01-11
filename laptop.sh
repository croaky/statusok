#!/bin/bash

# ./laptop.sh

# - installs system packages with Homebrew package manager
# - changes shell to Z shell (zsh)
# - creates symlinks for dotfiles to `$HOME`
# - installs programming language runtimes
# - installs or updates Vim plugins

# This script can be safely run multiple times.
# Tested with Big Sur (11.3) on arm64 (Apple Silicon) and x86_64 (Intel) chips.

set -eux

# arm64 or x86_64
arch="$(uname -m)"

# Homebrew
if [ "$arch" = "arm64" ]; then
  BREW="/opt/homebrew"
else
  BREW="/usr/local"
fi

if [ ! -d "$BREW" ]; then
  sudo mkdir -p "$BREW"
  sudo chflags norestricted "$BREW"
  sudo chown -R "$LOGNAME:admin" "$BREW"
  curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C "$BREW"
fi

export PATH="$BREW/bin:$PATH"

brew analytics off
brew update-reset
brew bundle --no-lock --file=- <<EOF
tap "heroku/brew"
tap "homebrew/services"
tap "planetscale/tap"

brew "asdf"
brew "awscli"
brew "bat"
brew "fzf"
brew "gh"
brew "git"
brew "go"
brew "heroku"
brew "jq"
brew "kitty", args: ["build-from-source"]
brew "libyaml"
brew "mysql-client"
brew "node"
brew "openssl"
brew "pgformatter"
brew "pscale"
brew "shellcheck"
brew "the_silver_searcher"
brew "tldr"
brew "tmux"
brew "tree"
brew "vim"
brew "watch"
brew "zsh"

cask "ngrok"
EOF

brew upgrade
brew cleanup

# zsh
update_shell() {
  sudo chown -R "$(whoami)" "$BREW/share/zsh" "$BREW/share/zsh/site-functions"
  chmod u+w "$BREW/share/zsh" "$BREW/share/zsh/site-functions"
  shellpath="$(command -v zsh)"

  if ! grep "$shellpath" /etc/shells > /dev/null 2>&1 ; then
    sudo sh -c "echo $shellpath >> /etc/shells"
  fi

  chsh -s "$shellpath"
}

case "$SHELL" in
  */zsh)
    if [ "$(command -v zsh)" != "$BREW/bin/zsh" ] ; then
      update_shell
    fi
    ;;
  *)
    update_shell
    ;;
esac

# Symlinks
(
  ln -sf "$PWD/asdf/asdfrc" "$HOME/.asdfrc"
  ln -sf "$PWD/asdf/tool-versions" "$HOME/.tool-versions"

  ln -sf "$PWD/vim/vimrc" "$HOME/.vimrc"

  mkdir -p "$HOME/.vim/ftdetect"
  mkdir -p "$HOME/.vim/ftplugin"
  mkdir -p "$HOME/.vim/syntax"
  (
    cd vim
    ln -sf "$PWD/coc-settings.json" "$HOME/.vim/coc-settings.json"
    for f in {ftdetect,ftplugin,syntax}/*; do
      ln -sf "$PWD/$f" "$HOME/.vim/$f"
    done
  )

  ln -sf "$PWD/git/gitconfig" "$HOME/.gitconfig"
  ln -sf "$PWD/git/gitignore" "$HOME/.gitignore"
  ln -sf "$PWD/git/gitmessage" "$HOME/.gitmessage"

  mkdir -p "$HOME/.bundle"
  ln -sf "$PWD/ruby/bundle/config" "$HOME/.bundle/config"
  ln -sf "$PWD/ruby/gemrc" "$HOME/.gemrc"
  ln -sf "$PWD/ruby/irbrc" "$HOME/.irbrc"
  ln -sf "$PWD/ruby/rspec" "$HOME/.rspec"

  mkdir -p "$HOME/.config/kitty"
  ln -sf "$PWD/shell/kitty.conf" "$HOME/.config/kitty/kitty.conf"

  mkdir -p "$HOME/.ssh"
  ln -sf "$PWD/shell/ssh" "$HOME/.ssh/config"

  mkdir -p "$HOME/.config/bat"
  ln -sf "$PWD/shell/bat" "$HOME/.config/bat/config"

  mkdir -p "$HOME/.warp/themes"
  ln -sf "$PWD/shell/warp-theme.yaml" "$HOME/.warp/themes"

  ln -sf "$PWD/shell/curlrc" "$HOME/.curlrc"
  ln -sf "$PWD/shell/hushlogin" "$HOME/.hushlogin"
  ln -sf "$PWD/shell/tmux.conf" "$HOME/.tmux.conf"
  ln -sf "$PWD/shell/zshrc" "$HOME/.zshrc"

  ln -sf "$PWD/sql/psqlrc" "$HOME/.psqlrc"

  mkdir -p "$HOME/Library/Application Support/Code/User"
  ln -sf "$PWD/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
)

# Go
if ! command -v godoc &> /dev/null; then
  go get golang.org/x/tools/cmd/godoc
fi

# Deno
curl -fsSL https://deno.land/x/install/install.sh | sh
mkdir -p ~/.zsh
deno completions zsh > ~/.zsh/_deno

# Heroku Postgres
heroku plugins:install heroku-pg-extras

# ASDF
export PATH="$BREW/opt/asdf/bin:$BREW/opt/asdf/shims:$PATH"

# Ruby
if ! asdf plugin-list | grep -Fq "ruby"; then
  asdf plugin-add "ruby" "https://github.com/asdf-vm/asdf-ruby"
fi
asdf plugin-update "ruby"
asdf install ruby 3.0.3

# Vim
if [ -e "$HOME/.vim/autoload/plug.vim" ]; then
  vim -u "$HOME/.vimrc" +PlugUpgrade +qa
else
  curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi
vim -u "$HOME/.vimrc" +PlugUpdate +PlugClean! +qa

# VS Code
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false

# Solana
sh -c "$(curl -sSfL https://release.solana.com/stable/install)"

# Rust
if ! command -v rustup &> /dev/null; then
  curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh
  source "$HOME/.cargo/env"
fi

if ! command -v rustfmt &> /dev/null; then
  rustup component add rustfmt
fi
