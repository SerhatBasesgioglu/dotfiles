return {
  cmd = {
          'pwsh', -- Use pwsh (PowerShell 7+)
          '-NoLogo',
          '-NoProfile',
          '-NonInteractive',
          '-Command',
          '/home/serhat/.local/share/nvim/mason/packages/powershell-editor-services/PowerShellEditorServices/Start-EditorServices.ps1 -LogLevel Information',
          '-Stdio'
  },
	filetypes = { "ps1", "powershell" },
	root_markers = {
		".git",
	},
	single_file_support = true,
	log_level = vim.lsp.protocol.MessageType.Warning,

	settings = {
	},
}
