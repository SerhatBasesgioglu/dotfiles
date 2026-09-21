local cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if cmp_ok then
  vim.lsp.config("*", {
    capabilities = cmp_nvim_lsp.default_capabilities(),
  })
end

vim.lsp.enable({
  "lua_ls",
  "pyright",
  "angularls",
  "roslyn",
  "bashls",
  "ts_ls",
})
--"sqlls",

vim.diagnostic.config({
  virtual_lines = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.HINT] = "󰠠 ",
      [vim.diagnostic.severity.INFO] = " ",
    },
  },
})
