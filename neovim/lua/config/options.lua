-- leader
vim.g.mapleader = " "

-- linenumbers
vim.wo.number = true
vim.wo.relativenumber = true

-- clipboard for yank and paste
vim.opt.clipboard = "unnamedplus"

-- fuzzy search
vim.opt.path:append("**")
vim.opt.wildmenu = true
vim.opt.wildignorecase = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- spaces and tabs
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.smartindent = true

-- Backup / undo / swap
vim.opt.undofile = true
vim.opt.swapfile = false
vim.opt.backup = false

-- Scrolling
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.wrap = false
vim.opt.cursorline = false
vim.opt.cursorcolumn = false


