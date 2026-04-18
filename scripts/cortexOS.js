/**
 * cortexOS.js — Full launcher (action → model → subject/file → topic)
 * QuickAdd user script: Settings → QuickAdd → Manage Macros → User Script
 *
 * Shows every step: pick action, pick model, then action-specific prompts.
 * For direct action launchers (skip step 1) use the cortexOS-*.js scripts.
 */
"use strict";
const { exec } = require("child_process");

// ── Edit these to match your subjects ────────────────────────────────────────
const SUBJECTS = [
  "Subject 1", "Subject 2", "Subject 3", "Subject 4", "Subject 5",
];

const MODELS = [
  ["☁️  Claude",             "claude"         ],
  ["✨  Gemini",             "gemini"         ],
  ["🦙  Ollama · llama3.2",  "ollama"         ],
  ["🦙  Ollama · mistral",   "ollama/mistral" ],
];

const ACTIONS = [
  ["📝  Note",       "note"      ],
  ["💡  Explain",    "explain"   ],
  ["📋  Worksheet",  "worksheet" ],
  ["📄  Summarise",  "summarise" ],
];

const NOTE_TYPES = [
  ["Concept Note", "concept-note"],
  ["Summary",      "summary"     ],
  ["Essay Plan",   "essay-plan"  ],
  ["Revision",     "revision"    ],
];

const Q_COUNTS = [
  ["4 questions",  "4" ],
  ["6 questions",  "6" ],
  ["8 questions",  "8" ],
  ["10 questions", "10"],
];

// ── Helpers ───────────────────────────────────────────────────────────────────
const d = (arr) => arr.map((a) => a[0]);   // display labels
const v = (arr) => arr.map((a) => a[1]);   // values
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function run(cmd, vault, app) {
  new Notice(`⚙️  Running…`, 9000);
  exec(cmd, { shell: "/bin/zsh", cwd: vault }, async (err, stdout, stderr) => {
    if (err) {
      new Notice(`❌  ${(stderr || err.message).trim()}`, 15000);
      console.error("[cortexOS]", err);
      return;
    }
    const match = stdout.match(/Saved to:\s*(.+\.md)/);
    if (!match) { new Notice("✅  Done!", 4000); return; }
    const rel = match[1].trim().replace(vault + "/", "");
    new Notice(`✅  Saved → ${rel}`, 7000);
    await sleep(1500);
    const f = app.vault.getAbstractFileByPath(rel);
    if (f) app.workspace.openLinkText(rel, "", false);
  });
}

// ── Main ──────────────────────────────────────────────────────────────────────
module.exports = async ({ quickAddApi: { suggester, inputPrompt }, app }) => {
  const vault   = app.vault.adapter.basePath;
  const scripts = `${vault}/scripts`;

  // Step 1 — Action
  const action = await suggester(d(ACTIONS), v(ACTIONS));
  if (!action) return;

  // Step 2 — Model
  const model = await suggester(d(MODELS), v(MODELS));
  if (!model) return;

  let cmd;

  if (action === "note") {
    const subject  = await suggester(SUBJECTS, SUBJECTS);
    if (!subject) return;
    const topic    = await inputPrompt("Topic?", "e.g. Newton's Laws");
    if (!topic) return;
    const noteType = await suggester(d(NOTE_TYPES), v(NOTE_TYPES));
    if (!noteType) return;
    cmd = `"${scripts}/note" ${model} "${subject}" "${topic}" ${noteType}`;
  }

  else if (action === "explain") {
    const kind = await suggester(
      ["❓ Type a question", "📁 Pick a file from vault"],
      ["question", "file"]
    );
    if (!kind) return;
    if (kind === "question") {
      const q       = await inputPrompt("What do you want explained?");
      if (!q) return;
      const subject = await suggester(["General", ...SUBJECTS], ["General", ...SUBJECTS]);
      cmd = `"${scripts}/explain" ${model} "${q.replace(/"/g, '\\"')}" "${subject}"`;
    } else {
      const files = app.vault.getFiles().map((f) => f.path);
      const file  = await suggester(files, files);
      if (!file) return;
      const subject = await suggester(["General", ...SUBJECTS], ["General", ...SUBJECTS]);
      cmd = `"${scripts}/explain" ${model} "${vault}/${file}" "${subject}"`;
    }
  }

  else if (action === "worksheet") {
    const subject = await suggester(SUBJECTS, SUBJECTS);
    if (!subject) return;
    const topic   = await inputPrompt("Topic?", "e.g. Integration by Parts");
    if (!topic) return;
    const numQ    = await suggester(d(Q_COUNTS), v(Q_COUNTS));
    if (!numQ) return;
    cmd = `"${scripts}/worksheet" ${model} "${subject}" "${topic}" ${numQ}`;
  }

  else if (action === "summarise") {
    const files = app.vault.getFiles()
      .filter((f) => ["pdf", "txt", "md"].includes(f.extension))
      .map((f) => f.path);
    const file    = await suggester(files, files);
    if (!file) return;
    const subject = await suggester(SUBJECTS, SUBJECTS);
    if (!subject) return;
    const topic   = await inputPrompt("Topic label?", "e.g. Organic Chemistry");
    if (!topic) return;
    cmd = `"${scripts}/summarise" ${model} "${vault}/${file}" "${subject}" "${topic}"`;
  }

  await run(cmd, vault, app);
};
