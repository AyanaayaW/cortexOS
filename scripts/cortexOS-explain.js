/**
 * cortexOS-explain.js — Explain launcher (action pre-set, starts at model)
 * Assign to a QuickAdd macro called "cortexOS: Explain"
 * Then add a Commander toolbar button → QuickAdd: cortexOS: Explain
 */
"use strict";
const { exec } = require("child_process");

const SUBJECTS = ["General", "Subject 1", "Subject 2", "Subject 3", "Subject 4", "Subject 5"];
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

  const model = await suggester(d(MODELS), v(MODELS));
  if (!model) return;

  // Ask whether it's a typed question or a file from the vault
  const kind = await suggester(
    ["❓ Type a question", "📁 Pick a file from vault"],
    ["question", "file"]
  );
  if (!kind) return;

  let cmd;

  if (kind === "question") {
    const q       = await inputPrompt("What do you want explained?");
    if (!q) return;
    const subject = await suggester(SUBJECTS, SUBJECTS);
    if (!subject) return;
    cmd = `"${scripts}/explain" ${model} "${q.replace(/"/g, '\\"')}" "${subject}"`;
  } else {
    const files = app.vault.getFiles().map((f) => f.path);
    const file  = await suggester(files, files);
    if (!file) return;
    const subject = await suggester(SUBJECTS, SUBJECTS);
    if (!subject) return;
    cmd = `"${scripts}/explain" ${model} "${vault}/${file}" "${subject}"`;
  }

  new Notice(`💡  Explain · ${model}  —  running…`, 9000);

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
