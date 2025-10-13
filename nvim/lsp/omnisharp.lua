return {
	cmd = {
		"OmniSharp",
	},
	filetypes = { "cs", "csproj" },
	root_markers = {
		".git",
		".sln",
		".csproj",
		"omnisharp.json",
	},

	single_file_support = true,
	log_level = vim.lsp.protocol.MessageType.Warning,
	settings = {
		omnisharp = {
			enable_import_completion = true,
		},
	},
}
