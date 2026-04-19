module.exports = async (params) => {
    const { app } = params;
    const activeFile = app.workspace.getActiveFile();

    if (!activeFile) {
        new Notice("❌ No active file open.");
        return;
    }

    // Prompt for topic
    const topic = await params.quickAddApi.inputPrompt("Topic for practice questions:");
    if (!topic) {
        new Notice("❌ No topic provided.");
        return;
    }

    // Read the current note as source content
    const noteContent = await app.vault.read(activeFile);

    // Determine the space from frontmatter or folder
    const metadata = app.metadataCache.getFileCache(activeFile);
    const frontmatter = metadata?.frontmatter;
    let space = frontmatter?.space || activeFile.path.split("/")[0];

    // Read Sources/ for calibration
    let sourcesContent = "";
    const sourcesFolder = `${space}/Sources`;
    const allFiles = app.vault.getFiles();
    const sourceFiles = allFiles.filter(f => f.path.startsWith(sourcesFolder));

    for (const file of sourceFiles) {
        try {
            const content = await app.vault.read(file);
            sourcesContent += `\n--- Source: ${file.name} ---\n${content}\n`;
        } catch (e) {
            // Skip binary files
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
        // Use default
    }

    const sourcesContext = sourcesContent
        ? `\nReference material:\n${sourcesContent}`
        : "";

    const prompt = `Generate 6 practice questions on "${topic}" based on this note content:

${noteContent}

${sourcesContext}

Rules:
- 2 Easy questions (2 marks each)
- 3 Medium questions (4-5 marks each)
- 1 Hard question (8 marks)
- Adapt question style to domain: exam-style for academics, scenario-based for professionals, concept-check for personal learning
- All math/formulas in LaTeX
- Calibrate difficulty to the level shown in source material
- Include a complete answer/mark scheme

Format each question under ### Q1 — Easy, ### Q2 — Easy, ### Q3 — Medium, etc.
Put ALL answers inside a folded callout: > [!summary]- Answers & Mark Scheme`;

    // Create the worksheet file
    const date = new Date().toISOString().split("T")[0];
    const fileName = `${date} ${topic} Practice.md`;
    const filePath = `${space}/Worksheets/${fileName}`;

    const worksheetContent = `---
space: "${space}"
topic: "${topic}"
type: practice
created: ${date}
source-note: "[[${activeFile.basename}]]"
---

# ${topic} — Practice Questions

> [!abstract] AI Action Bar
>
> \`\`\`button
> name 🔄 Regenerate questions
> type command
> action QuickAdd: CortexOS: Generate Worksheet
> \`\`\`
>
> \`\`\`button
> name 💬 Open AI Chat
> type command
> action smart-connections:open-chat
> \`\`\`

---

*AI prompt has been prepared. Open the AI Chat sidebar (brain icon) and paste:*

---

${prompt}

---

> [!summary]- Answers & Mark Scheme
>
> *Answers will appear here after AI generation.*
`;

    // Create the file
    try {
        // Ensure the Worksheets folder exists
        const worksheetsFolder = `${space}/Worksheets`;
        if (!app.vault.getAbstractFileByPath(worksheetsFolder)) {
            await app.vault.createFolder(worksheetsFolder);
        }
        const newFile = await app.vault.create(filePath, worksheetContent);
        // Open the new file
        await app.workspace.openLinkText(filePath, "", true);
        new Notice("✅ Practice questions created");
    } catch (e) {
        new Notice(`❌ Error creating worksheet: ${e.message}`);
    }
};
