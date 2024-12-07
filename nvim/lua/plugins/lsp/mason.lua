return {
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = {
            "WhoIsSethDaniel/mason-tool-installer.nvim",
            "williamboman/mason.nvim",
        },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    -- LSPs
                    "lua_ls",
                    "html",
                    "cssls",
                    "tailwindcss",
                    "pyright",
                    "jdtls",
                    "ts_ls",
                },
            })
        end,
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        config = function()
            require("mason-tool-installer").setup({
                ensure_installed = {
                    -- Formatters
                    "prettier",
                    "stylua",
                    "isort",
                    "black",
                    -- Linters
                    "pylint",
                    "eslint_d",
                    "htmlhint",
                    --"selene",
                },
            })
        end,
    },
}
