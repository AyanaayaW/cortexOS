# ============================================
# CortexOS Installer — Windows (PowerShell)
# ============================================

$ErrorActionPreference = "Continue"

function Print-Header {
    Write-Host ""
    Write-Host "+==============================================+" -ForegroundColor Blue
    Write-Host "|             CortexOS Installer                |" -ForegroundColor Blue
    Write-Host "|    AI-powered second brain for everyone       |" -ForegroundColor Blue
    Write-Host "+==============================================+" -ForegroundColor Blue
    Write-Host ""
}

function Success($msg) { Write-Host "  [OK] $msg" -ForegroundColor Green }
function Warn($msg)    { Write-Host "  [!!] $msg" -ForegroundColor Yellow }
function Fail($msg)    { Write-Host "  [X]  $msg" -ForegroundColor Red }
function Info($msg)    { Write-Host "  -->  $msg" -ForegroundColor Cyan }

Print-Header

Write-Host "Checking dependencies..." -ForegroundColor White
Write-Host ""

# --- Check git ---
$gitPath = Get-Command git -ErrorAction SilentlyContinue
if ($gitPath) {
    $gitVersion = git --version
    Success "git installed ($gitVersion)"
} else {
    Fail "git is not installed"
    Info "Install with: winget install --id Git.Git"
    Info "Or download from: https://git-scm.com/download/win"
    $installGit = Read-Host "  Install git with winget now? (y/n)"
    if ($installGit -eq "y") {
        $wingetPath = Get-Command winget -ErrorAction SilentlyContinue
        if ($wingetPath) {
            winget install --id Git.Git -e --accept-package-agreements --accept-source-agreements
            Success "git installed — restart PowerShell to use it"
        } else {
            Warn "winget not available — download git manually from https://git-scm.com/download/win"
        }
    }
}

# --- Check Obsidian ---
$obsidianPath = "$env:LOCALAPPDATA\Obsidian\Obsidian.exe"
if (Test-Path $obsidianPath) {
    Success "Obsidian installed"
} else {
    # Also check Program Files
    $obsidianAlt = Get-Command obsidian -ErrorAction SilentlyContinue
    if ($obsidianAlt) {
        Success "Obsidian installed"
    } else {
        Warn "Obsidian not found"
        Info "Download from: https://obsidian.md/download"
        $continue = Read-Host "  Continue anyway? (y/n)"
        if ($continue -ne "y") { exit 1 }
    }
}

# --- Clone / Copy vault ---
Write-Host ""
Write-Host "Setting up CortexOS vault..." -ForegroundColor White
Write-Host ""

$vaultDir = "$HOME\CortexOS"

if (Test-Path "$vaultDir\.git") {
    Info "CortexOS vault already exists at $vaultDir"
    Info "Pulling latest changes..."
    Set-Location $vaultDir
    git pull origin main 2>$null
    Success "Vault updated"
} elseif (Test-Path $vaultDir) {
    Info "Directory exists — initializing git..."
    Set-Location $vaultDir
    git init
    git branch -M main
    Success "Vault initialized at $vaultDir"
} else {
    Info "Creating vault at $vaultDir..."
    New-Item -ItemType Directory -Path $vaultDir -Force | Out-Null
    Set-Location $vaultDir
    git init
    git branch -M main
    Success "Vault created at $vaultDir"
}

# --- User profile ---
Write-Host ""
Write-Host "What will you use CortexOS for?" -ForegroundColor White
Write-Host ""
Write-Host "  1) Academic (student - any level, any curriculum)"
Write-Host "  2) Professional (work projects, industry research)"
Write-Host "  3) Personal (hobbies, self-learning, creative projects)"
Write-Host "  4) Mixed (all of the above)"
Write-Host ""
$profileChoice = Read-Host "  Choose (1-4)"

switch ($profileChoice) {
    "1" { $profile = "academic" }
    "2" { $profile = "professional" }
    "3" { $profile = "personal" }
    default { $profile = "mixed" }
}

$configDir = "$vaultDir\_System\Config"
if (-not (Test-Path $configDir)) { New-Item -ItemType Directory -Path $configDir -Force | Out-Null }

$profileContent = @"
---
type: config
profile: $profile
created: $(Get-Date -Format "yyyy-MM-dd")
---

# User Profile

**Profile type:** $profile

This was set during CortexOS installation. Your Spaces and content generation will adapt to this profile.
"@

Set-Content -Path "$configDir\user-profile.md" -Value $profileContent -Encoding UTF8
Success "Profile saved: $profile"

# --- AI Setup ---
Write-Host ""
Write-Host "AI Setup (all optional - skip any you don't want)" -ForegroundColor White
Write-Host ""

