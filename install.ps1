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

# Download a plugin from its GitHub latest release
function Install-Plugin {
    param(
        [string]$Repo,
        [string]$PluginId,
        [string]$DisplayName
    )

    $pluginDir = "$vaultDir\.obsidian\plugins\$PluginId"
    if (-not (Test-Path $pluginDir)) { New-Item -ItemType Directory -Path $pluginDir -Force | Out-Null }

    try {
        # Get latest release tag
        $releaseInfo = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/releases/latest" -ErrorAction Stop
        $tag = $releaseInfo.tag_name

        $baseUrl = "https://github.com/$Repo/releases/download/$tag"

        # Download main.js and manifest.json (required)
        Invoke-WebRequest -Uri "$baseUrl/main.js" -OutFile "$pluginDir\main.js" -ErrorAction Stop
        Invoke-WebRequest -Uri "$baseUrl/manifest.json" -OutFile "$pluginDir\manifest.json" -ErrorAction Stop

        # Download styles.css (optional — don't fail if missing)
        try {
            Invoke-WebRequest -Uri "$baseUrl/styles.css" -OutFile "$pluginDir\styles.css" -ErrorAction Stop
        } catch {
            # No styles.css for this plugin — that's fine
        }

        Success "$DisplayName ($tag)"
    } catch {
        Warn "$DisplayName - could not download, may need manual install"
    }
}

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
            Success "git installed - restart PowerShell to use it"
        } else {
            Warn "winget not available - download git manually from https://git-scm.com/download/win"
        }
    }
}

