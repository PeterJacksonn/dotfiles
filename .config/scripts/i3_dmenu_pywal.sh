#!/bin/bash

# Load pywal colors into shell variables
source "$HOME/.cache/wal/colors.sh"

# Launch i3-dmenu-desktop with dmenu themed using pywal colors
exec i3-dmenu-desktop --dmenu="dmenu -i -nb $color0 -nf $color7 -sb $color1 -sf $color15"
