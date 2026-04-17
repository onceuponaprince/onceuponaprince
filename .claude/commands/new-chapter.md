---
description: Bootstrap a new chapter directory with chapter.md and empty scenes folder
---

Create a new chapter for $ARGUMENTS.

1. Determine campaign, chapter number, chapter title from $ARGUMENTS
2. Create `/campaigns/<campaign>/chapters/<NN-slug>/scenes/` directory
3. Copy `templates/chapter-template.md` to `<NN-slug>/chapter.md`
4. Fill frontmatter: campaign, chapter, title, status: not-started
5. Draft the Arc and Thesis progress sections from campaign context
6. Present for edit, save on sign-off
7. Update the parent campaign.md's Chapters list with the new chapter

$ARGUMENTS
