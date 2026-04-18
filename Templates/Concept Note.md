---
title: <% tp.system.prompt("Note title / topic") %>
subject: <% tp.system.prompt("Subject") %>
type: concept-note
date: <% tp.date.now("YYYY-MM-DD") %>
tags: [<% tp.system.prompt("Subject tag (lowercase slug)") %>, <% tp.system.prompt("Topic tag (lowercase slug)") %>]
source: manual
reviewed: true
---

# <% tp.frontmatter.title %>

## Overview

> One-paragraph summary of the concept and why it matters.

---

## Key Concepts

| Concept | Definition |
|---------|-----------|
| | |
| | |

---

## Equations

$$
% Add equations here
$$

| Symbol | Meaning | Units |
|--------|---------|-------|
| | | |

---

## ⭐ Key Points

- ⭐ 
- ⭐ 

---

## Common Mistakes

- ❌ 
- ❌ 

---

## Practice Questions

1. **[2 marks]** 

2. **[4 marks]** 

3. **[6 marks]** 

---

*Last reviewed: <% tp.date.now("YYYY-MM-DD") %>*
