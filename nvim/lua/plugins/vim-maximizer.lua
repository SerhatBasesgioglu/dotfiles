return {
    "szw/vim-maximizer",
    init = function()
        vim.g.maximizer_set_default_mapping = 0
    end,
    config = function()
        vim.keymap.set("n", "<leader>sm", "<cmd>MaximizerToggle<CR>", { desc = "Maximizer/minimize a split" })
    end,
}
