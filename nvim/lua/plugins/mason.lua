return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup({
				registries = {
					"github:mason-org/mason-registry",
					"github:Crashdummyy/mason-registry",
				},
			})
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"pyright",
					"bashls",
					"ts_ls",
					"angularls",
				},
			})
		end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
		},
		config = function()
				require("mason-tool-installer").setup({
					ensure_installed = {
						-- LSP servers
						"lua_ls",
						"pyright",
						"bashls",
						"ts_ls",
						"angularls",
						"netcoredbg",
						"debugpy",

					-- Formatters
					"prettier",
					"stylua",
					"ruff",
					"mypy",
					-- Linters
					"eslint_d",
					"selene",
				},
				run_on_start = true,
			})
		end,
	},
}
