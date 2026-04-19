<div align="center">

# CortexOS

**AI-powered second brain for anyone who works with knowledge.**

Students, professionals, researchers, writers, developers, creatives — if you work with knowledge, CortexOS gives you a structured, AI-enhanced vault that grows with you. Built on Obsidian, powered by your choice of AI.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

</div>

---

## What is CortexOS?

CortexOS is a complete knowledge operating system built on [Obsidian](https://obsidian.md). It turns your vault into an intelligent workspace where AI helps you capture, organize, and generate knowledge — whether you're studying quantum physics, managing a product roadmap, learning guitar, or writing a novel.

It's not tied to any curriculum, industry, or domain. You define your **Spaces** (areas of knowledge), drop in your reference material, and CortexOS adapts to your level and terminology.

---

## Features

| Feature | Description |
|---------|-------------|
| **Spaces** | User-defined knowledge areas — academic subjects, work projects, creative pursuits, anything |
| **AI Chat** | Built-in chat sidebar via Smart Connections (Claude, Gemini, or Ollama) |
| **Smart Buttons** | One-click AI generation — notes, practice questions, model selection |
| **Sources Context** | Drop reference material in Sources/ — AI reads it to calibrate level, terminology, and depth |
| **Practice Generator** | Domain-adaptive practice questions with hidden answer schemes |
| **Graph View** | Color-coded knowledge graph — see how your notes connect |
| **Daily Notes** | Daily journal with task tracking and progress reflection |
| **Task Management** | Cross-vault task dashboard grouped by Space |
| **Spaced Repetition** | Flashcard system for long-term retention |
| **Embedded Terminal** | Full terminal inside Obsidian — run Claude, Gemini, or Ollama directly |
| **Auto Git Sync** | Auto-commit every 5 minutes, auto-push to GitHub |
| **Cross-Platform** | One-command install on macOS, Linux, and Windows |

---

## Platform Support

| Platform | Status | Installer |
|----------|--------|-----------|
| macOS    | ✅     | `bash install.sh` |
| Linux    | ✅     | `bash install.sh` |
| Windows  | ✅     | `install.bat` or `powershell -ExecutionPolicy Bypass -File install.ps1` |

---

## Installation

### macOS / Linux

```bash
git clone https://github.com/AyanaayaW/cortexOS.git ~/cortexOS-repo
cd ~/cortexOS-repo
bash install.sh
```

This clones the project repo and runs the installer, which sets up your personal vault at `~/CortexOS/`.

### Windows

```powershell
git clone https://github.com/AyanaayaW/cortexOS.git $HOME\cortexOS-repo
cd $HOME\cortexOS-repo
.\install.bat
```

Your personal vault is created at `%USERPROFILE%\CortexOS\`.

Or directly in PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

The installer will:
1. Check your dependencies (git, Obsidian)
2. Ask what you'll use CortexOS for (academic / professional / personal / mixed)
3. Help you set up AI tools (all optional)
4. Print the list of Obsidian plugins to install
5. Open your vault in Obsidian

---

## AI Setup

CortexOS supports three AI backends. All are optional — use whichever you prefer, or combine them.

### Claude (Anthropic)

| Platform | Install |
|----------|---------|
| macOS    | `npm install -g @anthropic-ai/claude-code` |
| Linux    | `npm install -g @anthropic-ai/claude-code` |
| Windows  | `npm install -g @anthropic-ai/claude-code` (requires Node.js) |

Requires an Anthropic API key for the chat sidebar. CLI works with your Claude account.

### Gemini (Google)

| Platform | Install |
|----------|---------|
| All      | See [Gemini CLI docs](https://ai.google.dev/gemini-api/docs/gemini-cli) |

Requires a Google AI Studio API key for the chat sidebar.

### Ollama (Free, Local, Offline)

| Platform | Install |
|----------|---------|
| macOS    | `brew install ollama` then `ollama pull llama3.2` |
| Linux    | `curl -fsSL https://ollama.com/install.sh \| sh` then `ollama pull llama3.2` |
| Windows  | `winget install --id Ollama.Ollama` then `ollama pull llama3.2` |

No API key needed. Runs entirely on your machine.

---

## Updating

### macOS / Linux

```bash
cd ~/CortexOS
bash update.sh
```

### Windows

```powershell
cd $HOME\CortexOS
powershell -File update.ps1
```

---

## Required Obsidian Plugins

Install these via **Settings → Community Plugins → Browse** inside Obsidian:

| Plugin | Author | Purpose |
|--------|--------|---------|
| Obsidian Git | Vinzent Steinberg | Auto GitHub sync |
| Templater | SilentVoid13 | Smart templates |
| Dataview | Michael Brenan | Live queries |
| QuickAdd | Christian B. B. Houmann | Macros + capture |
| Buttons | shabegom | In-note buttons |
| Commander | Johnny Nguyen | Ribbon shortcuts |
| Calendar | Liam Cain | Daily notes calendar |
| Tasks | Martin Schenk | Task management |
| Spaced Repetition | Stephen Mwangi | Flashcard review |
| Smart Connections | Brian Petro | AI chat sidebar |
| Obsidian Terminal | polyipseity | Embedded terminal |

---

## Vault Structure

```
~/CortexOS/
├── Dashboard.md                  ← main home screen
├── _System/
│   ├── Templates/                ← note, worksheet, flashcard templates
│   ├── Theme/
│   └── Config/
│       └── Macros/               ← QuickAdd JS macros
├── <Your Spaces>/                ← created at onboarding
│   ├── Notes/
│   ├── Worksheets/
│   ├── Assets/
│   └── Sources/                  ← drop reference material here
├── Productivity/
│   ├── Daily Notes/
│   ├── Tasks/
│   └── Calendar/
└── Inbox/                        ← quick capture
```

---

## How It Works

1. **Create a Space** — click "New Space" on the Dashboard. Name it anything: Physics, Marketing, Guitar, Novel.
2. **Add Sources** — drop PDFs, articles, docs into `<Space>/Sources/`. The AI reads these to understand your level.
3. **Create Notes** — use the Note template. Click "Generate with AI" to auto-fill from your sources.
4. **Practice** — click "Generate practice questions" to create domain-adaptive worksheets.
5. **Review** — use Spaced Repetition flashcards for long-term retention.
6. **Track** — Daily Notes and Tasks keep you on top of everything.

---

## Screenshots

> *Coming soon*

---

## License

[MIT](LICENSE) — use it however you want.
