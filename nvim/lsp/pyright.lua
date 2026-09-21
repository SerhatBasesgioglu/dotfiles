return {
	cmd = {
		"pyright-langserver",
    "--stdio"
	},
	filetypes = { "python" },
	root_markers = {
		"pyproject.toml",
		"pyrightconfig.json",
		".git",
	},
	single_file_support = true,
	log_level = vim.lsp.protocol.MessageType.Warning,

	settings = {
		python = {},
	},
}
