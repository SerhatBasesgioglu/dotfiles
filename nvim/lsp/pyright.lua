return {
	cmd = {
		"pyright-langserver",
    "--stdio"
	},
	filetypes = { "python" },
	root_markers = {
		".git",
	},
	single_file_support = true,
	log_level = vim.lsp.protocol.MessageType.Warning,

	settings = {
    python = {
      pythonPath = "/home/serhat/repos/rag/env/bin/python"
    }
	},
}

