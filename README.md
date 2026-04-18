<div align="center">

# 🗂️ cortexOS

**An AI-powered Obsidian vault scaffold for students.**
IB Diploma · A-Levels · University · Any structured study system.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0-green.svg)](https://github.com/AyanaayaW/cortexOS/releases/tag/v1.0)
[![Obsidian](https://img.shields.io/badge/Obsidian-compatible-7C3AED)](https://obsidian.md)

</div>

---

## What is cortexOS?

cortexOS is a ready-to-use Obsidian vault template that wires together four AI tools into a single, consistent study workflow:

- **A clean folder structure** organised by subject, content type, and source
- **4 AI shell scripts** — generate notes, summaries, explanations, and worksheets straight from the terminal
- **3 Templater templates** — concept notes, worksheets, and AI output notes with review checklists
- **Obsidian Git pre-configured** — auto-commit and push every 5 minutes
- **A `CLAUDE.md` context file** — so Claude Code instantly understands your vault in every session

Designed for students who want AI to handle the scaffolding (formatting, practice questions, summaries from PDFs) while they focus on actually learning.

---

## Who is this for?

| Use case | How to adapt |
|----------|-------------|
| **IB Diploma (DP1/DP2)** | Edit subjects in `CLAUDE.md`; scripts already use exam command terms |
| **A-Levels** | Rename subject folders; adjust script prompts for your specification |
| **University (STEM)** | Add course-code folders; adjust worksheet difficulty in `ai-worksheet.sh` |
| **Language learning** | Use `ollama-explain.sh` for offline grammar and vocabulary questions |
| **General self-study** | Works out of the box — just add your subjects |

---

## Folder Structure

```
cortexOS/
├── Notes/
│   └── <Subject>/           ← one folder per subject
├── Worksheets/
│   └── <Subject>/
├── AI Outputs/
│   ├── Notes/               ← output from claude-note.sh & gemini-summarise.sh
│   ├── Explanations/        ← output from ollama-explain.sh
│   └── Worksheets/          ← output from ai-worksheet.sh
├── Assets/
│   ├── PDFs/
│   ├── Images/
│   └── Formula Sheets/
├── Templates/
│   ├── Concept Note.md
│   ├── Worksheet.md
│   └── AI Output.md
├── scripts/
│   ├── claude-note.sh
│   ├── gemini-summarise.sh
│   ├── ollama-explain.sh
│   └── ai-worksheet.sh
├── .obsidian/
│   └── plugins/obsidian-git/
├── CLAUDE.md                ← persistent AI context (edit this first)
├── SETUP_README.md          ← step-by-step setup guide
└── .gitignore
```

---

## Quick Start

### 1. Clone

```bash
git clone https://github.com/AyanaayaW/cortexOS.git ~/cortexOS
cd ~/cortexOS
```

### 2. Add your subjects

```bash
SUBJECTS=("Math" "Physics" "History" "English" "Economics")

for s in "${SUBJECTS[@]}"; do
  mkdir -p ~/cortexOS/Notes/"$s"
  mkdir -p ~/cortexOS/Worksheets/"$s"
  mkdir -p ~/cortexOS/"AI Outputs"/Notes/"$s"
done
```

Then **edit `CLAUDE.md`** — update the subjects table so Claude knows your courses.

### 3. Open in Obsidian

**Open folder as vault** → select `~/cortexOS`

### 4. Install the 5 community plugins

| Plugin | Author |
|--------|--------|
| Obsidian Git | Vinzent Steinberg |
| Templater | SilentVoid13 |
| Dataview | Michael Brenan |
| QuickAdd | Christian B. B. Houmann |
| Commander | Johnny Nguyen |

Set Templater's template folder to `Templates/`.

### 5. Connect to GitHub

```bash
cd ~/cortexOS
git init && git branch -M main
gh repo create cortexOS --private --source=. --remote=origin --push
```

---

## AI Scripts

All four scripts share the same interface: **action first, model second.**

```
<action> <model> [args…]
```

Swap any model in or out — the action stays the same.

---

### `note` — Generate a study note

```bash
./scripts/note <model> <subject> "<topic>" [type]
```

```bash
./scripts/note claude  Physics "Newton's Laws"
./scripts/note gemini  Math    "Integration by Parts"
./scripts/note ollama  History "Causes of WWI" essay-plan
./scripts/note ollama/mistral Econ "Supply and Demand"
```

Output → `AI Outputs/Notes/<subject>/YYYY-MM-DD <topic> — <type>.md`

---

### `explain` — Get an explanation (question or file)

```bash
./scripts/explain <model> "<question-or-filepath>" [subject]
```

```bash
./scripts/explain claude  "What is the photoelectric effect?"
./scripts/explain gemini  "chapter5.pdf"  Physics
./scripts/explain ollama  "Explain entropy in simple terms"
./scripts/explain ollama/mistral "What is a p-value?" Stats
```

Detects automatically whether the second argument is a text question or a file path. For Gemini + files, uses `--include-directories` so Gemini reads the file natively.

Output → `AI Outputs/Explanations/YYYY-MM-DD <slug>.md`

---

### `worksheet` — Generate a practice worksheet + full mark scheme

```bash
./scripts/worksheet <model> <subject> "<topic>" [num-questions]
```

```bash
./scripts/worksheet claude  Math    "Differentiation" 8
./scripts/worksheet gemini  Physics "Electric Fields"
./scripts/worksheet ollama  Econ    "Elasticity" 5
```

Output → `AI Outputs/Worksheets/YYYY-MM-DD <subject> — <topic> Worksheet.md`

---

### `summarise` — Summarise a file into a structured note

```bash
./scripts/summarise <model> "<filepath>" <subject> "<topic>"
```

```bash
./scripts/summarise gemini  ~/Downloads/textbook.pdf  Chemistry "Equilibrium"
./scripts/summarise claude  lecture_notes.txt          Math      "Calculus"
./scripts/summarise ollama  chapter3.md                History   "Cold War"
```

For Gemini, uses `--include-directories` with a text-embed fallback. For PDFs with non-Gemini models, requires `pdftotext` (`brew install poppler`).

Output → `AI Outputs/Notes/<subject>/YYYY-MM-DD <topic> — summary.md`

---

## Prerequisites

| Tool | Install | Required for |
|------|---------|-------------|
| [Claude Code](https://claude.ai/code) | See docs | `note`, `worksheet`, `explain`, `summarise` |
| [Gemini CLI](https://github.com/google-gemini/gemini-cli) | `npm install -g @google/gemini-cli` | `note`, `worksheet`, `explain`, `summarise` |
| [Ollama](https://ollama.com) | Download from site | `note`, `worksheet`, `explain`, `summarise` |
| [jq](https://jqlang.github.io/jq/) | `brew install jq` | All Ollama routes |
| [Git](https://git-scm.com) | Pre-installed on macOS | Everything |
| [gh CLI](https://cli.github.com) | `brew install gh` | Initial GitHub setup |

Verify all at once:

```bash
claude --version && gemini --version && ollama list && jq --version
```

---

## Note Frontmatter

Every note uses this YAML header:

```yaml
---
title: "<topic>"
subject: "<subject>"
type: concept-note | worksheet | ai-output | explanation
date: YYYY-MM-DD
tags: [<subject-slug>, <topic-slug>]
source: manual | claude | gemini | ollama
reviewed: false
---
```

Set `reviewed: true` after verifying AI-generated content against your syllabus or a trusted source.

---

## Contributing

PRs welcome. If you adapt cortexOS for a new study system (university, professional exams, etc.) and want to share your configuration, open an issue or pull request.

---

## License

MIT — use it, fork it, adapt it.

---

<div align="center">
Built with Claude Code · Obsidian · Gemini CLI · Ollama
</div>
