---
cssclass: dashboard
---

# CortexOS

> **<% tp.date.now("dddd, MMMM Do YYYY") %>**

---

> [!abstract] Quick Actions
>
> ```button
> name Daily Note
> type command
> action Templater: Create new note from template
> ```
>
> ```button
> name Tasks
> type link
> action [[Tasks Dashboard]]
> ```
>
> ```button
> name Graph View
> type command
> action Graph view: Open graph view
> ```
>
> ```button
> name AI Chat
> type command
> action smart-connections:open-chat
> ```
>
> ```button
> name Open Terminal
> type command
> action terminal:open-terminal
> ```
>
> ```button
> name Calendar
> type command
> action calendar:open
> ```

---

> [!tip] Quick Capture
>
> ```button
> name + Quick Capture
> type command
> action QuickAdd: Run QuickAdd
> ```

> [!example] Add New Space
>
> ```button
> name + New Space
> type command
> action QuickAdd: CortexOS: New Space
> ```

---

> [!info] My Spaces
>
> ```dataview
> LIST
> FROM "/"
> WHERE file.folder = "" AND file.name != "Dashboard" AND file.name != "CLAUDE" AND file.name != "README" AND file.name != "LICENSE"
> SORT file.name ASC
> ```

---

> [!warning] Pending Tasks
>
> ```dataview
> TASK
> FROM ""
> WHERE !completed
> SORT due ASC
> LIMIT 15
> ```

---

> [!gear] System
>
> ```button
> name Check for Updates
> type command
> action QuickAdd: CortexOS: Check for Updates
> ```
>
> ```button
> name Update CortexOS
> type command
> action QuickAdd: CortexOS: Update
> ```

---

> [!note] Recently Modified
>
> ```dataview
> TABLE file.mtime AS "Last Modified", file.folder AS "Space"
> FROM "" AND -"_System" AND -"Productivity"
> SORT file.mtime DESC
> LIMIT 5
> ```
