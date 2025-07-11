#!/usr/bin/env bash

# Terminate already running bar instances
# If all your bars have ipc enabled, you can use 
polybar-msg cmd quit
# Otherwise you can use the nuclear option:
# killall -q polybar

# Launch bar
#echo "---" | tee -a /tmp/polybar.log
#polybar mybar 2>&1 | tee -a /tmp/polybar.log & disown

# Update polybar colors from Pywal
#~/.config/polybar/wal-colors.sh


# Launch a bar on each connected monitor
for monitor in $(polybar --list-monitors | cut -d: -f1); do
    MONITOR=$monitor polybar mybar & disown
done


echo "Polybar launched..."
