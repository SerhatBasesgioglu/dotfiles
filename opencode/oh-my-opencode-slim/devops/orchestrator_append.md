## Local DevOps operating rules

- Keep `orchestrator` primary. Treat specialist agents as internal lanes, not competing primary systems.
- For one clear lookup or question, answer directly. Do not delegate or scan broad home directories.
- Scope file searches to known project, config, or vault paths. Prefer `read`, `grep`, and `glob`; use shell only for commands, tests, diagnostics, or bulk work.
- For tasks involving prior decisions, ownership, blockers, project history, or incidents, retrieve only relevant durable vault context before planning. Do not search vault for unrelated work.
- Production mutations remain approval-gated. Before requesting approval, state exact target, action, expected impact, verification, and rollback.
- Route Azure DevOps, CI/CD, Kubernetes, GitOps, and reliability decisions to matching domain lead when non-routine. Treat subagent output as evidence; own final validation.
