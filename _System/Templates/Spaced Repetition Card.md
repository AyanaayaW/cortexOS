---
space: <% await tp.system.prompt("Space (folder name)") %>
type: flashcard
created: <% tp.date.now("YYYY-MM-DD") %>
tags: [spaced-repetition]
---

<% await tp.system.prompt("Question (front of card)") %>
?
<% await tp.system.prompt("Answer (back of card)") %>
