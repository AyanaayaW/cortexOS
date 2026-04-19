#!/usr/bin/env bash
set -e

# ============================================
# CortexOS Installer — macOS & Linux
# ============================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

print_header() {
    echo ""
    echo -e "${BLUE}${BOLD}╔══════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}${BOLD}║            CortexOS Installer            ║${NC}"
    echo -e "${BLUE}${BOLD}║   AI-powered second brain for everyone   ║${NC}"
    echo -e "${BLUE}${BOLD}╚══════════════════════════════════════════╝${NC}"
    echo ""
}

success() { echo -e "  ${GREEN}✓${NC} $1"; }
warn()    { echo -e "  ${YELLOW}⚠${NC} $1"; }
fail()    { echo -e "  ${RED}✗${NC} $1"; }
info()    { echo -e "  ${CYAN}→${NC} $1"; }

print_header

# --- Detect OS ---
OS="$(uname -s)"
case "$OS" in
    Darwin) PLATFORM="macos"; info "Detected: macOS" ;;
    Linux)  PLATFORM="linux"; info "Detected: Linux" ;;
    *)      fail "Unsupported OS: $OS"; exit 1 ;;
esac

echo ""
echo -e "${BOLD}Checking dependencies...${NC}"
echo ""

# --- Check git ---
if command -v git &>/dev/null; then
    success "git installed ($(git --version | head -1))"
else
    fail "git is not installed"
    if [ "$PLATFORM" = "macos" ]; then
        info "Install with: brew install git"
    else
        info "Install with: sudo apt install git (Debian/Ubuntu) or sudo dnf install git (Fedora)"
    fi
    exit 1
fi

# --- Check curl ---
if command -v curl &>/dev/null; then
    success "curl installed"
else
    fail "curl is required but not installed"
    exit 1
fi

# --- Check Obsidian ---
OBSIDIAN_FOUND=false
if [ "$PLATFORM" = "macos" ]; then
    if [ -d "/Applications/Obsidian.app" ] || [ -d "$HOME/Applications/Obsidian.app" ]; then
        OBSIDIAN_FOUND=true
        success "Obsidian installed"
    fi
else
    if command -v obsidian &>/dev/null || [ -f "/usr/bin/obsidian" ] || flatpak list 2>/dev/null | grep -qi obsidian; then
        OBSIDIAN_FOUND=true
        success "Obsidian installed"
    fi
fi

if [ "$OBSIDIAN_FOUND" = false ]; then
    warn "Obsidian not found"
    info "Download from: https://obsidian.md/download"
    echo ""
    read -rp "  Continue anyway? (y/n) " CONTINUE
    if [ "$CONTINUE" != "y" ] && [ "$CONTINUE" != "Y" ]; then
        exit 1
    fi
fi

# --- Check brew (macOS only) ---
if [ "$PLATFORM" = "macos" ]; then
    if command -v brew &>/dev/null; then
        success "Homebrew installed"
    else
        warn "Homebrew not found (optional but recommended)"
        info "Install from: https://brew.sh"
    fi
fi

# --- Clone / Copy vault ---
echo ""
echo -e "${BOLD}Setting up CortexOS vault...${NC}"
echo ""

VAULT_DIR="$HOME/CortexOS"
REPO_URL="https://github.com/AyanaayaW/cortexOS.git"

if [ -d "$VAULT_DIR/.git" ]; then
    info "CortexOS vault already exists at $VAULT_DIR"
    info "Pulling latest changes..."
    cd "$VAULT_DIR" && git pull origin main 2>/dev/null || true
    success "Vault updated"
else
    if [ -d "$VAULT_DIR" ]; then
        warn "Directory $VAULT_DIR exists but is not a git repo"
        info "Backing up to ${VAULT_DIR}.bak and cloning fresh..."
        mv "$VAULT_DIR" "${VAULT_DIR}.bak"
    fi
    info "Cloning CortexOS into $VAULT_DIR..."
    git clone "$REPO_URL" "$VAULT_DIR" && success "Vault cloned" || {
        fail "Clone failed — check your internet connection"
        exit 1
    }
    cd "$VAULT_DIR"
