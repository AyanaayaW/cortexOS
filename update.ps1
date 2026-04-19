# ============================================
# CortexOS Updater — Windows (PowerShell)
# ============================================

$ErrorActionPreference = "Continue"

function Success($msg) { Write-Host "  [OK] $msg" -ForegroundColor Green }
function Warn($msg)    { Write-Host "  [!!] $msg" -ForegroundColor Yellow }
function Info($msg)    { Write-Host "  -->  $msg" -ForegroundColor Cyan }

function Install-Plugin {
    param(
        [string]$Repo,
        [string]$PluginId,
        [string]$DisplayName
    )

    $pluginDir = "$vaultDir\.obsidian\plugins\$PluginId"
    if (-not (Test-Path $pluginDir)) { New-Item -ItemType Directory -Path $pluginDir -Force | Out-Null }

    try {
        $releaseInfo = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/releases/latest" -ErrorAction Stop
        $tag = $releaseInfo.tag_name
        $baseUrl = "https://github.com/$Repo/releases/download/$tag"

        Invoke-WebRequest -Uri "$baseUrl/main.js" -OutFile "$pluginDir\main.js" -ErrorAction Stop
        Invoke-WebRequest -Uri "$baseUrl/manifest.json" -OutFile "$pluginDir\manifest.json" -ErrorAction Stop
        try { Invoke-WebRequest -Uri "$baseUrl/styles.css" -OutFile "$pluginDir\styles.css" -ErrorAction Stop } catch {}

        Success "$DisplayName -> $tag"
    } catch {
        Warn "$DisplayName - could not update"
    }
}

$vaultDir = "$HOME\CortexOS"

if (-not (Test-Path "$vaultDir\.git")) {
    Warn "No CortexOS vault found at $vaultDir"
    Write-Host "  Run install.ps1 first."
    exit 1
}

# --- Pull vault updates ---
Write-Host ""
Write-Host "Updating CortexOS vault..." -ForegroundColor White
Set-Location $vaultDir
git pull origin main 2>$null
Success "Vault files updated"

# --- Update plugins ---
Write-Host ""
Write-Host "Updating plugins..." -ForegroundColor White
Write-Host ""

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

Write-Host ""
Write-Host "  CortexOS updated. Restart Obsidian to load new plugin versions." -ForegroundColor Green
Write-Host ""
