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
if [ -d "$VAULT_DIR/.git" ]; then
    info "CortexOS vault already exists at $VAULT_DIR"
    info "Pulling latest changes..."
    cd "$VAULT_DIR" && git pull origin main 2>/dev/null || true
    success "Vault updated"
else
    if [ -d "$VAULT_DIR" ]; then
        info "Directory exists but is not a git repo — initializing..."
        cd "$VAULT_DIR"
        if [ ! -d ".git" ]; then
            git init
            git branch -M main
        fi
        success "Vault initialized at $VAULT_DIR"
    else
        info "Creating vault at $VAULT_DIR..."
        mkdir -p "$VAULT_DIR"
        cd "$VAULT_DIR"
        git init
        git branch -M main
        success "Vault created at $VAULT_DIR"
    fi
fi

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

# --- Print plugin list ---
echo ""
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}  Obsidian Plugins to Install${NC}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  Open Obsidian → Settings → Community Plugins → Browse"
echo ""
echo -e "  ${CYAN}Required plugins:${NC}"
echo -e "    • ${BOLD}Obsidian Git${NC}       — Vinzent Steinberg      (auto GitHub sync)"
echo -e "    • ${BOLD}Templater${NC}          — SilentVoid13           (smart templates)"
echo -e "    • ${BOLD}Dataview${NC}           — Michael Brenan         (live queries)"
echo -e "    • ${BOLD}QuickAdd${NC}           — Christian B. B. Houmann (macros + capture)"
echo -e "    • ${BOLD}Buttons${NC}            — shabegom               (in-note buttons)"
echo -e "    • ${BOLD}Commander${NC}          — Johnny Nguyen           (ribbon shortcuts)"
echo -e "    • ${BOLD}Calendar${NC}           — Liam Cain              (daily notes calendar)"
echo -e "    • ${BOLD}Tasks${NC}              — Martin Schenk          (task management)"
echo -e "    • ${BOLD}Spaced Repetition${NC}  — Stephen Mwangi         (flashcard review)"
echo -e "    • ${BOLD}Smart Connections${NC}  — Brian Petro            (AI chat sidebar)"
echo -e "    • ${BOLD}Obsidian Terminal${NC}  — polyipseity            (embedded terminal)"
echo ""

# --- Open Obsidian ---
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
echo ""
echo -e "  ${BOLD}Next steps:${NC}"
echo -e "    1. Install the plugins listed above in Obsidian"
echo -e "    2. Open Dashboard.md — it's your home screen"
echo -e "    3. Click '+ New Space' to create your first Space"
echo -e "    4. Drop reference material into your Space's Sources/ folder"
echo -e "    5. Create notes and use the AI buttons to generate content"
echo ""
echo -e "  ${BOLD}Update anytime:${NC}  bash update.sh"
echo ""
