# studyOS Setup Guide

Complete these steps after cloning the repo or downloading the template.

---

## 1. Clone or Download

```bash
git clone https://github.com/AyanaayaW/studyOS-template.git ~/studyOS
cd ~/studyOS
```

Or download the ZIP from the [Releases page](https://github.com/AyanaayaW/studyOS-template/releases) and unzip to your preferred location.

---

## 2. Add Your Subjects

Edit the `Notes/`, `Worksheets/`, and `AI Outputs/Notes/` directories to match your courses:

```bash
SUBJECTS=("Math" "Physics" "Chemistry" "History" "English")

for s in "${SUBJECTS[@]}"; do
  mkdir -p ~/studyOS/Notes/"$s"
  mkdir -p ~/studyOS/Worksheets/"$s"
  mkdir -p ~/studyOS/"AI Outputs"/Notes/"$s"
done
```

Then **edit `CLAUDE.md`** — update the subjects table so Claude Code knows your courses.

---

## 3. Open in Obsidian

1. Launch **Obsidian**
2. Click **Open folder as vault**
3. Navigate to your `studyOS` folder and click **Open**

---

## 4. Install Community Plugins

**Settings → Community plugins → Turn on community plugins → Browse**

| Plugin | Author | Purpose |
|--------|--------|---------|
| **Obsidian Git** | Vinzent Steinberg | Auto-commit & push every 5 min |
| **Templater** | SilentVoid13 | Dynamic templates with prompts |
| **Dataview** | Michael Brenan | Query notes as a database |
| **QuickAdd** | Christian B. B. Houmann | Fast note creation macros |
| **Commander** | Johnny Nguyen | Add commands to toolbar |

---

## 5. Configure Templater

1. **Settings → Templater**
2. Set **Template folder location** → `Templates`
3. Enable **Trigger Templater on new file creation**

---

## 6. Connect to GitHub

```bash
cd ~/studyOS
git init && git branch -M main
gh repo create studyOS --private --source=. --remote=origin --push
```

Obsidian Git will auto-commit and push every 5 minutes from here on.

---

## 7. Verify AI Tools

```bash
claude --version        # Claude Code
gemini --version        # Gemini CLI
ollama list             # Ollama (lists pulled models)
jq --version            # jq (JSON parser)
```

If anything is missing:

| Tool | Install command |
|------|----------------|
| Claude Code | https://claude.ai/code |
| Gemini CLI | `npm install -g @google/gemini-cli` |
| Ollama | https://ollama.com → then `ollama pull llama3.2` |
| jq | `brew install jq` |

---

## 8. End-to-End Test

```bash
cd ~/studyOS
./scripts/claude-note.sh Physics "Newton's Laws" concept-note
```

Expected output: a new `.md` file in `AI Outputs/Notes/Physics/` with today's date.

---

## Script Usage

| Script | Command | Output |
|--------|---------|--------|
| `claude-note.sh` | `./scripts/claude-note.sh <subject> "<topic>" [type]` | `AI Outputs/Notes/<subject>/` |
| `gemini-summarise.sh` | `./scripts/gemini-summarise.sh <file> <subject> "<topic>"` | `AI Outputs/Notes/<subject>/` |
| `ollama-explain.sh` | `./scripts/ollama-explain.sh "<question>" [model]` | `AI Outputs/Explanations/` |
| `ai-worksheet.sh` | `./scripts/ai-worksheet.sh <subject> "<topic>" [n]` | `AI Outputs/Worksheets/` |
