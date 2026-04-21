---
cssclass: dashboard
---

# 🧠 CortexOS

`$= dv.date('today').toFormat("cccc, LLLL d, yyyy")`

---

## Quick Actions

```button
name 📝 Daily Note
type command
action Templater: Create new note from template
color blue
```
```button
name ✅ Tasks
type link
action [[Tasks Dashboard]]
color blue
```
```button
name 🕸 Graph
type command
action Graph view: Open graph view
color blue
```
```button
name 🤖 AI Chat
type command
action Smart Connections: Open Chat
color blue
```
```button
name ➕ New Space
type command
action QuickAdd: CortexOS: New Space
color blue
```
```button
name 📥 Capture
type command
action QuickAdd: Run QuickAdd
color blue
```

---

## My Spaces

```dataview
LIST WITHOUT ID "[[" + file.name + "]]"
FROM "/"
WHERE file.folder != "" AND contains(file.folder, "/Notes") = false AND contains(file.folder, "/Worksheets") = false AND contains(file.folder, "/Assets") = false AND contains(file.folder, "/Sources") = false AND file.name = split(file.folder, "/")[0]
SORT file.name ASC
LIMIT 10
```

---

## Recent Notes

```dataview
TABLE file.mtime AS "Modified", file.folder AS "Space"
FROM "" AND -"_System" AND -"Productivity" AND -"Inbox"
WHERE file.name != "Dashboard"
SORT file.mtime DESC
LIMIT 8
```

---

## Pending Tasks

```dataview
TASK
FROM ""
WHERE !completed
SORT due ASC
LIMIT 10
```

---

## System

```button
name 🔍 Check for Updates
type command
action QuickAdd: CortexOS: Check for Updates
```
```button
name ⬆️ Update CortexOS
type command
action QuickAdd: CortexOS: Update
```
