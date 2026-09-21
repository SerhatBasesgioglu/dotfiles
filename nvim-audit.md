# Neovim Audit

Open issues found during the initial dotfiles review. This is a backlog for later cleanup.

## High Priority

### Treesitter setup likely wrong
- File: `nvim/lua/plugins/treesitter.lua`
- The config calls `require("nvim-treesitter").setup(...)`.
- Treesitter config is normally done through `require("nvim-treesitter.configs").setup(...)`.
- Likely result: plugin config error or setup not applying correctly.

### Active LSP mappings depend on Telescope, but Telescope is archived
- File: `nvim/lua/plugins/lsp.lua`
- Mappings like `gd`, `gR`, `gi`, `gt`, and `<leader>D` call `:Telescope ...`.
- Telescope is only configured in `nvim/lua/plugins/archive/telescope.lua`.
- `lazy.nvim` imports from `nvim/lua/plugins/`, so the archived Telescope spec is inactive.
- Likely result: those mappings fail at runtime because `:Telescope` is unavailable.

### Enabled LSP servers are out of sync with `nvim/lsp/`
- File: `nvim/lua/config/lsp.lua`
- Enabled servers include `angular`, `bashls`, `ts_ls`, and `angular_ls`.
- Current `nvim/lsp/` directory only contains `lua_ls.lua`, `pyright.lua`, and `powershell.lua`.
- `nvim/lsp/angular.lua` is deleted in the current worktree.
- Likely result: stale config and broken or confusing LSP startup behavior.

## Medium Priority

### Hard-coded machine-specific paths
- Files:
- `nvim/lsp/pyright.lua`
- `nvim/lsp/powershell.lua`
- `nvim/lua/plugins/debugger.lua`
- These use absolute `/home/serhat/...` paths for project Python, Mason packages, and debugger binaries.
- Likely result: config breaks after moving machines, changing project paths, or reinstalling tools.

### Snacks keymap typo and duplicate mappings
- File: `nvim/lua/plugins/snacks.lua`
- `"<lea'er>sH"` is a typo, so that mapping will never work.
- The file also defines duplicates such as `<leader>n` and `<leader>sb`.
- Likely result: dead mapping plus harder-to-track key behavior.

### Bufferline spec appears malformed
- File: `nvim/lua/plugins/bufferline.lua`
- `version` and `opts` are nested inside `dependencies` instead of at the plugin-spec level.
- `separator_style` is misspelled as `seperator_style`.
- Likely result: bufferline options are ignored.

### Fold config may conflict with `nvim-ufo`
- Files:
- `nvim/lua/config/options.lua`
- `nvim/lua/plugins/nvim-ufo.lua`
- Global `foldmethod = "syntax"` may fight with folding managed by `ufo`.
- Likely result: confusing fold behavior rather than a hard failure.

### Tool installation drift between Mason and formatter/linter config
- Files:
- `nvim/lua/plugins/mason.lua`
- `nvim/lua/plugins/formatter.lua`
- `nvim/lua/plugins/linter.lua`
- Mason ensures only `prettier`, `stylua`, `eslint_d`, and `selene`.
- Formatter/linter config also expects `black`, `shfmt`, `csharpier`, `htmlhint`, and `jsonlint`.
- Likely result: some formatters/linters silently fail unless installed another way.

## Low Priority

### LSP mappings are defined in two places
- Files:
- `nvim/lua/config/autocmds.lua`
- `nvim/lua/plugins/lsp.lua`
- Both register `LspAttach` callbacks and assign overlapping mappings.
- Likely result: redundant config and future maintenance drift.
