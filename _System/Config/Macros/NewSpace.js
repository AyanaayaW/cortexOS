module.exports = async (params) => {
    const { app } = params;

    // Prompt for Space name
    const spaceName = await params.quickAddApi.inputPrompt(
        "Name your Space (e.g. Physics, Marketing Strategy, Guitar, Novel Writing):"
    );

    if (!spaceName || spaceName.trim() === "") {
        new Notice("❌ No Space name provided.");
        return;
    }

    const name = spaceName.trim();

    // Check if Space already exists
    if (app.vault.getAbstractFileByPath(name)) {
        new Notice(`❌ Space "${name}" already exists.`);
        return;
    }

    // Create folder structure
    try {
        await app.vault.createFolder(name);
        await app.vault.createFolder(`${name}/Notes`);
        await app.vault.createFolder(`${name}/Worksheets`);
        await app.vault.createFolder(`${name}/Assets`);
        await app.vault.createFolder(`${name}/Sources`);
    } catch (e) {
        new Notice(`❌ Error creating folders: ${e.message}`);
        return;
    }

    // Create Space index/dashboard file
    const indexContent = `---
type: space-index
space: "${name}"
created: ${new Date().toISOString().split("T")[0]}
---

# ${name}

> [!abstract] Actions
>
> \`\`\`button
> name + New Note
> type command
> action Templater: Create new note from template
> \`\`\`
>
> \`\`\`button
> name + New Practice
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

> [!note] Notes in ${name}
>
> \`\`\`dataview
> TABLE topic AS "Topic", created AS "Created"
> FROM "${name}/Notes"
> SORT created DESC
> \`\`\`

> [!example] Practice Sheets
>
> \`\`\`dataview
> TABLE topic AS "Topic", created AS "Created"
> FROM "${name}/Worksheets"
> SORT created DESC
> \`\`\`

> [!info] Sources
>
> \`\`\`dataview
> LIST
> FROM "${name}/Sources"
> SORT file.name ASC
> \`\`\`
`;

    try {
        await app.vault.create(`${name}/${name}.md`, indexContent);
        // Open the new Space index
        await app.workspace.openLinkText(`${name}/${name}.md`, "", true);
        new Notice(`✅ Space "${name}" created`);
    } catch (e) {
        new Notice(`❌ Error creating Space index: ${e.message}`);
    }
};
