/**
 * cortexOS-worksheet.js — Worksheet launcher (action pre-set, starts at model)
 * Assign to a QuickAdd macro called "cortexOS: Worksheet"
 * Then add a Commander toolbar button → QuickAdd: cortexOS: Worksheet
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
const Q_COUNTS = [
  ["4 questions",  "4" ],
  ["6 questions",  "6" ],
  ["8 questions",  "8" ],
  ["10 questions", "10"],
];

const d     = (arr) => arr.map((a) => a[0]);
const v     = (arr) => arr.map((a) => a[1]);
const sleep = (ms)  => new Promise((r) => setTimeout(r, ms));

module.exports = async ({ quickAddApi: { suggester, inputPrompt }, app }) => {
  const vault   = app.vault.adapter.basePath;
  const scripts = `${vault}/scripts`;

  const model   = await suggester(d(MODELS), v(MODELS));           if (!model)   return;
  const subject = await suggester(SUBJECTS, SUBJECTS);             if (!subject) return;
  const topic   = await inputPrompt("Topic?", "e.g. Integration by Parts"); if (!topic) return;
  const numQ    = await suggester(d(Q_COUNTS), v(Q_COUNTS));       if (!numQ)    return;

  const cmd = `"${scripts}/worksheet" ${model} "${subject}" "${topic}" ${numQ}`;
  new Notice(`📋  Worksheet · ${model} · ${subject}  —  running…`, 9000);

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
