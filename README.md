<div align="center">

# 🗂️ studyOS

**An AI-powered Obsidian vault scaffold for students.**
IB Diploma · A-Levels · University · Any structured study system.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0-green.svg)](https://github.com/AyanaayaW/studyOS-template/releases/tag/v1.0)
[![Obsidian](https://img.shields.io/badge/Obsidian-compatible-7C3AED)](https://obsidian.md)

</div>

---

## What is studyOS?

studyOS is a ready-to-use Obsidian vault template that wires together four AI tools into a single, consistent study workflow:

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
studyOS/
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
git clone https://github.com/AyanaayaW/studyOS-template.git ~/studyOS
cd ~/studyOS
```

### 2. Add your subjects

```bash
SUBJECTS=("Math" "Physics" "History" "English" "Economics")

for s in "${SUBJECTS[@]}"; do
  mkdir -p ~/studyOS/Notes/"$s"
  mkdir -p ~/studyOS/Worksheets/"$s"
  mkdir -p ~/studyOS/"AI Outputs"/Notes/"$s"
done
```

Then **edit `CLAUDE.md`** — update the subjects table so Claude knows your courses.

### 3. Open in Obsidian

**Open folder as vault** → select `~/studyOS`

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
cd ~/studyOS
git init && git branch -M main
gh repo create studyOS --private --source=. --remote=origin --push
```

---

## AI Scripts

### `claude-note.sh` — Generate a study note

```bash
./scripts/claude-note.sh <subject> "<topic>" [type]
# type defaults to: concept-note
```

```bash
./scripts/claude-note.sh Physics "Newton's Laws" concept-note
./scripts/claude-note.sh Math "Integration by Parts" concept-note
./scripts/claude-note.sh History "Causes of WWI" essay-plan
```

Output → `AI Outputs/Notes/<subject>/YYYY-MM-DD <topic> — <type>.md`

---

### `gemini-summarise.sh` — Summarise a PDF or text file

```bash
./scripts/gemini-summarise.sh <filepath> <subject> "<topic>"
```

```bash
./scripts/gemini-summarise.sh ~/Downloads/chapter3.pdf Chemistry "Organic Chemistry"
./scripts/gemini-summarise.sh ~/notes/lecture5.txt Economics "Supply and Demand"
```

Output → `AI Outputs/Notes/<subject>/YYYY-MM-DD <topic> — gemini-summary.md`

Uses `--include-directories` to pass files to the Gemini agentic CLI. Falls back to inline text embedding for plain-text files. Requires [Google Gemini CLI](https://github.com/google-gemini/gemini-cli): `npm install -g @google/gemini-cli`

---

### `ollama-explain.sh` — Quick offline explanation

```bash
./scripts/ollama-explain.sh "<question>" [model]
# model defaults to: llama3.2
```

```bash
./scripts/ollama-explain.sh "What is the difference between enthalpy and entropy?"
./scripts/ollama-explain.sh "Explain p-values in plain English" llama3.2
```

Output → `AI Outputs/Explanations/YYYY-MM-DD <question-slug>.md`

Requires [Ollama](https://ollama.com): `ollama pull llama3.2`

---

### `ai-worksheet.sh` — Generate a practice worksheet + full mark scheme

```bash
./scripts/ai-worksheet.sh <subject> "<topic>" [num-questions]
# num-questions defaults to: 6
```

```bash
./scripts/ai-worksheet.sh Math "Differentiation" 8
./scripts/ai-worksheet.sh Economics "Elasticity" 6
```

Output → `AI Outputs/Worksheets/YYYY-MM-DD <subject> — <topic> Worksheet.md`

---

## Prerequisites

| Tool | Install | Required for |
|------|---------|-------------|
| [Claude Code](https://claude.ai/code) | See docs | `claude-note.sh`, `ai-worksheet.sh` |
| [Gemini CLI](https://github.com/google-gemini/gemini-cli) | `npm install -g @google/gemini-cli` | `gemini-summarise.sh` |
| [Ollama](https://ollama.com) | Download from site | `ollama-explain.sh` |
| [jq](https://jqlang.github.io/jq/) | `brew install jq` | `ollama-explain.sh` |
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

PRs welcome. If you adapt studyOS for a new study system (university, professional exams, etc.) and want to share your configuration, open an issue or pull request.

---

## License

MIT — use it, fork it, adapt it.

---

<div align="center">
Built with Claude Code · Obsidian · Gemini CLI · Ollama
</div>
