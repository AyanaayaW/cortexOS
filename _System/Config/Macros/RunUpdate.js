module.exports = async (params) => {
    const { app } = params;

    new Notice("Updating CortexOS...", 5000);

    const vaultPath = app.vault.adapter.basePath;
    const pluginsDir = `${vaultPath}/.obsidian/plugins`;

    // --- Step 1: Git pull for vault updates ---
    try {
        const { exec } = require("child_process");
        const util = require("util");
        const execAsync = util.promisify(exec);

        await execAsync("git pull origin main", { cwd: vaultPath });
        new Notice("✅ Vault files updated");
    } catch (e) {
        new Notice("⚠ Git pull failed — check your connection. Continuing with plugin updates...");
    }

    // --- Step 2: Update all plugins from GitHub releases ---
    const plugins = [
        { repo: "denolehov/obsidian-git",                    id: "obsidian-git",               name: "Obsidian Git" },
        { repo: "SilentVoid13/Templater",                    id: "templater-obsidian",         name: "Templater" },
        { repo: "blacksmithgu/obsidian-dataview",            id: "dataview",                   name: "Dataview" },
        { repo: "chhoumann/quickadd",                        id: "quickadd",                   name: "QuickAdd" },
        { repo: "shabegom/buttons",                          id: "buttons",                    name: "Buttons" },
        { repo: "phibr0/obsidian-commander",                 id: "cmdr",                       name: "Commander" },
        { repo: "liamcain/obsidian-calendar-plugin",         id: "calendar",                   name: "Calendar" },
        { repo: "obsidian-tasks-group/obsidian-tasks",       id: "obsidian-tasks-plugin",       name: "Tasks" },
        { repo: "st3v3nmw/obsidian-spaced-repetition",       id: "obsidian-spaced-repetition",  name: "Spaced Repetition" },
        { repo: "brianpetro/obsidian-smart-connections",     id: "smart-connections",           name: "Smart Connections" },
        { repo: "polyipseity/obsidian-terminal",             id: "terminal",                   name: "Terminal" }
    ];

    let updated = 0;
    let failed = 0;

    for (const plugin of plugins) {
        try {
            // Get latest release info
            const releaseRes = await requestUrl({
                url: `https://api.github.com/repos/${plugin.repo}/releases/latest`,
                method: "GET",
                headers: { "Accept": "application/vnd.github.v3+json" }
            });

            const tag = releaseRes.json.tag_name;
            const baseUrl = `https://github.com/${plugin.repo}/releases/download/${tag}`;

            const pluginDir = `${pluginsDir}/${plugin.id}`;
            const fs = require("fs");
            if (!fs.existsSync(pluginDir)) {
                fs.mkdirSync(pluginDir, { recursive: true });
            }

            // Download main.js
            const mainRes = await requestUrl({ url: `${baseUrl}/main.js` });
            fs.writeFileSync(`${pluginDir}/main.js`, mainRes.text);

            // Download manifest.json
            const manifestRes = await requestUrl({ url: `${baseUrl}/manifest.json` });
            fs.writeFileSync(`${pluginDir}/manifest.json`, manifestRes.text);

            // Download styles.css (optional)
            try {
                const stylesRes = await requestUrl({ url: `${baseUrl}/styles.css` });
                fs.writeFileSync(`${pluginDir}/styles.css`, stylesRes.text);
            } catch (e) {
                // No styles.css — that's fine
            }

            updated++;
        } catch (e) {
            failed++;
        }
    }

    // --- Step 3: Save current version ---
    try {
        const releaseRes = await requestUrl({
            url: "https://api.github.com/repos/AyanaayaW/cortexOS/releases/latest",
            method: "GET",
            headers: { "Accept": "application/vnd.github.v3+json" }
        });

        const versionPath = "_System/Config/version.md";
        const versionFile = app.vault.getAbstractFileByPath(versionPath);
        if (versionFile) {
            await app.vault.modify(versionFile, releaseRes.json.tag_name);
        } else {
            await app.vault.create(versionPath, releaseRes.json.tag_name);
        }
    } catch (e) {
        // Non-critical
    }

    // --- Done ---
    const msg = `✅ CortexOS updated — ${updated} plugins updated` + (failed > 0 ? `, ${failed} failed` : "") + `\nRestart Obsidian to load new versions.`;
    new Notice(msg, 10000);
};
