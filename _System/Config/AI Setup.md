---
type: config
---

# AI Setup — CortexOS

CortexOS supports three AI backends. All are optional — use whichever you prefer.

## AI Chat (Smart Connections)

The **Smart Connections** plugin provides a native AI chat sidebar inside Obsidian.

### Opening AI Chat

- Click the **brain icon** in the left ribbon
- Or: `Cmd+P` → `Smart Connections: Open Chat` (Mac/Linux)
- Or: `Ctrl+P` → `Smart Connections: Open Chat` (Windows)

The chat is **context-aware** — it reads the current open note and can reference your Sources/ folder automatically.

### Switching Models

Go to **Settings → Smart Connections → Model** to switch between:

| Model   | Provider   | Cost     | Setup                              |
|---------|-----------|----------|------------------------------------|
| Claude  | Anthropic | Paid API | Requires Anthropic API key         |
| Gemini  | Google    | Free tier| Requires Google AI Studio API key  |
| Ollama  | Local     | Free     | Requires Ollama at localhost:11434 |

### Getting API Keys

- **Claude (Anthropic)**: [console.anthropic.com](https://console.anthropic.com/) → API Keys → Create Key
- **Gemini (Google)**: [aistudio.google.com](https://aistudio.google.com/) → Get API Key
- **Ollama (local)**: No key needed. Install Ollama, run `ollama pull llama3.2`, then `ollama serve`.

Paste your API key into Smart Connections settings. Keys are stored locally in your vault — never synced.

## AI Generation (QuickAdd Macros)

The buttons in your notes (✨ Generate, 📝 Practice Questions) trigger QuickAdd macros that prepare AI prompts using your note content and Sources/ folder.

## Embedded Terminal

For direct CLI access to Claude, Gemini, or Ollama, see [[AI Terminal]].
