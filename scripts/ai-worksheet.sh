#!/usr/bin/env bash
# ai-worksheet.sh — Generate a practice worksheet with mark scheme using Claude
# Usage: ./scripts/ai-worksheet.sh <subject> "<topic>" [num-questions]
#
# num-questions defaults to: 6
# Output: AI Outputs/Worksheets/YYYY-MM-DD <subject> — <topic> Worksheet.md

set -euo pipefail

SUBJECT="${1:-}"
TOPIC="${2:-}"
NUM_Q="${3:-6}"
DATE="$(date +%Y-%m-%d)"
VAULT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT_DIR="$VAULT_DIR/AI Outputs/Worksheets"

if [[ -z "$SUBJECT" || -z "$TOPIC" ]]; then
  echo "Usage: ./scripts/ai-worksheet.sh <subject> \"<topic>\" [num-questions]"
  echo "  num-questions defaults to: 6"
  exit 1
fi

if ! command -v claude &>/dev/null; then
  echo "Error: 'claude' CLI not found."
  echo "Install Claude Code: https://claude.ai/code"
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

OUTPUT_FILE="$OUTPUT_DIR/$DATE $SUBJECT — $TOPIC Worksheet.md"

SUBJECT_TAG="$(echo "$SUBJECT" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"
TOPIC_TAG="$(echo "$TOPIC"   | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"

PROMPT="You are an expert tutor and examiner. Create a rigorous practice worksheet for a student.

Subject: $SUBJECT
Topic: $TOPIC
Number of questions: $NUM_Q

Requirements:
- Begin with YAML frontmatter:
  ---
  title: \"$TOPIC Worksheet\"
  subject: \"$SUBJECT\"
  type: worksheet
  date: $DATE
  tags: [$SUBJECT_TAG, $TOPIC_TAG, worksheet]
  source: claude
  reviewed: false
  ---
- Difficulty spread across $NUM_Q questions:
  - First 2 questions: easy (knowledge/recall, 2-3 marks each)
  - Middle questions: medium (application/analysis, 4-6 marks each)
  - Final 1 question: hard (synthesis/evaluation, 8-10 marks)
- LaTeX for ALL equations (inline: \$...\$, block: \$\$...\$\$)
- Each question clearly numbered with mark allocation in brackets, e.g. [4 marks]
- After all questions, include a full Mark Scheme section:
  - Worked solutions for every question
  - Method marks (M), Answer marks (A), Reasoning marks (R) clearly labelled
  - Accept alternative valid methods where appropriate
- No filler. Precise, academic language throughout."

echo "Generating worksheet: $TOPIC ($SUBJECT, $NUM_Q questions) …"
claude --print "$PROMPT" > "$OUTPUT_FILE"

echo "✅ Saved to: $OUTPUT_FILE"
