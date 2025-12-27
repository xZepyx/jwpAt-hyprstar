#!/bin/bash

echo "include $HOME/.config/kitty/themes/$1.conf" > "$HOME/.config/kitty/kitty.conf"
echo "source = $HOME/.config/hypr/themes/$1.conf" > "$HOME/.config/hypr/theme.conf"
quickshell ipc call theme themeSet $1
hyprctl reload
pkill -SIGUSR1 kitty