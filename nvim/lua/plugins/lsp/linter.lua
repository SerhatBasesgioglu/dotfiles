return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		lint.linters_by_ft = {
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			python = { "pylint" },
			html = { "htmlhint" },
			lua = { "selene" },
		}

		local lint_enabled = true
		local function toggle_linter_diagnostics()
			local ft = vim.bo.filetype
			local linters = lint.linters_by_ft[ft]

			if linters and #linters > 0 then
				for _, linter in ipairs(linters) do
					local namespace = lint.get_namespace(linter)

					if lint_enabled then
						vim.diagnostic.reset(namespace, 0)
					else
						lint.try_lint()
					end
				end
				lint_enabled = not lint_enabled
			end
		end

		vim.keymap.set("n", "<leader>ll", function()
			toggle_linter_diagnostics()
		end, { desc = "Toggle linter diagnostics" })
		vim.api.nvim_create_autocmd({ "InsertLeave", "BufWritePost", "TextChanged" }, {
			callback = function()
				if lint_enabled then
					lint.try_lint() -- Only run lint if diagnostics are toggled on
				end
			end,
		})
	end,
}
