#!/usr/bin/env bash
set -e

# ============================================
# CortexOS Updater — macOS & Linux
# ============================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

success() { echo -e "  ${GREEN}✓${NC} $1"; }
warn()    { echo -e "  ${YELLOW}⚠${NC} $1"; }
info()    { echo -e "  ${CYAN}→${NC} $1"; }

VAULT_DIR="$HOME/CortexOS"
PLUGINS_DIR="$VAULT_DIR/.obsidian/plugins"

if [ ! -d "$VAULT_DIR/.git" ]; then
    echo -e "  ${YELLOW}⚠${NC} No CortexOS vault found at $VAULT_DIR"
    echo "  Run install.sh first."
    exit 1
fi

# --- Pull vault updates ---
echo ""
echo -e "${BOLD}Updating CortexOS vault...${NC}"
cd "$VAULT_DIR"
git pull origin main 2>/dev/null && success "Vault files updated" || warn "Git pull failed — check your connection"

# --- Update plugins ---
echo ""
echo -e "${BOLD}Updating plugins...${NC}"
echo ""

install_plugin() {
    local repo="$1"
    local plugin_id="$2"
    local display_name="$3"
    local plugin_dir="$PLUGINS_DIR/$plugin_id"

    mkdir -p "$plugin_dir"

    local tag
    tag=$(curl -sL "https://api.github.com/repos/$repo/releases/latest" 2>/dev/null | grep '"tag_name"' | head -1 | sed -E 's/.*"tag_name"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/')

    if [ -z "$tag" ]; then
        warn "$display_name — could not fetch latest release"
        return 1
    fi

    local base_url="https://github.com/$repo/releases/download/$tag"

    curl -sL -f "$base_url/main.js" -o "$plugin_dir/main.js" 2>/dev/null || true
    curl -sL -f "$base_url/manifest.json" -o "$plugin_dir/manifest.json" 2>/dev/null || true
    curl -sL -f "$base_url/styles.css" -o "$plugin_dir/styles.css" 2>/dev/null || rm -f "$plugin_dir/styles.css"

    success "$display_name → $tag"
}

install_plugin "denolehov/obsidian-git"                          "obsidian-git"               "Obsidian Git"
install_plugin "SilentVoid13/Templater"                          "templater-obsidian"         "Templater"
install_plugin "blacksmithgu/obsidian-dataview"                  "dataview"                   "Dataview"
install_plugin "chhoumann/quickadd"                              "quickadd"                   "QuickAdd"
install_plugin "shabegom/buttons"                                "buttons"                    "Buttons"
install_plugin "phibr0/obsidian-commander"                       "cmdr"                       "Commander"
install_plugin "liamcain/obsidian-calendar-plugin"               "calendar"                   "Calendar"
install_plugin "obsidian-tasks-group/obsidian-tasks"             "obsidian-tasks-plugin"       "Tasks"
install_plugin "st3v3nmw/obsidian-spaced-repetition"             "obsidian-spaced-repetition"  "Spaced Repetition"
install_plugin "brianpetro/obsidian-smart-connections"           "smart-connections"           "Smart Connections"
install_plugin "polyipseity/obsidian-terminal"                   "terminal"                   "Terminal"

echo ""
echo -e "  ${GREEN}✅ CortexOS updated.${NC} Restart Obsidian to load new plugin versions."
echo ""