fi

# ============================================
# --- Install Obsidian Plugins ---
# ============================================

echo ""
echo -e "${BOLD}Installing Obsidian plugins...${NC}"
echo ""

PLUGINS_DIR="$VAULT_DIR/.obsidian/plugins"
mkdir -p "$PLUGINS_DIR"

# Install a plugin by downloading its latest GitHub release
# Usage: install_plugin "github-org/repo" "plugin-id" "Display Name"
install_plugin() {
    local repo="$1"
    local plugin_id="$2"
    local display_name="$3"
    local plugin_dir="$PLUGINS_DIR/$plugin_id"

    mkdir -p "$plugin_dir"

    # Get the latest release tag from the GitHub API
    local release_json
    release_json=$(curl -sL "https://api.github.com/repos/$repo/releases/latest" 2>/dev/null)

    local tag
    tag=$(echo "$release_json" | grep '"tag_name"' | head -1 | sed -E 's/.*"tag_name"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/')

    if [ -z "$tag" ]; then
        warn "$display_name — could not fetch latest release"
        return 1
    fi

    # Download main.js, manifest.json, and optionally styles.css
    local base_url="https://github.com/$repo/releases/download/$tag"
    local got_main=false
    local got_manifest=false

    if curl -sL -f "$base_url/main.js" -o "$plugin_dir/main.js" 2>/dev/null; then
        got_main=true
    fi

    if curl -sL -f "$base_url/manifest.json" -o "$plugin_dir/manifest.json" 2>/dev/null; then
        got_manifest=true
    fi

    # styles.css is optional — don't fail if missing
    curl -sL -f "$base_url/styles.css" -o "$plugin_dir/styles.css" 2>/dev/null || rm -f "$plugin_dir/styles.css"

    if [ "$got_main" = true ] && [ "$got_manifest" = true ]; then
        success "$display_name ($tag)"
        return 0
    else
        warn "$display_name — download incomplete, may need manual install"
        return 1
    fi
}

# Plugin registry: "github-org/repo" "obsidian-plugin-id" "Display Name"
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

# --- Enable all plugins in community-plugins.json ---
info "Enabling plugins..."

cat > "$VAULT_DIR/.obsidian/community-plugins.json" << 'PLUGINS_EOF'
[
  "obsidian-git",
  "templater-obsidian",
  "dataview",
  "quickadd",
  "buttons",
  "cmdr",
  "calendar",
  "obsidian-tasks-plugin",
  "obsidian-spaced-repetition",
  "smart-connections",
  "terminal"
]
PLUGINS_EOF

success "All plugins enabled"

# --- User profile ---
echo ""
echo -e "${BOLD}What will you use CortexOS for?${NC}"
echo ""
echo "  1) Academic (student — any level, any curriculum)"
echo "  2) Professional (work projects, industry research)"
echo "  3) Personal (hobbies, self-learning, creative projects)"
echo "  4) Mixed (all of the above)"
echo ""
read -rp "  Choose (1-4): " PROFILE_CHOICE

case "$PROFILE_CHOICE" in
    1) PROFILE="academic" ;;
    2) PROFILE="professional" ;;
    3) PROFILE="personal" ;;
    *) PROFILE="mixed" ;;
esac

mkdir -p "$VAULT_DIR/_System/Config"
cat > "$VAULT_DIR/_System/Config/user-profile.md" << EOF
---
type: config
profile: $PROFILE
created: $(date +%Y-%m-%d)
---

# User Profile

**Profile type:** $PROFILE

This was set during CortexOS installation. Your Spaces and content generation will adapt to this profile.
EOF
success "Profile saved: $PROFILE"

# --- AI setup ---
echo ""
echo -e "${BOLD}AI Setup (all optional — skip any you don't want)${NC}"
echo ""

# Claude
echo -e "  ${CYAN}Claude (Anthropic CLI)${NC}"
if command -v claude &>/dev/null; then
    success "Claude CLI installed"
