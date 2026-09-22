---
description: Distill this session into the Obsidian vault
subagent: false
---

Distill the current OpenCode session into one durable Obsidian note.

## Runtime context

- Today: !`date +%F`
- Working directory: !`pwd`
- Repository root: !`git rev-parse --show-toplevel 2>/dev/null || pwd`
- Active OpenCode sessions: !`opencode api get /api/session/active 2>/dev/null || true`
- Optional title hint: $ARGUMENTS

## Destination

- Vault: `/home/serhat/repos/vault`
- Session folder: `/home/serhat/repos/vault/OpenCode Sessions`

Use the current session ID as the stable identity. Prefer the session ID exposed by your runtime context. If needed, infer it from the active-session data above. Do not select another session when multiple sessions are active and identity is uncertain; ask the user instead.

Search the session folder for existing frontmatter with the same `session_id`. Update that note if found. Otherwise create one named:

`YYYY-MM-DD - Short descriptive title - SESSION_SHORT_ID.md`

Sanitize the title for a filename. `SESSION_SHORT_ID` is the first 10 characters of the session ID.

Use this format:

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

Rules:

1. Keep the generated content concise and factual; aim for fewer than 700 words.
2. Capture outcomes and reusable knowledge, not a chronological transcript.
3. Never include secrets, credentials, raw tool output, hidden reasoning, or irrelevant conversational detail.
4. Add zero to five `[[wikilinks]]`, only for concepts genuinely central to the session.
5. Do not create concept notes yet. Dangling links are acceptable in this first version.
6. On update, replace only the generated region and frontmatter `updated` value. Preserve `created`, the filename, and everything outside the generated markers, especially personal notes.
7. Write only the session note. Do not reorganize or otherwise modify the vault.
8. After writing, report the exact note path and a one-sentence description of what was captured.
