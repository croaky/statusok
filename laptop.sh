#!/bin/bash

# ./laptop.sh

# - symlinks for dotfiles to `$HOME`
# - system packages with Homebrew
# - shell (zsh)
# - programming language runtimes (Go, Ruby, Crystal)
# - text editors (Vim, VS Code)
# - language servers (HTML, SQL)

# This script can be safely run multiple times.
# Tested with macOS Monterey (12.6) on arm64 (Apple Silicon)

set -eux

if [ "$(uname -m)" != "arm64" ]; then
 echo "laptop script only configured for M1 chip"
 exit 1
fi

# Symlinks
(
  ln -sf "$PWD/asdf/asdfrc" "$HOME/.asdfrc"
  ln -sf "$PWD/asdf/tool-versions" "$HOME/.tool-versions"

  ln -sf "$PWD/vim/vimrc" "$HOME/.vimrc"
  mkdir -p "$HOME/.config/nvim/ftdetect"
  mkdir -p "$HOME/.config/nvim/ftplugin"
  mkdir -p "$HOME/.config/nvim/syntax"
  (
    cd vim
    for f in {ftdetect,ftplugin,syntax}/*; do
      ln -sf "$PWD/$f" "$HOME/.config/nvim/$f"
    done
  )
  mkdir -p "$HOME/.config/nvim"
  ln -sf "$PWD/vim/nvim.vim" "$HOME/.config/nvim/init.vim"

  ln -sf "$PWD/git/gitconfig" "$HOME/.gitconfig"
  ln -sf "$PWD/git/gitignore" "$HOME/.gitignore"
  ln -sf "$PWD/git/gitmessage" "$HOME/.gitmessage"

  mkdir -p "$HOME/.bundle"
  ln -sf "$PWD/ruby/bundle/config" "$HOME/.bundle/config"
  ln -sf "$PWD/ruby/gemrc" "$HOME/.gemrc"
  ln -sf "$PWD/ruby/irbrc" "$HOME/.irbrc"
  ln -sf "$PWD/ruby/rspec" "$HOME/.rspec"

  ln -sf "$PWD/js/npmrc" "$HOME/.npmrc"

  mkdir -p "$HOME/.config/kitty"
  ln -sf "$PWD/shell/kitty.conf" "$HOME/.config/kitty/kitty.conf"

  mkdir -p "$HOME/.ssh"
  ln -sf "$PWD/shell/ssh" "$HOME/.ssh/config"

  mkdir -p "$HOME/.config/bat"
  ln -sf "$PWD/shell/bat" "$HOME/.config/bat/config"

  ln -sf "$PWD/shell/curlrc" "$HOME/.curlrc"
  ln -sf "$PWD/shell/hushlogin" "$HOME/.hushlogin"
  ln -sf "$PWD/shell/tmux.conf" "$HOME/.tmux.conf"
  ln -sf "$PWD/shell/zshrc" "$HOME/.zshrc"

  mkdir -p "$HOME/.config/sqls"
  ln -sf "$PWD/sql/psqlrc" "$HOME/.psqlrc"
  ln -sf "$PWD/sql/sqls.yml" "$HOME/.config/sqls/config.yml"

  mkdir -p "$HOME/Library/Application Support/Code/User"
  ln -sf "$PWD/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
)

# Homebrew
BREW="/opt/homebrew"

if [ ! -d "$BREW" ]; then
  curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
fi

export PATH="$BREW/bin:$PATH"

brew analytics off
brew update-reset
brew bundle --no-lock --file=- <<EOF
tap "heroku/brew"

brew "asdf"
brew "awscli"
brew "bat"
brew "crystal"
brew "fzf"
brew "gh"
brew "git"
brew "go"
brew "heroku"
brew "jq"
brew "libyaml"
brew "node"
brew "neovim"
brew "openssl"
brew "pgformatter"
brew "railway"
brew "shellcheck"
brew "the_silver_searcher"
brew "tldr"
brew "tmux"
brew "tree"
brew "tree-sitter"
brew "vim"
brew "watch"
brew "zsh"

# Ruby https://github.com/rbenv/ruby-build/wiki
brew "gmp"
brew "libyaml"
brew "openssl@3"
brew "readline"
brew "rust"
EOF

brew upgrade
brew cleanup

# Shell
if [ ! -d "/Applications/kitty.app" ]; then
  curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
fi

if [ "$(command -v zsh)" != "$BREW/bin/zsh" ] ; then
  sudo chown -R "$(whoami)" "$BREW/share/zsh" "$BREW/share/zsh/site-functions"
  chmod u+w "$BREW/share/zsh" "$BREW/share/zsh/site-functions"
  shellpath="$(command -v zsh)"

  if ! grep "$shellpath" /etc/shells > /dev/null 2>&1 ; then
    sudo sh -c "echo $shellpath >> /etc/shells"
  fi

  chsh -s "$shellpath"
fi

# Go
if ! command -v godoc &> /dev/null; then
  go get golang.org/x/tools/cmd/godoc
fi

# Deno
# curl -fsSL https://deno.land/x/install/install.sh | sh
# mkdir -p ~/.zsh
# deno completions zsh > ~/.zsh/_deno

# ASDF
export PATH="$BREW/opt/asdf/bin:$BREW/opt/asdf/shims:$PATH"

# Ruby
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=/opt/homebrew/opt/openssl@3"
if ! asdf plugin-list | grep -Fq "ruby"; then
  asdf plugin-add "ruby" "https://github.com/asdf-vm/asdf-ruby"
fi
asdf plugin-update "ruby"
asdf install ruby 3.2.0

# HTML
npm i -g vscode-langservers-extracted

# SQL https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#sqls
go install github.com/lighttiger2505/sqls@latest

# Heroku Postgres
heroku plugins:install heroku-pg-extras

# Vim
if [ -e "$HOME/.vim/autoload/plug.vim" ]; then
  nvim --headless +PlugUpgrade +qa
else
  curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi
nvim --headless +PlugUpdate +PlugClean! +qa
nvim --headless +TSUpdate +qa

# VS Code
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
