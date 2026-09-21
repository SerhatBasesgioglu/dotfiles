# Neovim Audit

The configuration audit was addressed on 2026-09-21.

Resolved items include:

- malformed Bufferline options;
- Telescope mappings left active after Telescope was archived;
- duplicate and mistyped Snacks mappings;
- duplicate LSP attachment configuration;
- old auto-session option names;
- missing Mason declarations for configured development tools;
- machine-specific Python debugger adapter lookup.

Neovim now starts successfully in headless mode and reports no deprecated API usage. `:checkhealth` may still report unavailable external runtimes or optional tools until Mason and the operating-system dependencies finish installing.