# --- Check Obsidian ---
$obsidianPath = "$env:LOCALAPPDATA\Obsidian\Obsidian.exe"
if (Test-Path $obsidianPath) {
    Success "Obsidian installed"
} else {
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
$repoUrl = "https://github.com/AyanaayaW/cortexOS.git"

if (Test-Path "$vaultDir\.git") {
    Info "CortexOS vault already exists at $vaultDir"
    Info "Pulling latest changes..."
    Set-Location $vaultDir
    git pull origin main 2>$null
    Success "Vault updated"
} elseif (Test-Path $vaultDir) {
    Warn "Directory $vaultDir exists but is not a git repo"
    Info "Backing up and cloning fresh..."
    Rename-Item $vaultDir "$vaultDir.bak"
    git clone $repoUrl $vaultDir
    Set-Location $vaultDir
    Success "Vault cloned"
} else {
    Info "Cloning CortexOS into $vaultDir..."
    git clone $repoUrl $vaultDir
    Set-Location $vaultDir
    Success "Vault cloned"
}

# ============================================
# --- Install Obsidian Plugins ---
# ============================================

Write-Host ""
Write-Host "Installing Obsidian plugins..." -ForegroundColor White
Write-Host ""

$pluginsDir = "$vaultDir\.obsidian\plugins"
if (-not (Test-Path $pluginsDir)) { New-Item -ItemType Directory -Path $pluginsDir -Force | Out-Null }

Install-Plugin -Repo "denolehov/obsidian-git"                    -PluginId "obsidian-git"               -DisplayName "Obsidian Git"
Install-Plugin -Repo "SilentVoid13/Templater"                    -PluginId "templater-obsidian"         -DisplayName "Templater"
Install-Plugin -Repo "blacksmithgu/obsidian-dataview"            -PluginId "dataview"                   -DisplayName "Dataview"
Install-Plugin -Repo "chhoumann/quickadd"                        -PluginId "quickadd"                   -DisplayName "QuickAdd"
Install-Plugin -Repo "shabegom/buttons"                          -PluginId "buttons"                    -DisplayName "Buttons"
Install-Plugin -Repo "phibr0/obsidian-commander"                 -PluginId "cmdr"                       -DisplayName "Commander"
Install-Plugin -Repo "liamcain/obsidian-calendar-plugin"         -PluginId "calendar"                   -DisplayName "Calendar"
Install-Plugin -Repo "obsidian-tasks-group/obsidian-tasks"       -PluginId "obsidian-tasks-plugin"       -DisplayName "Tasks"
Install-Plugin -Repo "st3v3nmw/obsidian-spaced-repetition"       -PluginId "obsidian-spaced-repetition"  -DisplayName "Spaced Repetition"
Install-Plugin -Repo "brianpetro/obsidian-smart-connections"     -PluginId "smart-connections"           -DisplayName "Smart Connections"
Install-Plugin -Repo "polyipseity/obsidian-terminal"             -PluginId "terminal"                   -DisplayName "Terminal"

# --- Enable all plugins ---
Info "Enabling plugins..."

$communityPlugins = @'
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
'@

Set-Content -Path "$vaultDir\.obsidian\community-plugins.json" -Value $communityPlugins -Encoding UTF8
Success "All plugins enabled"

# --- Write default workspace layout (terminal in right pane) ---
$workspaceFile = "$vaultDir\.obsidian\workspace.json"
if (-not (Test-Path $workspaceFile)) {
    $workspaceJson = @'
{
  "main": {
    "id": "a0b1c2d3e4f50001",
    "type": "split",
    "children": [
      {
        "id": "a0b1c2d3e4f50002",
        "type": "tabs",
        "children": [
          {
            "id": "a0b1c2d3e4f50003",
            "type": "leaf",
            "state": {
              "type": "empty",
              "state": {},
              "icon": "lucide-file",
              "title": "New tab"
            }
          }
        ]
      }
    ],
    "direction": "vertical"
  },
  "left": {
    "id": "a0b1c2d3e4f50010",
    "type": "split",
    "children": [
      {
        "id": "a0b1c2d3e4f50011",
        "type": "tabs",
        "children": [
          {
            "id": "a0b1c2d3e4f50012",
            "type": "leaf",
            "state": {
              "type": "file-explorer",
              "state": {
                "sortOrder": "alphabetical",
                "autoReveal": false
              },
              "icon": "lucide-folder-closed",
              "title": "Files"
            }
          },
          {
            "id": "a0b1c2d3e4f50013",
            "type": "leaf",
            "state": {
              "type": "search",
              "state": {
                "query": "",
                "matchingCase": false,
                "explainSearch": false,
                "collapseAll": false,
                "extraContext": false,
                "sortOrder": "alphabetical"
              },
              "icon": "lucide-search",
              "title": "Search"
            }
          },
          {
            "id": "a0b1c2d3e4f50014",
            "type": "leaf",
            "state": {
              "type": "bookmarks",
              "state": {},
              "icon": "lucide-bookmark",
              "title": "Bookmarks"
            }
          }
        ]
      }
    ],
    "direction": "horizontal",
    "width": 200
  },
  "right": {
    "id": "a0b1c2d3e4f50020",
    "type": "split",
    "children": [
      {
        "id": "a0b1c2d3e4f50021",
        "type": "tabs",
        "children": [
          {
            "id": "a0b1c2d3e4f50022",
            "type": "leaf",
            "state": {
              "type": "terminal:terminal",
              "state": {
                "terminal:terminal": {
                  "cwd": null,
                  "focus": false,
                  "profile": {
                    "args": [],
                    "executable": "powershell.exe",
                    "followTheme": true,
                    "name": "CortexOS Terminal (Windows)",
                    "platforms": {
                      "darwin": false,
                      "linux": false,
                      "win32": true
                    },
                    "pythonExecutable": "python.exe",
                    "restoreHistory": false,
                    "rightClickAction": "copyPaste",
                    "successExitCodes": ["0", "SIGINT", "SIGTERM"],
                    "terminalOptions": {
                      "documentOverride": null
                    },
                    "type": "integrated",
                    "useWin32Conhost": true
                  },
                  "serial": null
                }
              },
              "icon": "lucide-terminal",
              "title": "Terminal"
            }
          },
          {
            "id": "a0b1c2d3e4f50023",
            "type": "leaf",
            "state": {
              "type": "backlink",
              "state": {
                "collapseAll": false,
                "extraContext": false,
                "sortOrder": "alphabetical",
                "showSearch": false,
                "searchQuery": "",
                "backlinkCollapsed": false,
                "unlinkedCollapsed": true
              },
              "icon": "links-coming-in",
              "title": "Backlinks"
            }
          },
          {
            "id": "a0b1c2d3e4f50024",
            "type": "leaf",
            "state": {
              "type": "smart-connections-view",
              "state": {},
              "icon": "smart-connections",
              "title": "Connections"
            }
          },
          {
            "id": "a0b1c2d3e4f50025",
            "type": "leaf",
            "state": {
              "type": "tag",
              "state": {
                "sortOrder": "frequency",
                "useHierarchy": true,
                "showSearch": false,
                "searchQuery": ""
              },
              "icon": "lucide-tags",
              "title": "Tags"
            }
          }
        ],
        "currentTab": 0
      }
    ],
    "direction": "horizontal",
    "width": 300
  },
  "left-ribbon": {
    "hiddenItems": {
      "switcher:Open quick switcher": false,
      "graph:Open graph view": false,
      "canvas:Create new canvas": false,
      "command-palette:Open command palette": false,
      "terminal:Open terminal": false
    }
  },
  "active": "a0b1c2d3e4f50022",
  "lastOpenFiles": []
}
'@
    Set-Content -Path $workspaceFile -Value $workspaceJson -Encoding UTF8
    Success "Default workspace layout set (terminal in right pane)"
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
            Success "Ollama installed - restart PowerShell, then run: ollama pull llama3.2"
        } else {
            Warn "winget not available - download from https://ollama.com/download"
        }
    }
}