else
    warn "Claude CLI not found"
    info "Install: npm install -g @anthropic-ai/claude-code"
    info "More info: https://claude.ai/code"
    echo ""
    read -rp "  Install Claude CLI now? (y/n) " INSTALL_CLAUDE
    if [ "$INSTALL_CLAUDE" = "y" ] || [ "$INSTALL_CLAUDE" = "Y" ]; then
        if command -v npm &>/dev/null; then
            npm install -g @anthropic-ai/claude-code && success "Claude CLI installed" || warn "Installation failed — try manually"
        else
            warn "npm not found — install Node.js first: https://nodejs.org"
        fi
    fi
fi

echo ""

# Gemini
echo -e "  ${CYAN}Gemini (Google CLI)${NC}"
if command -v gemini &>/dev/null; then
    success "Gemini CLI installed"
else
    warn "Gemini CLI not found"
    info "Install from: https://ai.google.dev/gemini-api/docs/gemini-cli"
fi

echo ""

# Ollama
echo -e "  ${CYAN}Ollama (free, local, offline)${NC}"
if command -v ollama &>/dev/null; then
    success "Ollama installed"
    echo ""
    read -rp "  Pull llama3.2 model? (y/n) " PULL_OLLAMA
    if [ "$PULL_OLLAMA" = "y" ] || [ "$PULL_OLLAMA" = "Y" ]; then
        ollama pull llama3.2 && success "llama3.2 downloaded" || warn "Pull failed — try: ollama pull llama3.2"
    fi
else
    warn "Ollama not found"
    echo ""
    read -rp "  Install Ollama now? (y/n) " INSTALL_OLLAMA
    if [ "$INSTALL_OLLAMA" = "y" ] || [ "$INSTALL_OLLAMA" = "Y" ]; then
        if [ "$PLATFORM" = "macos" ]; then
            if command -v brew &>/dev/null; then
                brew install ollama && success "Ollama installed" || warn "Installation failed"
            else
                info "Install Homebrew first: https://brew.sh"
                info "Then run: brew install ollama"
            fi
        else
            curl -fsSL https://ollama.com/install.sh | sh && success "Ollama installed" || warn "Installation failed"
        fi
        if command -v ollama &>/dev/null; then
            echo ""
            read -rp "  Pull llama3.2 model? (y/n) " PULL_OLLAMA
            if [ "$PULL_OLLAMA" = "y" ] || [ "$PULL_OLLAMA" = "Y" ]; then
                ollama pull llama3.2 && success "llama3.2 downloaded" || warn "Pull failed"
            fi
        fi
    fi
fi

# --- Open Obsidian ---
echo ""
echo -e "${BOLD}Opening CortexOS in Obsidian...${NC}"
echo ""

if [ "$PLATFORM" = "macos" ]; then
    open "obsidian://open?vault=CortexOS" 2>/dev/null && success "Obsidian opened" || warn "Could not open Obsidian automatically — open it manually and select ~/CortexOS"
else
    xdg-open "obsidian://open?vault=CortexOS" 2>/dev/null && success "Obsidian opened" || warn "Could not open Obsidian automatically — open it manually and select ~/CortexOS"
fi

# --- Summary ---
echo ""
echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}${BOLD}║         CortexOS is ready! 🧠            ║${NC}"
echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${BOLD}Vault location:${NC}  ~/CortexOS/"
echo -e "  ${BOLD}Profile:${NC}          $PROFILE"
echo -e "  ${BOLD}Plugins:${NC}          11 installed and enabled"
echo ""
echo -e "  ${BOLD}Next steps:${NC}"
echo -e "    1. Open Dashboard.md — it's your home screen"
echo -e "    2. Click '+ New Space' to create your first Space"
echo -e "    3. Drop reference material into your Space's Sources/ folder"
echo -e "    4. Create notes and use the AI buttons to generate content"
echo ""
echo -e "  ${BOLD}Update anytime:${NC}  cd ~/CortexOS && bash update.sh"
echo ""
