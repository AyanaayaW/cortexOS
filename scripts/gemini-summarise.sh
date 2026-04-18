#!/usr/bin/env bash
# gemini-summarise.sh — Summarise a file (PDF/txt/md) using Gemini CLI
# Usage: ./scripts/gemini-summarise.sh <filepath> <subject> "<topic>"
#
# Compatible with the Google Gemini agentic CLI (geminicli.com).
# Uses --include-directories so Gemini can read the file natively.
# Falls back to embedding text content directly for plain-text files
# if the file is outside the vault or Gemini can't reach it.

set -euo pipefail

FILEPATH="${1:-}"
SUBJECT="${2:-}"
TOPIC="${3:-}"

if [[ -z "$FILEPATH" || -z "$SUBJECT" || -z "$TOPIC" ]]; then
  echo "Usage: ./scripts/gemini-summarise.sh <filepath> <subject> \"<topic>\""
  exit 1
fi

# Resolve to absolute path
FILEPATH="$(cd "$(dirname "$FILEPATH")" && pwd)/$(basename "$FILEPATH")"

if [[ ! -f "$FILEPATH" ]]; then
  echo "Error: File not found: $FILEPATH"
  echo "Provide an absolute or relative path to an existing PDF or text file."
  exit 1
fi

if ! command -v gemini &>/dev/null; then
  echo "Error: 'gemini' CLI not found."
  echo "Install it with:  npm install -g @google/gemini-cli"
  echo "Then authenticate: gemini (follow the login prompt)"
  exit 1
fi

DATE="$(date +%Y-%m-%d)"
VAULT="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT_DIR="$VAULT/AI Outputs/Notes/$SUBJECT"
mkdir -p "$OUTPUT_DIR"
OUTPUT_FILE="$OUTPUT_DIR/$DATE $TOPIC — gemini-summary.md"

FILE_DIR="$(dirname "$FILEPATH")"
FILE_NAME="$(basename "$FILEPATH")"
FILE_EXT="${FILEPATH##*.}"

SUBJECT_TAG="$(echo "$SUBJECT" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"
TOPIC_TAG="$(echo "$TOPIC"   | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"

# Build the instruction prompt
PROMPT="You are an expert tutor. Read the file '$FILE_NAME' and produce an IB study summary for a student.

Subject: $SUBJECT
Topic focus: $TOPIC

Output a single Markdown document with this exact structure:

---
title: \"$TOPIC — Summary\"
subject: \"$SUBJECT\"
type: ai-output
date: $DATE
tags: [ib, $SUBJECT_TAG, $TOPIC_TAG, gemini-summary]
source: gemini
reviewed: false
---

## Key Concepts
(Concise bullet list. LaTeX for all equations: inline \$...\$, block \$\$...\$\$)

## Important Equations
(Table: Equation | Meaning | When to use. LaTeX for every equation.)

## ⭐ Examinable Points
(Mark every point that appears in past papers or the official course syllabus with ⭐)

## Common Exam Traps
(Mistakes IB students commonly make — be specific)

## Practice Questions
(3 IB-style questions with command terms and mark allocations, e.g. [4 marks])

Rules: concise — no filler. Academic command terms throughout. LaTeX for ALL equations."

echo "Summarising '$FILE_NAME' for $SUBJECT — $TOPIC …"

# Strategy 1 (preferred): pass file via --include-directories so Gemini
# can read it natively (works for PDF and all text formats).
if gemini --include-directories "$FILE_DIR" -p "$PROMPT" > "$OUTPUT_FILE" 2>/dev/null; then
  echo "✅ Saved to: $OUTPUT_FILE"
  exit 0
fi

# Strategy 2 (fallback): embed plain-text content directly in the prompt.
# This works for .txt, .md, and any UTF-8 file but NOT for binary PDFs.
echo "Note: --include-directories failed; falling back to inline content…"

if [[ "$FILE_EXT" == "pdf" ]]; then
  if command -v pdftotext &>/dev/null; then
    FILE_CONTENT="$(pdftotext "$FILEPATH" -)"
  else
    echo "Error: Could not read PDF and 'pdftotext' is not installed."
    echo "Install it with: brew install poppler"
    echo "Then re-run this script."
    rm -f "$OUTPUT_FILE"
    exit 1
  fi
else
  FILE_CONTENT="$(cat "$FILEPATH")"
fi

INLINE_PROMPT="$PROMPT

--- BEGIN FILE CONTENT: $FILE_NAME ---
$FILE_CONTENT
--- END FILE CONTENT ---"

gemini -p "$INLINE_PROMPT" > "$OUTPUT_FILE"
echo "✅ Saved to: $OUTPUT_FILE"
