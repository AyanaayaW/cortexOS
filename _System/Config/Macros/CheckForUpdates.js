module.exports = async (params) => {
    const { app } = params;

    new Notice("Checking for CortexOS updates...");

    try {
        // Use Obsidian's requestUrl to check the latest release from GitHub
        const response = await requestUrl({
            url: "https://api.github.com/repos/AyanaayaW/cortexOS/releases/latest",
            method: "GET",
            headers: { "Accept": "application/vnd.github.v3+json" }
        });

        const latestTag = response.json.tag_name;
        const latestDate = new Date(response.json.published_at).toLocaleDateString();
        const releaseUrl = response.json.html_url;

        // Read local version if it exists
        let localVersion = "unknown";
        try {
            const versionFile = app.vault.getAbstractFileByPath("_System/Config/version.md");
            if (versionFile) {
                localVersion = (await app.vault.read(versionFile)).trim();
            }
        } catch (e) {
            // No version file yet
        }

        if (localVersion === latestTag) {
            new Notice(`✅ CortexOS is up to date (${latestTag})`);
        } else {
            new Notice(`🔄 Update available: ${latestTag} (released ${latestDate})\nYou have: ${localVersion}\nRun the Update macro to install it.`, 10000);
        }
    } catch (e) {
        new Notice("❌ Could not check for updates — check your internet connection");
    }
};
