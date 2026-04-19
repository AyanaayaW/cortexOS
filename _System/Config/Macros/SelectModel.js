module.exports = async (params) => {
    const { app } = params;

    const labels = [
        "Claude (claude-3-5-sonnet)",
        "Gemini (gemini-1.5-pro)",
        "Ollama — llama3.2 (local, free)"
    ];

    const values = [
        "claude-3-5-sonnet-20241022",
        "gemini-1.5-pro",
        "ollama:llama3.2"
    ];

    const selected = await params.quickAddApi.suggester(labels, values);

    if (!selected) {
        new Notice("❌ No model selected.");
        return;
    }

    // Save to config file
    const configPath = "_System/Config/ai-model.md";
    const configFile = app.vault.getAbstractFileByPath(configPath);

    if (configFile) {
        await app.vault.modify(configFile, selected);
    } else {
        await app.vault.create(configPath, selected);
    }

    // Find the display name
    const index = values.indexOf(selected);
    const displayName = labels[index] || selected;

    new Notice(`✅ AI model set to: ${displayName}`);
};
