return {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter.configs").setup({
            auto_install = true,
            ensure_installed = {
                "c",
                "lua",
                "html",
                "javascript",
                "typescript",
                "vim",
                "vimdoc",
                "query",
                "markdown",
                "markdown_inline",
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
            autotag = {
                enable = true,
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
