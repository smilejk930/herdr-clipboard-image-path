#!/usr/bin/env bash
# Reads a Windows clipboard image from WSL, stores it in Windows' temp folder,
# then sends its /mnt/c/... path to the Herdr pane that invoked this action.
set -euo pipefail

fail() {
  printf 'clipboard-image-path: %s\n' "$*" >&2
  exit 1
}

[[ -n "${HERDR_PANE_ID:-}" ]] || fail "no focused Herdr pane was supplied"
[[ -n "${HERDR_BIN_PATH:-}" ]] || fail "Herdr binary path was not supplied"
command -v powershell.exe >/dev/null 2>&1 || fail "powershell.exe is unavailable; run this plugin from WSL"
command -v wslpath >/dev/null 2>&1 || fail "wslpath is unavailable"

plugin_root="${HERDR_PLUGIN_ROOT:-$(cd -- "$(dirname -- "$0")/.." && pwd)}"
export HERDR_CLIPBOARD_PNG_NAME="herdr-clipboard-$(date +%Y%m%d-%H%M%S)-$$.png"

windows_path="$({
  powershell.exe -NoLogo -NoProfile -STA -ExecutionPolicy Bypass \
    -File "$plugin_root/scripts/save-clipboard-image.ps1"
} | tr -d '\r' | tail -n 1)" || fail "could not read an image from the Windows clipboard"

[[ -n "$windows_path" ]] || fail "the Windows clipboard does not contain an image"
linux_path="$(wslpath -u "$windows_path")" || fail "could not convert Windows path: $windows_path"
[[ -f "$linux_path" ]] || fail "saved image is not reachable from WSL: $linux_path"

"$HERDR_BIN_PATH" pane send-text "$HERDR_PANE_ID" "$linux_path"
printf 'Pasted image path: %s\n' "$linux_path" >&2
