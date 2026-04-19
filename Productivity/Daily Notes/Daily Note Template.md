---
type: daily-note
created: <% tp.date.now("YYYY-MM-DD") %>
---

# <% tp.date.now("dddd, MMMM Do YYYY") %>

---

## Today's Focus

> What's the one thing that matters most today?

- 

---

## Tasks Due Today

```dataview
TASK
FROM ""
WHERE due = date(today) AND !completed
SORT file.folder ASC
```

---

## Notes Created Today

```dataview
TABLE file.folder AS "Space", topic AS "Topic"
FROM "" AND -"_System" AND -"Productivity"
WHERE file.cday = date(today)
SORT file.ctime DESC
```

---

## Wins

- 

---

## Reflections

> What worked? What didn't? What will you change tomorrow?



---

```button
name Open Graph View
type command
action Graph view: Open graph view
```
