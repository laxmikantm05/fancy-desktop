#!/bin/bash
OUT="$HOME/gnome-backup.dconf"
> "$OUT"  # clear/create file

declare -A sections=(
  ["[keybindings]"]="/org/gnome/desktop/keybindings/"
  ["[custom-shortcuts]"]="/org/gnome/settings-daemon/plugins/media-keys/"
  ["[extensions]"]="/org/gnome/shell/extensions/"
  ["[shell]"]="/org/gnome/shell/"
  ["[interface-themes-fonts]"]="/org/gnome/desktop/interface/"
  ["[mutter]"]="/org/gnome/mutter/"
  ["[peripherals]"]="/org/gnome/desktop/peripherals/"
)

for label in "${!sections[@]}"; do
  path="${sections[$label]}"
  echo "### $label -> $path" >> "$OUT"
  dconf dump "$path" >> "$OUT"
  echo "" >> "$OUT"
done

echo "✅ Backup saved to $OUT"
