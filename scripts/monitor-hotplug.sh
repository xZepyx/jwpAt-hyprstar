#!/usr/bin/env bash
set -euo pipefail

sock="${XDG_RUNTIME_DIR}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"
script="${HOME}/.config/hypr/scripts/assign-workspaces.sh"

# tiny debounce so multiple events don’t spam
pending=0
run_assign() {
  if [[ "$pending" -eq 1 ]]; then return; fi
  pending=1
  ( sleep 0.2; "$script" >/dev/null 2>&1; pending=0 ) &
}

# requires socat
command -v socat >/dev/null 2>&1 || exit 0

socat -u "UNIX-CONNECT:${sock}" - | while IFS= read -r line; do
  case "$line" in
    monitoradded*|monitorremoved*|monitoraddedv2*|monitorremovedv2*)
      run_assign
      ;;
  esac
done
