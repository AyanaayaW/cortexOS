/**
 * cortexOS-summarise.js — Summarise launcher (action pre-set, starts at file pick)
 * Assign to a QuickAdd macro called "cortexOS: Summarise"
 * Then add a Commander toolbar button → QuickAdd: cortexOS: Summarise
 */
"use strict";
const { exec } = require("child_process");

const SUBJECTS = ["Subject 1", "Subject 2", "Subject 3", "Subject 4", "Subject 5"];
const MODELS   = [
  ["☁️  Claude",            "claude"        ],
  ["✨  Gemini",            "gemini"        ],
  ["🦙  Ollama · llama3.2", "ollama"        ],
  ["🦙  Ollama · mistral",  "ollama/mistral"],
];

const d     = (arr) => arr.map((a) => a[0]);
const v     = (arr) => arr.map((a) => a[1]);
const sleep = (ms)  => new Promise((r) => setTimeout(r, ms));

module.exports = async ({ quickAddApi: { suggester, inputPrompt }, app }) => {
  const vault   = app.vault.adapter.basePath;
  const scripts = `${vault}/scripts`;

  // Model first so user can bail early
  const model = await suggester(d(MODELS), v(MODELS));
  if (!model) return;

  // File picker — show PDFs first, then txt/md
  const allFiles = app.vault.getFiles()
    .filter((f) => ["pdf", "txt", "md"].includes(f.extension))
    .sort((a, b) => {
      const order = { pdf: 0, txt: 1, md: 2 };
      return (order[a.extension] ?? 9) - (order[b.extension] ?? 9);
    })
    .map((f) => f.path);

  const file = await suggester(allFiles, allFiles);
  if (!file) return;

  const subject = await suggester(SUBJECTS, SUBJECTS);
  if (!subject) return;

  const topic = await inputPrompt("Topic label for this summary?", "e.g. Organic Chemistry");
  if (!topic) return;

  const cmd = `"${scripts}/summarise" ${model} "${vault}/${file}" "${subject}" "${topic}"`;
  new Notice(`📄  Summarise · ${model}  —  running…`, 9000);

  exec(cmd, { shell: "/bin/zsh", cwd: vault }, async (err, stdout, stderr) => {
    if (err) { new Notice(`❌  ${(stderr || err.message).trim()}`, 15000); return; }
    const match = stdout.match(/Saved to:\s*(.+\.md)/);
    if (!match) { new Notice("✅  Done!", 4000); return; }
    const rel = match[1].trim().replace(vault + "/", "");
    new Notice(`✅  Saved → ${rel}`, 7000);
    await sleep(1500);
    const f = app.vault.getAbstractFileByPath(rel);
    if (f) app.workspace.openLinkText(rel, "", false);
  });
};
