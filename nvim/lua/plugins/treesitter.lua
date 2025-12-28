return {
	"nvim-treesitter/nvim-treesitter",
  lazy = false,
	build = ":TSUpdate",

	config = function()
    local configs = require("nvim-treesitter")
		configs.setup({
			auto_install = true,
			ensure_installed = {
				"c",
        "c_sharp",
				"lua",
				"html",
				"javascript",
				"typescript",
				"vim",
				"vimdoc",
				"query",
				"markdown",
				"markdown_inline",
				"hcl",
        "powershell"
			},
			sync_install = false,
			ignore_install = {},
			modules = {},
			highlight = {
				enable = true,
			},
			indent = {
				enable = true,
				disable = { "yaml" },
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
			},
		})
	end,
}
