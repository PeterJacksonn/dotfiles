#!/bin/bash

set -e  # Exit on errors

DOTFILES_DIR="$(pwd)"  # Assumes you're running this from your dotfiles directory

echo "🔗 Creating symlinks from: $DOTFILES_DIR"
mkdir -p ~/.config

# Function to back up and symlink
link_with_backup() {
  local target=$1         # Full target path (e.g. ~/.config/i3)
  local source=$2         # Relative source path in dotfiles (e.g. .config/i3)
  local backup="${target}.orig"

  echo "➡️  Linking $target ← $source"

  if [ -e "$target" ] || [ -L "$target" ]; then
    if [ -L "$target" ]; then
      echo "  🔗 $target is a symlink — removing"
      rm -f "$target"
    else
      echo "  📦 Backing up existing $target to $backup"
      mv -f "$target" "$backup"
    fi
  fi

  ln -sf "$DOTFILES_DIR/$source" "$target"
  echo "  ✅ Linked $target"
}

# Symlink config directories
link_with_backup ~/.config/i3         .config/i3
link_with_backup ~/.config/i3status   .config/i3status
link_with_backup ~/.config/nvim       .config/nvim
link_with_backup ~/.config/polybar    .config/polybar
link_with_backup ~/.config/scripts    .config/scripts

# oh-my-zsh custom
link_with_backup ~/.oh-my-zsh/custom  .oh-my-zsh/custom

# Home directory dotfiles
link_with_backup ~/.zshrc             .zshrc
link_with_backup ~/.tmux.conf         .tmux.conf
link_with_backup ~/.ideavimrc         .ideavimrc

# Skipped for now
echo "⚠️  Skipping JetBrains configs for now"
echo "⚠️  Skipping doom.d for now"

echo "✅ All symlinks created!"
