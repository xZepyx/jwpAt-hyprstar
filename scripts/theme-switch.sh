#!/bin/bash

echo "include $HOME/.config/kitty/themes/$1.conf" > "$HOME/.config/kitty/kitty.conf"
echo "source = $HOME/.config/hypr/themes/$1.conf" > "$HOME/.config/hypr/theme.conf"

if pgrep -x quickshell >/dev/null 2>&1; then
  quickshell ipc call theme themeSet "$1"
fi

if [[ "${XDG_SESSION_TYPE:-}" == "wayland" && -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
  hyprctl reload
  pkill -SIGUSR1 kitty || true
fi
