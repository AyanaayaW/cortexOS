module.exports = async (params) => {
    const { app } = params;
    const activeFile = app.workspace.getActiveFile();

    if (!activeFile) {
        new Notice("❌ No active file open.");
        return;
    }

    // Read frontmatter
    const metadata = app.metadataCache.getFileCache(activeFile);
    const frontmatter = metadata?.frontmatter;

    if (!frontmatter || !frontmatter.space || !frontmatter.topic) {
        new Notice("❌ This note is missing 'space' or 'topic' in frontmatter.");
        return;
    }

    const space = frontmatter.space;
    const topic = frontmatter.topic;

    // Read all files in <space>/Sources/
    let sourcesContent = "";
    const sourcesFolder = `${space}/Sources`;
    const allFiles = app.vault.getFiles();
    const sourceFiles = allFiles.filter(f => f.path.startsWith(sourcesFolder));

    for (const file of sourceFiles) {
        try {
            const content = await app.vault.read(file);
            sourcesContent += `\n--- Source: ${file.name} ---\n${content}\n`;
        } catch (e) {
            // Skip files that can't be read (e.g., binary)
        }
    }

    // Read AI model config
    let model = "claude-3-5-sonnet-20241022";
    try {
        const modelFile = app.vault.getAbstractFileByPath("_System/Config/ai-model.md");
        if (modelFile) {
            const modelContent = await app.vault.read(modelFile);
            model = modelContent.trim();
        }
    } catch (e) {
        // Use default model
    }

    // Build the prompt
    const sourcesContext = sourcesContent
        ? `\n\nReference material from Sources folder:\n${sourcesContent}`
        : "\n\nNo source material found. Generate based on general knowledge.";

    const prompt = `Generate a concise, information-dense note on: "${topic}" for the space "${space}".

Rules:
- Key Definitions: use EXACT wording from sources — never paraphrase definitions
- All formulas and equations in LaTeX ($$...$$)
- Every sentence must add information — no filler, no padding, no repetition
- Calibrate depth, terminology, and level to match the source material provided
- If sources suggest academic context, write at that academic level
- If sources suggest professional context, use industry terminology
- Sections to fill: Overview, Key Definitions, Key Concepts, Equations / Formulas, Explanation, Connections, Questions

${sourcesContext}

Return ONLY the markdown content for each section. Use ## headers matching the template sections. Do not include frontmatter or the title.`;

    // Send to Smart Connections chat or display for user
    // Since we can't directly call an API from Obsidian JS without an API key,
    // we'll write the prompt to a scratch file and open the AI chat
    const currentContent = await app.vault.read(activeFile);

    // Check if Smart Connections plugin is available
    const smartConnections = app.plugins.plugins["smart-connections"];

    if (smartConnections && smartConnections.chat) {
        try {
            // Use Smart Connections API to generate
            const response = await smartConnections.chat.complete(prompt);
            if (response) {
                // Parse and insert generated content into the appropriate sections
                const newContent = currentContent.replace(
                    /## Overview\n\n/,
                    `## Overview\n\n${response}\n\n`
                );
                await app.vault.modify(activeFile, newContent);
                new Notice("✅ Note generated with AI");
                return;
            }
        } catch (e) {
            // Fall through to alternative method
        }
    }

    // Alternative: write prompt to clipboard and open AI chat
    // Create a generation request file
    const genContent = `---\ntype: ai-request\ntopic: "${topic}"\nspace: "${space}"\nmodel: "${model}"\n---\n\n# AI Generation Request\n\nCopy the prompt below into AI Chat (brain icon in sidebar) or the embedded terminal.\n\n---\n\n${prompt}`;

    const genPath = `_System/Config/.ai-prompt-cache.md`;
    const genFile = app.vault.getAbstractFileByPath(genPath);
    if (genFile) {
        await app.vault.modify(genFile, genContent);
    } else {
        await app.vault.create(genPath, genContent);
    }

    // Try to open Smart Connections chat
    try {
        await app.commands.executeCommandById("smart-connections:open-chat");
    } catch (e) {
        // Chat may not be available
    }

    new Notice("✅ Note generated with AI — check AI Chat sidebar for context-aware generation");
};
