-- Line numbers
vim.opt.number = true

-- Relative line numbers
vim.opt.relativenumber = true

-- Enable mouse
vim.opt.mouse = "a"

-- Use system clipboard
vim.opt.clipboard = "unnamedplus"

-- Create new splits on right or below
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Make cursorline highlighted
vim.opt.cursorline = true

-- Make tabsize 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

-- Turn tabs into spaces
vim.opt.expandtab = true

-- Enable better color support
vim.opt.termguicolors = true

-- Make searches case insensitive
vim.opt.ignorecase = true

-- If search has upper case, make it case sensitive
vim.opt.smartcase = true

-- Make longer lines to overflow instead of wrapping to nextline
vim.opt.wrap = false

-- Enable persistent undo, can undo to older changes than file opening
vim.opt.undofile = true

-- Enable folding based on syntax, might need plugin for this.
vim.opt.foldmethod = "syntax"

-- Make all folds are open by default when opened a file (Number is arbitrary, bigger than fold level)
vim.opt.foldlevel = 99

-- Disables mode display at bottom
vim.opt.showmode = false

-- Disables swap files
vim.opt.swapfile = false

-- Keeps cursor in the middle of screen (10 means at least 10 lines away from the borders)
vim.opt.scrolloff = 999
