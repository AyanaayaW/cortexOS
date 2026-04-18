#!/usr/bin/env bash
# ollama-explain.sh — Get an offline explanation from a local Ollama model
# Usage: ./scripts/ollama-explain.sh "<question>" [model]
#
# model defaults to: llama3.2
# Output: AI Outputs/Explanations/YYYY-MM-DD <question-slug>.md

set -euo pipefail

QUESTION="${1:-}"
MODEL="${2:-llama3.2}"
DATE="$(date +%Y-%m-%d)"
VAULT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT_DIR="$VAULT_DIR/AI Outputs/Explanations"

if [[ -z "$QUESTION" ]]; then
  echo "Usage: ./scripts/ollama-explain.sh \"<question>\" [model]"
  echo "  model defaults to: llama3.2"
  exit 1
fi

if ! command -v jq &>/dev/null; then
  echo "Error: 'jq' is not installed."
  echo "Install it with: brew install jq  (macOS) | apt install jq  (Linux)"
  exit 1
fi

if ! curl -sf http://localhost:11434/api/tags &>/dev/null; then
  echo "Error: Ollama is not running at localhost:11434."
  echo "Start it with: ollama serve"
  echo "Then re-run this script."
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

SLUG="$(echo "$QUESTION" | cut -c1-60 | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')"
OUTPUT_FILE="$OUTPUT_DIR/$DATE $SLUG.md"

PROMPT="You are an expert tutor. Answer the following question clearly and concisely for a student. Use LaTeX for all equations (inline: \$...\$, block: \$\$...\$\$). Mark any especially important points with ⭐.

Question: $QUESTION"

echo "Querying Ollama ($MODEL) …"

RESPONSE=$(curl -sf http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d "$(jq -n \
        --arg model "$MODEL" \
        --arg prompt "$PROMPT" \
        '{model: $model, prompt: $prompt, stream: false}')" \
  | jq -r '.response')

if [[ -z "$RESPONSE" ]]; then
  echo "Error: Empty response from Ollama. Is model '$MODEL' pulled?"
  echo "Pull it with: ollama pull $MODEL"
  exit 1
fi

TITLE="$(echo "$QUESTION" | cut -c1-80)"

cat > "$OUTPUT_FILE" << MDEOF
---
title: "$TITLE"
type: explanation
model: ollama/$MODEL
date: $DATE
tags: [ollama, explanation]
source: ollama
reviewed: false
---

> **Question:** $QUESTION

---

$RESPONSE
MDEOF

echo "✅ Saved to: $OUTPUT_FILE"
