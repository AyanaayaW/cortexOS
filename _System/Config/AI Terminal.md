---
type: config
---

# AI Terminal — CortexOS

CortexOS embeds a real terminal inside Obsidian using the **Terminal** plugin by polyipseity. No need to leave your vault.

## Opening the Terminal

| Platform       | Command                                   |
|----------------|-------------------------------------------|
| macOS / Linux  | `Cmd+P` → `Terminal: Open terminal`       |
| Windows        | `Ctrl+P` → `Terminal: Open terminal`      |

The terminal opens at the vault root (`~/CortexOS/` or `%USERPROFILE%\CortexOS\`) by default.

## Running AI from the Terminal

| AI         | Command                       | Notes                          |
|------------|-------------------------------|--------------------------------|
| Claude     | `claude`                      | Anthropic CLI                  |
| Gemini     | `gemini`                      | Google Gemini CLI              |
| Ollama     | `ollama run llama3.2`         | Local, free, offline           |

## Troubleshooting

- **Windows**: If `claude` or `gemini` are not recognized, restart PowerShell after installing them. Ensure they're on your system PATH.
- **macOS/Linux**: Ensure the CLI tool was installed globally (`npm install -g @anthropic-ai/claude-code` for Claude).
- **Ollama**: Must be running in the background (`ollama serve`) before you can chat.
