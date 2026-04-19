# CortexOS — Persistent Claude Code Context

> Claude Code reads this file automatically in every session inside this vault.

---

## What Is CortexOS

CortexOS is an AI-powered second brain and knowledge operating system built on Obsidian. It works for anyone — students, professionals, researchers, writers, developers, creatives. It is not tied to any curriculum, industry, or domain.

---

## Vault Layout

| Path | Purpose |
|------|---------|
| `Dashboard.md` | Main home screen — navigation, tasks, recent notes |
| `_System/Templates/` | Templater templates (Note, Worksheet, Spaced Repetition Card) |
| `_System/Theme/` | Theme assets |
| `_System/Config/` | Configuration files, AI model selection |
| `_System/Config/Macros/` | QuickAdd JS macros (GenerateNote, GenerateWorksheet, SelectModel, NewSpace) |
| `<Space>/Notes/` | Core notes for a given Space |
| `<Space>/Worksheets/` | Practice questions / worksheets |
| `<Space>/Assets/` | Images, diagrams, media |
| `<Space>/Sources/` | Reference material — textbooks, PDFs, syllabi, documentation, articles |
| `Productivity/Daily Notes/` | Daily journal entries |
| `Productivity/Tasks/` | Task dashboard |
| `Productivity/Calendar/` | Calendar integration |
| `Inbox/` | Quick capture landing zone |

---

## The Space Model

A **Space** is any top-level folder representing an area of knowledge. Examples:
- Academic: Physics, Mathematics, History, Economics
- Professional: Marketing Strategy, Product Roadmap, Client Research
- Creative: Novel Writing, Music Theory, Photography
- Personal: Guitar Practice, Language Learning, Fitness

Every Space has four subfolders: `Notes/`, `Worksheets/`, `Assets/`, `Sources/`.

Spaces are created dynamically by the user via the `CortexOS: New Space` macro. There are no hardcoded subject names.

---

## Sources/ Folder — Critical Behavior

**Before generating any content, ALWAYS read the `<Space>/Sources/` folder first.**

The Sources/ folder contains the user's reference material for that Space. This calibrates:
- **Level** — undergraduate vs. graduate vs. professional vs. beginner
- **Terminology** — use the same terms as the source material
- **Depth** — match the complexity expected by the user's context
- **Domain** — academic, professional, creative, etc.

If Sources/ is empty, generate based on general knowledge but note that no source calibration was available.

---

## Note Format Specification

Every note follows this structure:
1. **Overview** — one paragraph summary
2. **Key Definitions** — exact wording from sources, NEVER paraphrased
3. **Key Concepts** — core ideas, frameworks, models
4. **Equations / Formulas** — all in LaTeX (`$$...$$` for block, `$...$` for inline)
5. **Explanation** — concise, every sentence adds information, no filler
6. **Connections** — `[[wikilinks]]` to related notes
7. **Questions** — open questions for further exploration

---

## Practice Questions Format

- 6 questions per worksheet: 2 easy, 3 medium, 1 hard
- Difficulty labels on each question with point/mark values
- Domain-adaptive style:
  - Academic → exam-style with mark schemes (Method/Answer/Reasoning marks)
  - Professional → scenario-based with depth ratings
  - Personal → concept-check with explanations
- All math/formulas in LaTeX
- Answers hidden in a folded callout: `> [!summary]- Answers & Mark Scheme`

---

## AI System Overview

All AI interaction happens inside Obsidian:

| Mechanism | Purpose |
|-----------|---------|
| **Smart Connections** | AI chat sidebar (Claude / Gemini / Ollama) — context-aware, reads open note |
| **QuickAdd Macros** | Generate Note, Generate Worksheet, Select Model, New Space — JS scripts in `_System/Config/Macros/` |
| **Embedded Terminal** | Full terminal inside Obsidian for CLI access to `claude`, `gemini`, `ollama` |

No shell scripts are used for AI workflows. Everything runs through Obsidian plugins.

---

## Style Rules

These rules apply to ALL generated content:

1. **No filler sentences** — every sentence must add information
2. **Definitions verbatim from source** — never paraphrase a definition
3. **All formulas in LaTeX** — no exceptions
4. **Concise and information-dense** — aim for maximum knowledge per word
5. **Domain-agnostic** — adapt tone and terminology to the user's Space and Sources
6. **Tables over long bullet lists** — when presenting structured information
7. **⭐ marks high-priority content** — examinable, critical, or frequently referenced
8. **Wikilinks for connections** — always use `[[Note Name]]` format

---

## Notes for Claude

- Generated files should have `reviewed: false` in frontmatter until verified by the user
- Read the Space's Sources/ folder before generating any content
- Match the difficulty and style of the source material
- When in doubt about level, aim slightly higher — it's easier to simplify than to add depth
