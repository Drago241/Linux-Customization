#!/bin/bash

# Create "themes" folder in ~/.local/share
mkdir -p "$HOME/.local/share/themes"

# Directory containing compressed files
ICON_DIR="$HOME/Downloads/Linux Customization/Icons, Themes & Cursors/Icons"

# Extract all archives inside ICON_DIR to ~/.local/share
for file in "$ICON_DIR"/*; do
    case "$file" in
        *.tar.gz|*.tgz)  tar -xzf "$file" -C "$HOME/.local/share/themes" ;;
        *.tar.xz)        tar -xJf "$file" -C "$HOME/.local/share/themes" ;;
        *.tar.bz2)       tar -xjf "$file" -C "$HOME/.local/share/themes" ;;
        *.zip)           unzip -q "$file" -d "$HOME/.local/share/themes" ;;
    esac
done

