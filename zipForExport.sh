#!/bin/bash

# Name of the archive
ARCHIVE_NAME="dotfiles_backup_$(date +%Y-%m-%d_%H-%M-%S).zip"

# Destination: Home directory
DEST="$HOME/$ARCHIVE_NAME"

# Get the current script's directory (your dotfiles directory)
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Zip the entire dotfiles directory
cd "$DOTFILES_DIR"
zip -r "$DEST" . -x "*.git*" -x "*__pycache__*" -x "*.DS_Store"

echo "✅ Dotfiles zipped to: $DEST"
