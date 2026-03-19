#!/bin/bash
# ============================================================
#  GNOME dconf Restore Script
#  Works with the old backup format (mixed relative paths)
# ============================================================

BACKUP="$HOME/gnome-backup.dconf"

# ── Check backup file exists ─────────────────────────────────
if [[ ! -f "$BACKUP" ]]; then
    echo "❌ Backup file not found at $BACKUP"
    exit 1
fi

echo "🔄 Starting GNOME dconf restore from $BACKUP..."
echo ""

# ── Section paths (must match what was used to dump) ─────────
declare -A SECTIONS
SECTIONS["[keybindings]"]="/org/gnome/desktop/keybindings/"
SECTIONS["[custom-shortcuts]"]="/org/gnome/settings-daemon/plugins/media-keys/"
SECTIONS["[extensions]"]="/org/gnome/shell/extensions/"
SECTIONS["[shell]"]="/org/gnome/shell/"
SECTIONS["[interface-themes-fonts]"]="/org/gnome/desktop/interface/"
SECTIONS["[mutter]"]="/org/gnome/mutter/"
SECTIONS["[peripherals]"]="/org/gnome/desktop/peripherals/"

ORDER=("[keybindings]" "[custom-shortcuts]" "[extensions]" "[shell]" "[interface-themes-fonts]" "[mutter]" "[peripherals]")

# ── Extract and load each section ────────────────────────────
for LABEL in "${ORDER[@]}"; do
    LOAD_PATH="${SECTIONS[$LABEL]}"

    echo -n "  Restoring $LABEL ($LOAD_PATH) ... "

    # Extract lines between this ### marker and the next one
    SECTION=$(awk "/^### \\$LABEL ->/{found=1; next} found && /^### /{exit} found" "$BACKUP" | grep -v '^#')

    if [[ -z "$SECTION" ]]; then
        echo "⚠️  empty or not found (skipped)"
        continue
    fi

    echo "$SECTION" | dconf load "$LOAD_PATH"
    echo "✅ done"
done

# ── Restart shell ─────────────────────────────────────────────
echo ""
echo "============================================================"
echo "  ✅ Restore complete!"
echo "============================================================"
echo ""
echo "  Now restart GNOME shell to apply changes:"
echo ""
echo "  Wayland  →  killall -3 gnome-shell"
echo "  Xorg     →  Alt+F2 → r → Enter"
echo ""
echo "  Or log out and back in for a clean reload."
echo ""
