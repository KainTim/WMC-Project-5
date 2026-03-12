---
description: Instructions for documenting prompts and file changes in docs/prompt.md
applyTo: '**'
---

# Writing Prompts to docs/prompt.md

## Purpose
Document all AI prompts and track which files were modified as a result of each prompt.

## Structure Requirements

### Date Organization
- Use German date format: `DD.MM.YYYY` (e.g., `11.03.2026`)
- Create a level 2 heading (`##`) for each date
- Dates should be in chronological order
- If the current date doesn't exist, create a new subheading for it

### Prompt Entry Format
Each prompt entry should follow this structure:

1. **Prompt text**: Write the actual prompt as a bullet point while only fixing grammatical errors (`-`)
2. **Separator**: Add `<br><br>` after the prompt text
3. **File changes header**: Add the line `Folgende Dateien wurden in diesem Prompt verändert:`
4. **File list**: List all affected files as indented sub-bullets (4 spaces + `-`)
   - Include file paths relative to the project root
   - Add notes in parentheses if relevant (e.g., "neu erstellt", "keine Änderungen")

### Example Format
```markdown
## 11.03.2026

- [Prompt text here]<br><br>
Folgende Dateien wurden in diesem Prompt verändert:
    - path/to/file1.ts
    - path/to/file2.dart (neu erstellt)
    - path/to/file3.ts (keine Änderungen, bereits vorhanden)
```

## Guidelines

1. **Always** add new prompts under the correct date heading
2. **Always** include the affected files list, even if no files were changed
3. Use relative file paths from the project root
4. Be specific about what changed (created, modified, deleted)
5. Keep the prompt text concise but descriptive
6. Maintain chronological order within each date section

## File Location
All prompt documentation goes into: `docs/prompt.md`