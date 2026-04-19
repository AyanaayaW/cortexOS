---
type: dashboard
---

# Tasks

> [!abstract] Actions
>
> ```button
> name + Add Task
> type command
> action QuickAdd: Run QuickAdd
> ```

---

> [!warning] All Incomplete Tasks (by Space)
>
> ```dataview
> TASK
> FROM ""
> WHERE !completed
> GROUP BY file.folder
> SORT file.folder ASC
> ```

---

> [!tip] Due This Week
>
> ```dataview
> TASK
> FROM ""
> WHERE !completed AND due >= date(today) AND due <= date(today) + dur(7 days)
> SORT due ASC
> ```

---

> [!note] Recently Completed
>
> ```dataview
> TASK
> FROM ""
> WHERE completed
> SORT completion DESC
> LIMIT 10
> ```
