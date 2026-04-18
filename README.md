<div align="center">

# 🧠 cortexOS

**An AI-powered Obsidian vault for students.**
Turn any AI tool into study notes, worksheets, and explanations — all from inside Obsidian.

IB Diploma · A-Levels · University · Any structured study system.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0-green.svg)](https://github.com/AyanaayaW/cortexOS/releases/tag/v1.0)
[![Obsidian](https://img.shields.io/badge/Obsidian-compatible-7C3AED)](https://obsidian.md)

</div>

---

## Table of Contents

1. [What is cortexOS?](#what-is-cortexos)
2. [What You Get](#what-you-get)
3. [Before You Start](#before-you-start)
4. [Installation](#installation)
5. [Open the Vault in Obsidian](#open-the-vault-in-obsidian)
6. [Install Community Plugins](#install-community-plugins)
7. [Configure Each Plugin](#configure-each-plugin)
8. [Add Your Subjects](#add-your-subjects)
9. [Set Up the Button Menu System](#set-up-the-button-menu-system)
10. [Using cortexOS — Obsidian Buttons](#using-cortexos--obsidian-buttons)
11. [Using cortexOS — Terminal](#using-cortexos--terminal)
12. [Keeping cortexOS Updated](#keeping-cortexos-updated)
13. [Note Frontmatter Format](#note-frontmatter-format)
14. [Troubleshooting](#troubleshooting)
15. [Contributing](#contributing)

---

## What is cortexOS?

cortexOS is a ready-to-clone Obsidian vault that connects Claude, Gemini, and Ollama to a single, consistent study workflow. Instead of copy-pasting prompts into a chat window, you pick an action (note, explain, worksheet, summarise), pick a model, answer a few quick prompts — and a formatted Markdown file appears directly in your vault, already frontmatter-tagged and ready for Dataview queries.

**It works two ways:**
- **Obsidian buttons** — click toolbar icons or the Dashboard note; fuzzy-search menus handle everything
- **Terminal scripts** — four shell scripts with a consistent `action model subject "topic"` interface

---

## What You Get

```
cortexOS/
├── Notes/
│   └── <Subject>/           ← your handwritten notes go here
├── Worksheets/
│   └── <Subject>/           ← saved practice sheets
├── AI Outputs/
│   ├── Notes/               ← AI-generated concept notes & summaries
│   ├── Explanations/        ← AI explanations of questions or files
│   └── Worksheets/          ← AI-generated worksheets with mark schemes
├── Assets/
│   ├── PDFs/                ← drop textbook PDFs here
│   ├── Images/
│   └── Formula Sheets/
├── Templates/
│   ├── Concept Note.md      ← Templater template
│   ├── Worksheet.md
│   └── AI Output.md
├── scripts/
│   ├── note                 ← shell script: generate a study note
│   ├── explain              ← shell script: explain a question or file
│   ├── worksheet            ← shell script: generate a worksheet
│   ├── summarise            ← shell script: summarise a PDF or text file
│   ├── cortexOS.js          ← QuickAdd script: full wizard
│   ├── cortexOS-note.js     ← QuickAdd script: note launcher
│   ├── cortexOS-explain.js  ← QuickAdd script: explain launcher
│   ├── cortexOS-worksheet.js
│   └── cortexOS-summarise.js
├── CLAUDE.md                ← persistent AI context — edit this first
├── SETUP_README.md
└── .gitignore
```

---

## Before You Start

You need a few tools installed before cortexOS will work. This section covers all of them.

### Obsidian

Download from [obsidian.md](https://obsidian.md) and install it. It's free.

---

### Git

**macOS:** Git ships with Xcode Command Line Tools. Open Terminal and run:

```bash
git --version
```

If it's not installed, macOS will prompt you to install it automatically. Click **Install** and wait.

---

### Homebrew (macOS package manager)

Most of the tools below install via Homebrew. Check if you have it:

```bash
brew --version
```

If not:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Follow the on-screen instructions. When it finishes, close and reopen Terminal.

---

### gh (GitHub CLI) — needed to push your vault to GitHub

```bash
brew install gh
gh auth login
```

When `gh auth login` runs:
- Choose **GitHub.com**
- Choose **HTTPS**
- Choose **Login with a web browser**
- Copy the one-time code shown, press Enter, and paste it in the browser tab that opens

---

### Claude Code

Claude Code is the CLI for Claude. Install from [claude.ai/code](https://claude.ai/code) and follow the setup instructions there.

Verify it's working:

```bash
claude --version
```

---

### Gemini CLI

```bash
npm install -g @google/gemini-cli
```

> **Don't have npm?** Install Node.js first: `brew install node`

Authenticate by running `gemini` once and following the browser login prompt.

Verify:

```bash
gemini --version
```

---

### Ollama (local/offline AI)

Download the macOS app from [ollama.com](https://ollama.com) and install it like any other app. Then pull a model:

```bash
ollama pull llama3.2
```

Verify Ollama is running:

```bash
ollama list
```

You should see `llama3.2` in the list.

---

### jq (JSON parser — required for Ollama routes)

```bash
brew install jq
```

Verify:

```bash
jq --version
```

---

### Quick verification — run all at once

```bash
claude --version && gemini --version && ollama list && jq --version && git --version && gh --version
```

All six should print version numbers. If any fail, revisit that section above.

---

## Installation

> 🖥️ **Everything in this section happens in Terminal.**

### 1. Clone the repo

```bash
git clone https://github.com/AyanaayaW/cortexOS.git ~/cortexOS
```

This creates a `cortexOS` folder in your home directory. You can clone it anywhere — just replace `~/cortexOS` with your preferred path throughout this guide.

### 2. Make the shell scripts executable

```bash
chmod +x ~/cortexOS/scripts/note \
         ~/cortexOS/scripts/explain \
         ~/cortexOS/scripts/worksheet \
         ~/cortexOS/scripts/summarise
```

### 3. Create your subject folders

Edit the list below to match your actual subjects, then paste it into Terminal:

```bash
SUBJECTS=("Math" "Physics" "Chemistry" "History" "English")

for s in "${SUBJECTS[@]}"; do
  mkdir -p ~/cortexOS/Notes/"$s"
  mkdir -p ~/cortexOS/Worksheets/"$s"
  mkdir -p ~/cortexOS/"AI Outputs"/Notes/"$s"
done
```

### 4. Push to your own private GitHub repo

```bash
cd ~/cortexOS
git init && git branch -M main
gh repo create cortexOS --private --source=. --remote=origin --push
```

This creates a private repo on your account and pushes everything to it. Obsidian Git will auto-sync from here on.

---

## Open the Vault in Obsidian

> 📱 **This section happens in Obsidian.**

1. Open **Obsidian**
2. On the home screen, click **Open folder as vault**
3. Navigate to your `cortexOS` folder (e.g. `~/cortexOS`) and click **Open**
4. If Obsidian asks *"Do you trust the author of this vault?"*, click **Trust author and enable plugins**

You should now see the cortexOS folder structure in the left sidebar.

---

## Install Community Plugins

> 📱 **This section happens in Obsidian.**

Obsidian has a built-in plugin store. You need to install **6 plugins** total.

### Step 1 — Enable community plugins

1. Click the **gear icon** (⚙️) in the bottom-left corner to open **Settings**
2. In the left sidebar of Settings, click **Community plugins**
3. Click the **Turn on community plugins** button (only needed the first time)
4. Click **Browse** to open the plugin store

### Step 2 — Install each plugin

For each plugin below, type its name in the search box, click the result, click **Install**, then click **Enable**.

| Plugin name (search for this) | Author | What it does |
|---|---|---|
| **Obsidian Git** | Vinzent Steinberg | Auto-commits and pushes your vault to GitHub every 5 minutes |
| **Templater** | SilentVoid13 | Smart templates with dynamic prompts when you create a note |
| **Dataview** | Michael Brenan | Lets the Dashboard query your notes like a database |
| **QuickAdd** | Christian B. B. Houmann | Powers the fuzzy-search menu system for AI actions |
| **Commander** | Johnny Nguyen | Adds custom buttons to the Obsidian toolbar |
| **Buttons** | shabegom | Renders clickable buttons inside notes |

> After installing all 6, close the plugin store (click **X** or press `Esc`).

---

## Configure Each Plugin

> 📱 **This section happens in Obsidian → Settings.**

### Templater

1. Go to **Settings** → **Templater** (in the left sidebar under "Community plugins")
2. Find **Template folder location** and type: `Templates`
3. Turn on **Trigger Templater on new file creation**
4. Close Settings

---

### Obsidian Git

Obsidian Git is pre-configured via the `data.json` already in the repo — auto-commit every 5 minutes, auto-push every 5 minutes, pull on boot. You don't need to change anything. To verify:

1. Go to **Settings** → **Obsidian Git**
2. Confirm **Auto backup interval** is `5` and **Auto push interval** is `5`

---

### QuickAdd — macros are pre-configured

The 5 QuickAdd macros are already written into `.obsidian/plugins/quickadd/data.json` inside the repo. When you opened the vault, QuickAdd loaded them automatically.

To verify they're there:

1. Go to **Settings** → **QuickAdd**
2. You should see these 5 entries in the choices list:
   - `cortexOS`
   - `cortexOS: Note`
   - `cortexOS: Explain`
   - `cortexOS: Worksheet`
   - `cortexOS: Summarise`

If you don't see them, close and reopen Obsidian once.

---

### Commander — add toolbar buttons

Commander lets you add icons to the top toolbar of every note. You'll add 5.

1. Go to **Settings** → **Commander**
2. Click **Editor toolbar** in the Commander settings
3. Click the **+** button to add a new toolbar item
4. In the search box that appears, type `QuickAdd: cortexOS` and select it
5. Click the icon next to the new item and choose **brain** (🧠)
6. Repeat for the remaining 4 — search for each command name and pick an icon:

| Search for | Suggested icon |
|---|---|
| `QuickAdd: cortexOS: Note` | `file-plus` |
| `QuickAdd: cortexOS: Explain` | `lightbulb` |
| `QuickAdd: cortexOS: Worksheet` | `clipboard-list` |
| `QuickAdd: cortexOS: Summarise` | `book-open` |

7. Close Settings

You should now see 5 icons at the top of every note.

---

## Add Your Subjects

### In CLAUDE.md (so the AI knows your courses)

Open `CLAUDE.md` in Obsidian. Find the **My Subjects** section and replace the placeholder table with your actual subjects:

```md
| Code  | Subject                  | Level |
|-------|--------------------------|-------|
| MATH  | Mathematics              | HL    |
| PHYS  | Physics                  | HL    |
| CHEM  | Chemistry                | SL    |
| ENG   | English Literature       | SL    |
| HIST  | History                  | SL    |
```

### In the QuickAdd scripts (so the menus show your subjects)

Open each of these files and replace the `SUBJECTS` array at the top with your actual subject names. The names must match your folder names exactly.

Files to edit:
- `scripts/cortexOS.js`
- `scripts/cortexOS-note.js`
- `scripts/cortexOS-explain.js`
- `scripts/cortexOS-worksheet.js`
- `scripts/cortexOS-summarise.js`

Find this line near the top of each file:

```js
const SUBJECTS = ["Subject 1", "Subject 2", "Subject 3", "Subject 4", "Subject 5"];
```

Replace it with your subjects, for example:

```js
const SUBJECTS = ["Math", "Physics", "Chemistry", "English", "History"];
```

---

## Set Up the Button Menu System

The button system is built on **QuickAdd** + **Commander** + **Buttons**. The macros are pre-configured. Here's how it all fits together:

```
Commander toolbar icon
        ↓
QuickAdd fuzzy-search modal opens
  Step 1 → Pick model  (Claude / Gemini / Ollama / Ollama·mistral)
  Step 2 → Pick subject
  Step 3 → Type topic or pick a file
  Step 4 → Pick detail  (note type / question count / etc.)
        ↓
Shell script runs in background
        ↓
Toast notification: "✅ Saved → AI Outputs/..."
        ↓
Output file opens automatically in Obsidian
```

The **Dashboard note** (`🧠 Dashboard.md` — see below) also has clickable Buttons-plugin buttons that trigger the same macros.

---

## Using cortexOS — Obsidian Buttons

> 📱 **This section happens entirely inside Obsidian.**

### Method 1 — Toolbar icons (available in every note)

After setting up Commander, you'll see icons in the top bar of every note:

| Icon | Action | What it asks you |
|---|---|---|
| 🧠 | Full wizard | Action → Model → Subject → Topic |
| 📝 | Note | Model → Subject → Topic → Note type |
| 💡 | Explain | Model → Question or file → Subject |
| 📋 | Worksheet | Model → Subject → Topic → No. of questions |
| 📄 | Summarise | Model → File from vault → Subject → Topic label |

Click any icon. A fuzzy-search modal appears. Use the arrow keys or start typing to filter options. Press `Enter` to confirm each step.

---

### Method 2 — Dashboard note

Open `🧠 Dashboard.md` from the file explorer. It contains:

- **Buttons** for each action (requires the Buttons plugin)
- A **Dataview table** showing your 12 most recent AI outputs
- An **Unreviewed** table showing AI notes you haven't verified yet
- Output stats grouped by type and subject

---

### The fuzzy-search menus in detail

Every action follows the same pattern. Here's an example for **Note**:

```
Step 1 — Model
┌─────────────────────────────────┐
│ ☁️  Claude                      │
│ ✨  Gemini                      │
│ 🦙  Ollama · llama3.2           │
│ 🦙  Ollama · mistral            │
└─────────────────────────────────┘
  ↓ select Claude

Step 2 — Subject
┌─────────────────────────────────┐
│ Math                            │
│ Physics                         │
│ Chemistry  ...                  │
└─────────────────────────────────┘
  ↓ select Physics

Step 3 — Topic  (free text input)
┌─────────────────────────────────┐
│ Newton's Laws                   │
└─────────────────────────────────┘
  ↓ type topic, press Enter

Step 4 — Note type
┌─────────────────────────────────┐
│ Concept Note                    │
│ Summary                         │
│ Essay Plan                      │
│ Revision                        │
└─────────────────────────────────┘
  ↓ select Concept Note

⚙️  Note · claude · Physics — running…   (toast appears)
✅  Saved → AI Outputs/Notes/Physics/2026-04-18 Newton's Laws — concept-note.md
```

The file opens automatically.

---

## Using cortexOS — Terminal

> 🖥️ **This section happens in Terminal.**

All four scripts follow the same interface: **action first, model second.**

```
./scripts/<action> <model> <subject> "<topic>"
```

Navigate to your vault first:

```bash
cd ~/cortexOS
```

---

### `note` — Generate a study note

```bash
./scripts/note <model> <subject> "<topic>" [type]
```

`type` is optional and defaults to `concept-note`. Options: `concept-note`, `summary`, `essay-plan`, `revision`.

```bash
./scripts/note claude  Physics "Newton's Laws"
./scripts/note gemini  Math    "Integration by Parts"
./scripts/note ollama  History "Causes of WWI" essay-plan
./scripts/note ollama/mistral Economics "Supply and Demand"
```

Output → `AI Outputs/Notes/<subject>/YYYY-MM-DD <topic> — <type>.md`

---

### `explain` — Explain a question or a file

```bash
./scripts/explain <model> "<question-or-filepath>" [subject]
```

The second argument can be a text question **or** a path to a file. cortexOS detects which it is automatically.

```bash
# Ask a question
./scripts/explain claude  "What is the photoelectric effect?" Physics
./scripts/explain ollama  "Explain entropy in simple terms"

# Explain a file
./scripts/explain gemini  "Assets/PDFs/chapter5.pdf" Physics
./scripts/explain gemini  ~/Downloads/lecture_notes.pdf Chemistry
```

Output → `AI Outputs/Explanations/YYYY-MM-DD <slug>.md`

---

### `worksheet` — Generate a worksheet with a full mark scheme

```bash
./scripts/worksheet <model> <subject> "<topic>" [num-questions]
```

`num-questions` defaults to `6`. Difficulty is automatically spread: 2 easy, 3 medium, 1 hard.

```bash
./scripts/worksheet claude  Math    "Differentiation" 8
./scripts/worksheet gemini  Physics "Electric Fields"
./scripts/worksheet ollama  Economics "Elasticity" 5
```

Output → `AI Outputs/Worksheets/YYYY-MM-DD <subject> — <topic> Worksheet.md`

---

### `summarise` — Summarise a PDF or text file into a structured note

```bash
./scripts/summarise <model> "<filepath>" <subject> "<topic>"
```

```bash
./scripts/summarise gemini  "Assets/PDFs/textbook.pdf" Chemistry "Equilibrium"
./scripts/summarise claude  "Assets/PDFs/lecture3.txt" Math      "Calculus"
./scripts/summarise ollama  ~/Downloads/chapter3.md    History   "Cold War"
```

> **Summarising PDFs with Claude or Ollama** requires `pdftotext`. Install it with:
> ```bash
> brew install poppler
> ```
> Gemini reads PDFs natively and does not need this.

Output → `AI Outputs/Notes/<subject>/YYYY-MM-DD <topic> — summary.md`

---

### Supported models

| What to type | Model used |
|---|---|
| `claude` | Claude Code (requires `claude` CLI) |
| `gemini` | Google Gemini CLI (requires `gemini` CLI) |
| `ollama` | Ollama with llama3.2 (default) |
| `ollama/mistral` | Ollama with mistral |
| `ollama/<any-name>` | Any model you have pulled via `ollama pull <name>` |

---

## Keeping cortexOS Updated

### If you cloned cortexOS directly as your vault

```bash
cd ~/cortexOS
git pull origin main
```

This updates scripts, templates, and config. Your notes are unaffected (they're gitignored or in `Notes/`).

---

### If you have a separate personal vault and want to pull script updates

```bash
# One-time: add cortexOS as an upstream remote
cd ~/my-vault
git remote add upstream https://github.com/AyanaayaW/cortexOS.git

# Pull script updates without touching your notes
git fetch upstream
git checkout upstream/main -- scripts/
git checkout upstream/main -- Templates/
git commit -m "chore: sync scripts from cortexOS upstream"
```

---

## Note Frontmatter Format

Every note generated by cortexOS starts with this YAML block. Dataview uses it for queries.

```yaml
---
title: "Newton's Laws"
subject: "Physics"
type: concept-note
date: 2026-04-18
tags: [physics, newtons-laws]
source: claude
reviewed: false
---
```

| Field | Values | Notes |
|---|---|---|
| `type` | `concept-note` `worksheet` `ai-output` `explanation` | Drives Dataview grouping |
| `source` | `manual` `claude` `gemini` `ollama` | Set automatically by scripts |
| `reviewed` | `true` / `false` | Change to `true` after verifying AI content |

> **Always verify AI-generated notes** against your textbook or syllabus before using them for revision. The `reviewed: false` flag is a reminder. The Dashboard shows all unreviewed notes in one Dataview table.

---

## Troubleshooting

### QuickAdd macros don't appear in the command palette

Close Obsidian completely and reopen it. QuickAdd reads `data.json` on startup.

If they still don't appear: **Settings → QuickAdd** — if the choices list is empty, the plugin may have reset its data. Re-add them manually: for each macro, click **Add Choice → Macro**, click **Manage Macros**, add a user script pointing to the `.js` file in `scripts/`.

---

### Commander toolbar buttons show "Command not found"

This happens if QuickAdd hasn't registered its commands yet. Fix: close and reopen Obsidian, then go to **Settings → Commander** and re-add the buttons.

---

### `./scripts/note: Permission denied`

Run this in Terminal:

```bash
chmod +x ~/cortexOS/scripts/note ~/cortexOS/scripts/explain \
          ~/cortexOS/scripts/worksheet ~/cortexOS/scripts/summarise
```

---

### Gemini returns "Unknown argument: file"

You're using the Google Gemini agentic CLI (v0.34+). The scripts use `--include-directories` and `-p` flags which are correct for this version. If you still get errors:

```bash
gemini --version   # should be 0.34.0 or higher
```

Update if needed:

```bash
npm update -g @google/gemini-cli
```

---

### Ollama returns an empty response

Check that Ollama is running and the model is pulled:

```bash
ollama serve         # start Ollama if it's not running
ollama pull llama3.2 # pull the default model
ollama list          # confirm it's in the list
```

---

### PDF summarising fails (non-Gemini models)

Claude and Ollama can't read PDFs directly. Install `pdftotext`:

```bash
brew install poppler
```

Then retry. Alternatively, use Gemini for PDFs — it reads them natively without any extra tools.

---

### Obsidian Git isn't pushing

1. Make sure you set up the GitHub remote: `git remote -v` should show `origin`
2. Check **Settings → Obsidian Git** — confirm auto-push is enabled
3. Run a manual backup: open the Obsidian command palette (`Cmd+P`) → type `Obsidian Git: Create backup` → press Enter

---

## Contributing

PRs are welcome. If you adapt cortexOS for a new study system (university modules, professional exams, language learning, etc.) and want to share your `CLAUDE.md` or script modifications, open a pull request or issue.

---

## License

MIT — use it, fork it, adapt it for any study system.

---

<div align="center">
Built with Claude Code · Obsidian · Gemini CLI · Ollama
</div>
