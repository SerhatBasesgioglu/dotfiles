return {
	cmd = {
		"lua-language-server",
	},
	filetypes = { "lua" },
	root_markers = {
		".git",
		".luarc.json",
		".luarc.jsonc",
		".stylua.toml",
		"selene.toml",
		"selene.yml",
		"stylua.toml",
	},
	single_file_support = true,
	log_level = vim.lsp.protocol.MessageType.Warning,

	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library = {
					"$VIMRUNTIME",
					"deps/nvim-test",
					"${3rd}/busted/library",
					"${3rd}/luassert/library",
          vim.fn.stdpath("data") .. "/lazy/snacks.nvim/lua"
				},
			},
		},
	},
}
