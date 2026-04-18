#!/usr/bin/env bash
# claude-note.sh — Generate a study note using Claude
# Usage: ./scripts/claude-note.sh <subject> "<topic>" [type]
#
# type defaults to: concept-note
# Output: AI Outputs/Notes/<subject>/YYYY-MM-DD <topic> — <type>.md

set -euo pipefail

SUBJECT="${1:-}"
TOPIC="${2:-}"
TYPE="${3:-concept-note}"
DATE="$(date +%Y-%m-%d)"
VAULT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT_DIR="$VAULT_DIR/AI Outputs/Notes/$SUBJECT"

if [[ -z "$SUBJECT" || -z "$TOPIC" ]]; then
  echo "Usage: ./scripts/claude-note.sh <subject> \"<topic>\" [type]"
  echo "  type defaults to: concept-note"
  exit 1
fi

if ! command -v claude &>/dev/null; then
  echo "Error: 'claude' CLI not found."
  echo "Install Claude Code: https://claude.ai/code"
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

OUTPUT_FILE="$OUTPUT_DIR/$DATE $TOPIC — $TYPE.md"

SUBJECT_TAG="$(echo "$SUBJECT" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"
TOPIC_TAG="$(echo "$TOPIC"   | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"

PROMPT="You are an expert tutor. Generate a comprehensive study note for a student.

Subject: $SUBJECT
Topic: $TOPIC
Note type: $TYPE

Requirements:
- Begin with YAML frontmatter:
  ---
  title: \"$TOPIC\"
  subject: \"$SUBJECT\"
  type: $TYPE
  date: $DATE
  tags: [$SUBJECT_TAG, $TOPIC_TAG]
  source: claude
  reviewed: false
  ---
- Use LaTeX for ALL equations (inline: \$...\$, block: \$\$...\$\$)
- Mark every high-priority or examinable point with ⭐
- Use precise academic language and command terms relevant to this subject
- Sections: Overview, Key Concepts, Equations (if applicable), ⭐ Key Points, Common Mistakes, Practice Questions
- End with 3-5 exam-style questions with mark allocations [2 marks], [4 marks] etc.
- Be concise — no filler. Every sentence must add value.
- Prefer tables over long bullet lists."

echo "Generating note: $TOPIC ($SUBJECT) …"
claude --print "$PROMPT" > "$OUTPUT_FILE"

echo "✅ Saved to: $OUTPUT_FILE"
