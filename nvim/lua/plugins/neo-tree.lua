return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
    },
    config = function()
        vim.keymap.set(
            "n",
            "<leader>ee",
            ":Neotree toggle<CR>",
            { noremap = true, silent = true, desc = "Toggle NeoTree" }
        )
        vim.keymap.set(
            "n",
            "<leader>er",
            ":Neotree reveal<CR>",
            { noremap = true, silent = true, desc = "Reveal current NeoTree" }
        )
        vim.keymap.set(
            "n",
            "<leader>eb",
            ":Neotree toggle buffers<CR>",
            { noremap = true, silent = true, desc = "Toggle Buffers" }
        )
        vim.keymap.set(
            "n",
            "<leader>eg",
            ":Neotree toggle git_status<CR>",
            { noremap = true, silent = true, desc = "Toggle Git Status" }
        )
    end,
}
