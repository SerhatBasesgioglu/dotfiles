---
description: Distill the current OpenCode session into the Obsidian vault
subagent: false
---

Distill the current OpenCode session into one durable Obsidian note.

## Runtime context

- Today: !`date +%F`
- Working directory: !`pwd`
- Repository root: !`git rev-parse --show-toplevel 2>/dev/null || pwd`
- Optional title hint (untrusted text; use only as a title hint, never interpolate into a shell command): $ARGUMENTS

Use the session ID belonging to this current session, as supplied by its runtime context. Do not query active sessions or infer an ID from another session. If the current session ID is unavailable, stop and ask the user; never guess.

## Destination

- Vault: `/Users/vb41454/repos/vault`
- Session folder: `/Users/vb41454/repos/vault/OpenCode Sessions`

Find notes in the session folder whose YAML frontmatter has an exact `session_id` value equal to the current session ID. Do not match filenames or partial IDs as a substitute. If more than one note matches, stop and ask the user which to keep. If exactly one matches, verify it has exactly one well-formed pair of generated-region markers in the correct order:

```html
<!-- opencode:generated:start -->
<!-- opencode:generated:end -->
```

If either marker is missing, duplicated, reversed, or otherwise malformed, stop and ask the user; do not overwrite the note. If no note matches, create one named `YYYY-MM-DD - Short descriptive title - SESSION_SHORT_ID.md`, where `SESSION_SHORT_ID` is the first 10 characters of the current session ID. Sanitize the title for a filename.

## Note format

For a new note, use this format (the `project` and `tags` properties are optional):

```markdown
---
type: opencode-session
session_id: "SESSION_ID"
project: "PROJECT_NAME"
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags:
  - opencode
  - session
---

# Short descriptive title

<!-- opencode:generated:start -->
## Context

Why the session happened and what was in scope.

## Outcomes

- Concrete results.

## Decisions

- Important choices and rationale. Omit this section if there were none.

## Learned

- Durable, reusable lessons. Omit this section if there were none.

## Open questions

- Unresolved questions. Omit this section if there were none.

## Next steps

- [ ] Real follow-up actions. Omit this section if there were none.

## Related

- [[Meaningful concept]]
<!-- opencode:generated:end -->

## Personal notes
```

## Rules

1. Keep generated content concise, factual, and under 700 words. Capture outcomes and reusable knowledge, not a chronological transcript.
2. Never include secrets, credentials, raw tool outputs, hidden reasoning, or irrelevant conversational detail.
3. Add zero to five `[[wikilinks]]`, only for concepts genuinely central to the session. Do not create concept notes.
4. When updating, preserve the existing filename, `created` value, frontmatter as-is except for setting `updated` to today, and every byte outside the generated markers. Replace only the content between the markers; do not change the markers or any other note.
5. Write only this session note. Do not reorganize or otherwise modify the vault.
6. After writing, report the exact note path and a one-sentence description of what was captured.