# Claude
Write-Host "  Claude (Anthropic CLI)" -ForegroundColor Cyan
$claudePath = Get-Command claude -ErrorAction SilentlyContinue
if ($claudePath) {
    Success "Claude CLI installed"
} else {
    Warn "Claude CLI not found"
    Info "Install: npm install -g @anthropic-ai/claude-code"
    Info "More info: https://claude.ai/code"
    $installClaude = Read-Host "  Install Claude CLI now? (y/n)"
    if ($installClaude -eq "y") {
        $npmPath = Get-Command npm -ErrorAction SilentlyContinue
        if ($npmPath) {
            npm install -g @anthropic-ai/claude-code
            Success "Claude CLI installed"
        } else {
            Warn "npm not found - install Node.js first: https://nodejs.org"
        }
    }
}

Write-Host ""

# Gemini
Write-Host "  Gemini (Google CLI)" -ForegroundColor Cyan
$geminiPath = Get-Command gemini -ErrorAction SilentlyContinue
if ($geminiPath) {
    Success "Gemini CLI installed"
} else {
    Warn "Gemini CLI not found"
    Info "Install from: https://ai.google.dev/gemini-api/docs/gemini-cli"
}

Write-Host ""

# Ollama
Write-Host "  Ollama (free, local, offline)" -ForegroundColor Cyan
$ollamaPath = Get-Command ollama -ErrorAction SilentlyContinue
if ($ollamaPath) {
    Success "Ollama installed"
    $pullOllama = Read-Host "  Pull llama3.2 model? (y/n)"
    if ($pullOllama -eq "y") {
        ollama pull llama3.2
        Success "llama3.2 downloaded"
    }
} else {
    Warn "Ollama not found"
    $installOllama = Read-Host "  Install Ollama now? (y/n)"
    if ($installOllama -eq "y") {
        $wingetPath = Get-Command winget -ErrorAction SilentlyContinue
        if ($wingetPath) {
            winget install --id Ollama.Ollama -e --accept-package-agreements --accept-source-agreements
            Success "Ollama installed — restart PowerShell, then run: ollama pull llama3.2"
        } else {
            Warn "winget not available — download from https://ollama.com/download"
        }
    }
}

# --- Plugin list ---
Write-Host ""
Write-Host "================================================" -ForegroundColor White
Write-Host "  Obsidian Plugins to Install" -ForegroundColor White
Write-Host "================================================" -ForegroundColor White
Write-Host ""
Write-Host "  Open Obsidian -> Settings -> Community Plugins -> Browse" -ForegroundColor Gray
Write-Host ""
Write-Host "  Required plugins:" -ForegroundColor Cyan
Write-Host "    * Obsidian Git       - Vinzent Steinberg      (auto GitHub sync)"
Write-Host "    * Templater          - SilentVoid13           (smart templates)"
Write-Host "    * Dataview           - Michael Brenan         (live queries)"
Write-Host "    * QuickAdd           - Christian B. B. Houmann (macros + capture)"
Write-Host "    * Buttons            - shabegom               (in-note buttons)"
Write-Host "    * Commander          - Johnny Nguyen           (ribbon shortcuts)"
Write-Host "    * Calendar           - Liam Cain              (daily notes calendar)"
Write-Host "    * Tasks              - Martin Schenk          (task management)"
Write-Host "    * Spaced Repetition  - Stephen Mwangi         (flashcard review)"
Write-Host "    * Smart Connections  - Brian Petro            (AI chat sidebar)"
Write-Host "    * Obsidian Terminal  - polyipseity            (embedded terminal)"
Write-Host ""

# --- Open Obsidian ---
Write-Host "Opening CortexOS in Obsidian..." -ForegroundColor White
Write-Host ""

try {
    Start-Process "obsidian://open?vault=CortexOS"
    Success "Obsidian opened"
} catch {
    Warn "Could not open Obsidian automatically - open it manually and select $vaultDir"
}

# --- Summary ---
Write-Host ""
Write-Host "+==============================================+" -ForegroundColor Green
Write-Host "|          CortexOS is ready!                   |" -ForegroundColor Green
Write-Host "+==============================================+" -ForegroundColor Green
Write-Host ""
Write-Host "  Vault location:  $vaultDir" -ForegroundColor White
Write-Host "  Profile:         $profile" -ForegroundColor White
Write-Host ""
Write-Host "  Next steps:" -ForegroundColor White
Write-Host "    1. Install the plugins listed above in Obsidian"
Write-Host "    2. Open Dashboard.md - it's your home screen"
Write-Host "    3. Click '+ New Space' to create your first Space"
Write-Host "    4. Drop reference material into your Space's Sources/ folder"
Write-Host "    5. Create notes and use the AI buttons to generate content"
Write-Host ""
Write-Host "  Update anytime:  powershell -File update.ps1" -ForegroundColor Gray
Write-Host ""
