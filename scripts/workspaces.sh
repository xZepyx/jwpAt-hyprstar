#!/usr/bin/env bash
set -euo pipefail

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing: $1" >&2; exit 1; }; }
need hyprctl
need jq

monitors_json="$(hyprctl monitors -j)"
has_dp1="$(jq -r 'any(.[]; .name == "DP-1" and .active == true)' <<<"$monitors_json")"
has_dp2="$(jq -r 'any(.[]; .name == "DP-2" and .active == true)' <<<"$monitors_json")"

move_ws() {
  local ws="$1" mon="$2"
  hyprctl dispatch moveworkspacetomonitor "$ws" "$mon" >/dev/null
}

# Always keep 1-4 on the laptop panel if it exists
if jq -e 'any(.[]; .name == "eDP-1" and .active == true)' <<<"$monitors_json" >/dev/null; then
  for ws in 1 2 3 4; do
    move_ws "$ws" "eDP-1"
  done
fi

if [[ "$has_dp1" == "true" && "$has_dp2" == "true" ]]; then
  # Both externals
  for ws in 5 6 7; do move_ws "$ws" "DP-1"; done
  for ws in 8 9 10; do move_ws "$ws" "DP-2"; done

elif [[ "$has_dp1" == "true" && "$has_dp2" != "true" ]]; then
  # Only DP-1
  for ws in 5 6 7 8; do move_ws "$ws" "DP-1"; done

elif [[ "$has_dp2" == "true" && "$has_dp1" != "true" ]]; then
  # Only DP-2
  for ws in 5 6 7 8; do move_ws "$ws" "DP-2"; done
fi