# --- Open Obsidian ---
Write-Host ""
Write-Host "Opening CortexOS in Obsidian..." -ForegroundColor White
Write-Host ""

# Register the vault in Obsidian's config so it knows about it
$obsidianConfig = "$env:APPDATA\obsidian\obsidian.json"
if (-not (Test-Path (Split-Path $obsidianConfig))) {
    New-Item -ItemType Directory -Path (Split-Path $obsidianConfig) -Force | Out-Null
}
if (-not (Test-Path $obsidianConfig)) {
    '{"vaults":{}}' | Set-Content $obsidianConfig -Encoding UTF8
}

try {
    $config = Get-Content $obsidianConfig -Raw | ConvertFrom-Json
    # Check if vault already registered
    $alreadyRegistered = $false
    if ($config.vaults) {
        foreach ($prop in $config.vaults.PSObject.Properties) {
            if ($prop.Value.path -eq $vaultDir) { $alreadyRegistered = $true; break }
        }
    }
    if (-not $alreadyRegistered) {
        $vid = [guid]::NewGuid().ToString("N").Substring(0, 16)
        $ts = [long]([datetime]::UtcNow - [datetime]"1970-01-01").TotalMilliseconds
        $config.vaults | Add-Member -NotePropertyName $vid -NotePropertyValue @{ path = $vaultDir; ts = $ts }
        $config | ConvertTo-Json -Depth 10 | Set-Content $obsidianConfig -Encoding UTF8
        Info "Vault registered with Obsidian"
    }
} catch {
    Warn "Could not auto-register vault - you may need to open the folder manually in Obsidian"
}

try {
    Start-Process "obsidian://open?vault=CortexOS"
    Success "Obsidian opened"
} catch {
    Warn "Could not open Obsidian automatically - open $vaultDir in Obsidian manually"
}

# --- Summary ---
Write-Host ""
Write-Host "+==============================================+" -ForegroundColor Green
Write-Host "|          CortexOS is ready!                   |" -ForegroundColor Green
Write-Host "+==============================================+" -ForegroundColor Green
Write-Host ""
Write-Host "  Vault location:  $vaultDir" -ForegroundColor White
Write-Host "  Profile:         $profile" -ForegroundColor White
Write-Host "  Plugins:         11 installed and enabled" -ForegroundColor White
Write-Host ""
Write-Host "  IMPORTANT - first launch only:" -ForegroundColor Yellow
Write-Host "    When Obsidian opens, it will ask about community plugins."
Write-Host "    Click 'Turn off restricted mode' then 'Trust author and enable plugins'."
Write-Host "    This activates all 11 plugins. You only need to do this once."
Write-Host ""
Write-Host "  Next steps:" -ForegroundColor White
Write-Host "    1. Open Dashboard.md - it's your home screen"
Write-Host "    2. Click '+ New Space' to create your first Space"
Write-Host "    3. Drop reference material into your Space's Sources/ folder"
Write-Host "    4. Create notes and use the AI buttons to generate content"
Write-Host ""
Write-Host "  Update anytime:  cd ~\CortexOS && powershell -File update.ps1" -ForegroundColor Gray
Write-Host ""
