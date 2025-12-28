vim.env.DOTNET_ROOT = "/opt/dotnet"
vim.env.DOTNET_ROOT_X64 = "/opt/dotnet"


require("config.options")
require("config.keymaps")
require("config.lazy")
require("config.lsp")
require("config.autocmds")

--require("notorious").setup()
