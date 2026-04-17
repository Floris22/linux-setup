-- =========================
-- Plugin installs
-- =========================
vim.pack.add { 
    'https://github.com/dmtrKovalenko/fff.nvim',
    'https://github.com/nvim-treesitter/nvim-treesitter',
    'https://github.com/neovim/nvim-lspconfig',
    'https://github.com/stevearc/oil.nvim',
    'https://github.com/esmuellert/codediff.nvim.git',
    'https://github.com/MeanderingProgrammer/render-markdown.nvim',
    'https://github.com/goolord/alpha-nvim',
    'https://github.com/ellisonleao/gruvbox.nvim',
    'https://github.com/kdheepak/lazygit.nvim.git',
}

-- =========================
-- Basic config
-- =========================

-- Set leader
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.keymap.set({ 'n', 'x' }, '<Space>', '<Nop>', { silent = true })

-- Relative line numbers
vim.o.relativenumber = true
vim.o.number = true

-- Case insensitive searching
vim.o.ignorecase = true
vim.o.smartcase = true

-- Sync clipboards
vim.o.clipboard = 'unnamedplus'

-- Raise dialog if unsaved buffer
vim.o.confirm = true

-- Vim diagnostics
vim.diagnostic.config({
    virtual_text = { spacing = 2, prefix = "●" },
    underline = true,
    severity_sort = true,
    update_in_insert = false,
    float = { source = 'if_many' },
    jump = { float = true },
})

-- Show diagnostics
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = 'show diagnostics' } )

-- Highlight yanks
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function() vim.highlight.on_yank() end,
})

-- Linebreaks and tabs
vim.o.linebreak = true
vim.o.wrap = false
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.breakindent = true

-- Cursor line
vim.o.cursorline = false
vim.o.cursorcolumn = false

-- Scrolling
vim.o.scrolloff = 999
vim.o.sidescrolloff = 999
vim.o.smoothscroll = true

-- Completion
vim.o.completeopt='menu,menuone,fuzzy,noinsert'
vim.keymap.set('i', '<C-Space>', '<C-x><C-o>') 
vim.keymap.set('i', '<CR>', [[pumvisible() ? "\<C-y>" : "\<CR>"]], { expr = true })

-- Other
vim.o.termguicolors = true
vim.o.mouse = 'a'
vim.o.winborder = 'rounded'

-- =============================
-- Plugins
-- =============================

--- FFF (fuzzy finder

vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == 'fff.nvim' and (kind == 'install' or kind == 'update') then
      if not ev.data.active then
        vim.cmd.packadd('fff.nvim')
      end
      require('fff.download').download_or_build_binary()
    end
  end,
})

-- the plugin will automatically lazy load
vim.g.fff = {
  lazy_sync = true, -- start syncing only when the picker is open
  debug = {
    enabled = true,
    show_scores = true,
  },
}

-- file search
vim.keymap.set(
  'n',
  '<leader>f',
  function() require('fff').find_files() end,
  { desc = 'FFFind files' }
)

-- live grep
vim.keymap.set(
  'n',
  'g/',
  function() require('fff').live_grep({
    grep = { modes = { 'fuzzy', 'plain' } },
  }) end,
  { desc = 'FFFind files' }
)

--- Treesitter

-- only highlight with treesitter
vim.cmd('syntax off')

require('nvim-treesitter.config').setup{
    highlight = { enable = true },
    ensure_installed = { 'go', 'lua', 'vim' },
}

vim.api.nvim_create_autocmd('FileType', {
    callback = function() pcall(vim.treesitter.start) end,
})

--- LSP

vim.lsp.config("gopls", {
    cmd = { "gopls" },
    capabilities = caps,
	settings = {
		gopls = {
		    usePlaceholders = true,
			staticcheck = true,
            completeUnimported = true,
			analyses = {
				unusedparams = true,
				nilness = true,
				ST1000 = false, -- package doc warning
				ST1021 = false, -- comment should be in format warning
		    },
			gofumpt = true,
		},
    },
})

vim.lsp.enable({
    'ty',
    'ruff',
    'gopls',
})

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('my.lsp', { clear = true }),
    callback = function(args)
        vim.o.signcolumn = 'yes:1'
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

        if not client:supports_method('textDocument/willSaveWaitUntil') then
            vim.api.nvim_create_autocmd('BufWritePre', {
                group = vim.api.nvim_create_augroup('my.lsp.fmt', { clear = false }),
                buffer = args.buf,
                callback = function()
                    -- organize imports (only for gopls)
                    if client.name == "gopls" then
                        local params = vim.lsp.util.make_range_params()
                        params.context = { only = { "source.organizeImports" } }

                        local result = vim.lsp.buf_request_sync(
                            args.buf,
                            "textDocument/codeAction",
                            params,
                            1000
                        )

                        if result then
                            for _, res in pairs(result) do
                                for _, action in pairs(res.result or {}) do
                                    if action.edit then
                                        vim.lsp.util.apply_workspace_edit(
                                            action.edit,
                                            client.offset_encoding
                                        )
                                    end
                                    if type(action.command) == "table" then
                                        vim.lsp.buf.execute_command(action.command)
                                    end
                                end
                            end
                        end
                    end

                    -- format
                    if client:supports_method('textDocument/formatting') then
                        vim.lsp.buf.format({
                            bufnr = args.buf,
                            id = client.id,
                            timeout_ms = 1000,
                        })
                    end
                end,
            })
        end

        if client:supports_method('textDocument/completion') then
            vim.o.complete = 'o,.,w,b,u'
            vim.o.completeopt = 'menu,menuone,popup,noinsert'
            vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
        end
    end
})

vim.o.signcolumn = 'yes'
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Goto Definition" })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "References" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Line diagnostics" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set('n', 'gh', 'K', { remap = true, desc = 'Hover' })

--- Oil

require('oil').setup {
    keymaps = { ['`'] = 'actions.tcd' },
    columns = { 'size', 'mtime' },
    delete_to_trash = true,
    skip_confirm_for_simple_edits = true,
}

vim.keymap.set('n', '-', ':Oil<CR>', { silent = true })


--- Lazygit
vim.keymap.set('n', '<leader>g', '<cmd>LazyGit<cr>', { desc = 'Lazygit' })

--- Theme (gruvbox)

require('gruvbox').setup({
    italic = { strings = false },
    overrides = {
        ["@function.go"] = { fg = "NONE", bold = false },
        ["@function.builtin.go"] = { fg = "#c18656", bold = false },
        ["@function.call.go"] = { bold = false },
        ["@function.method.call.go"] = { bold = false },
        ["@function.method.go"] = { bold = false },
        ["@keyword.go"] = { fg = "#c67369", bold = false },
        ["@keyword.import.go"] = { fg = "#c67369", bold = false },
        ["@keyword.function.go"] = { fg = "#c67369", bold = false },
        ["@keyword.conditional.go"] = { fg = "#c67369", bold = false },
        ["@keyword.repeat.go"] = { fg = "#c67369", bold = false },
        ["@keyword.return.go"] = { fg = "#c67369", bold = false },
        ["@keyword.type.go"] = { fg = "#c67369", bold = false },
        ["@keyword.coroutine.go"] = { fg = "#c67369", bold = false },
        ["@punctuation.bracket.go"] = { fg = "NONE", bold = false },
        ["@punctuation.delimiter.go"] = { fg = "NONE", bold = false },
        ["@variable.parameter.go"] = { fg = "NONE", bold = false },
        ["@variable.member.go"] = { fg = "#8c9c96", bold = false },
        ["@number.go"] = { fg = "NONE", bold = false },
        ["@operator.go"] = { fg = "NONE", bold = false },
        ["@property.go"] = { fg = "NONE", bold = false },
        ["@string.escape.go"] = { fg = "NONE", bold = false },
        ["@string.go"] = { fg = "#77763b", bold = false },
        ["@type.go"] = { fg = "NONE", bold = false },
        ["@type.definition.go"] = { fg = "NONE", bold = false },
        ["@boolean.go"] = { fg = "#bf9aa4", bold = false },
        ["@constant.go"] = { fg = "#bf9aa4", bold = false },
        ["@type.builtin.go"] = { fg = "NONE", bold = false },
        ["@constant.builtin.go"] = { fg = "NONE", bold = false },
        ["@lsp.type.function.go"] = { bold = false },
        ["@lsp.type.method.go"] = { bold = false },
    },
})

vim.cmd.colorscheme('gruvbox')

-- sets the statusline color underneath
vim.cmd(":hi statusline guibg=#556b2f")

--- Alpha (dashboard)

local alpha = require('alpha')
local dashboard = require('alpha.themes.dashboard')
dashboard.section.header.val = vim.split(
[[
    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⡇⠀⠀⢠⣼⣿⣿⣇⠀⡁⢀⣼⣿⣿⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢧⠀⠀⠀⣿⣥⠀⠀⢸⣿⣿⣿⣿⣶⣵⣾⣿⣿⣿⣟⣿⣏⣔⠀⠀⠀⠀⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣷⡀⠀⣿⣾⢀⣆⣾⢿⣿⣿⣿⣿⣿⣯⣿⣿⣿⣿⣿⣼⣧⣠⣞⣠⣴⠞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⣿⣾⣿⣿⣿⣿⣿⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣵⣿⣿⡿⣿⡿⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⢀⣿⣶⣄⢠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠀⢀⡸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣾⣷⣶⣴⡃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢷⣿⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢿⣿⣿⣿⣿⣿⣿⣭⣿⣟⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠆⠀⣀⣨⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣎⣿⣿⣿⣿⣿⣿⣯⣿⣏⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡆⠀⣾⣿⣤⣯⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣀⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣤⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡾⢿⣿⣿⣿⣄⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣏⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠀⡍⣻⣿⣿⣿⡀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⢹⣿⣿⣿⣛⣾⡽⢟⣿⣿⣿⣧⣤⣤⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣟⣿⣯⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⢱⣴⣸⣿⣿⣿⣿⣎⡑⠾⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠁⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⢋⣤⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣾⣿⡇⣿⣟⢻⣿⣿⣻⣦⣌⠹⣿⣿⣿⣿⣿⣿⣿⣿⠃⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⣿⣿⣿⣿⣿⣿⣿⠟⣡⣾⣿⣸⣿⣿⢻⣿⣿⣿⣿⣿⣿⣿⣿⢨⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⢹⣿⣿⠿⣿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣎⣻⣿⣿⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⣿⢟⣵⣾⣿⣿⣿⣿⣿⢇⣿⣿⣿⣿⣿⣿⣿⡆⠈⣸⠿⠻⢿⣻⣿⣿⣿⣿⣿⣿⣧⡜⠛⡿⣄⣄⠈⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠁⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣾⣿⣿⣿⣿⣿⣿⠟⠁⠀⠀⠀⠀⠀⠙⢿⣿⣿⣿⣿⣿⢛⡇⠀⠀⠀⠀⠀⠀⠈⣵⣿⣿⣿⣿⣿⣿⣿⣿⣷⠿⣿⣿⣿⣿⣿⣿⠁⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠀⠀⠀⣴⠀⠀⠀⠈⡌⣿⣿⢿⣿⡟⡏⠁⠀⠀⠀⠀⠀⠀⠀⠈⠛⡿⣿⣿⣟⢻⠏⠈⣿⡆⠛⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠋⢠⡂⠀⣀⣿⠀⠀⣰⣴⣧⣿⣿⣿⣿⣧⡜⡢⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡸⣿⣿⢰⠁⠀⡀⡇⠀⠘⣿⣿⣿⡙⢿⣆⣀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡞⠉⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣟⡶⠁⢈⠠⠄⢸⣿⡇⢀⣠⣿⣼⣧⣿⣿⣿⡿⣿⣣⣤⠃⠀⢠⠀⠀⠀⠀⠀⠀⠀⡇⢼⣿⡆⠁⠈⢳⣷⡀⠀⠨⣿⣿⣿⣿⣿⣿⣷⠄⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠟⢻⣿⣿⣿⣿⣿⣿⡟⣿⣿⣿⣿⣿⠽⠇⢀⣭⣤⣴⣿⣿⣶⣴⣿⢿⡿⣽⣿⣿⣿⡷⣽⣿⡟⣦⠀⢰⡇⠀⠀⠀⠀⠀⠀⠁⣼⣿⣷⠀⠀⢦⣿⣿⡀⠀⠋⠁⠀⠈⠁⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢰⣿⣿⣿⣿⣿⣿⣿⣹⣿⣿⣿⣿⠁⡦⠀⣼⣿⣿⣿⣿⡎⠻⣿⡏⡾⢰⡏⢻⣿⡟⢠⠙⣿⣟⣿⠀⠀⣀⣀⣂⠀⠀⠀⠀⠀⡈⣿⣿⡀⠀⢸⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣄⣹⣶⣿⣿⢿⣿⢿⡇⠀⠹⣿⣣⡀⠰⠻⣿⡇⠀⠠⠈⣿⠙⠀⣸⣿⣿⣿⣷⡀⠀⠐⢀⢆⢻⣿⣷⡄⠸⠙⢻⣿⠆⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣽⠿⣿⠻⣿⣦⣀⣾⣇⠀⢀⣿⣯⡵⠀⠈⣼⠃⠀⠀⠀⠯⠀⠀⢿⣟⠛⣹⣿⡿⣷⣦⢸⣿⡷⢿⣿⣧⠀⠀⢸⣿⣼⡄⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢰⣿⢰⣿⣆⠀⠙⠻⢿⣿⡄⢸⢿⠓⠀⠈⣖⣽⠀⠀⠀⠀⠀⠀⠀⣿⣿⡿⠛⠁⢠⡜⠙⢺⡟⡁⠸⣿⣿⡆⠀⢸⣿⣿⣿⣾⣦⡀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠚⠁⣾⣿⣿⣷⣄⠀⢸⣿⣷⣆⢾⡁⢀⢀⠱⣷⡇⠀⠀⠀⠀⠐⠠⣿⡟⠀⢀⣶⣶⣧⠄⠘⠿⠇⠘⣿⣿⣷⡄⢸⣿⣿⣿⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⢨⡗⣿⣿⣿⣿⣿⣿⡟⣿⣿⣿⣷⣦⣄⡄⣾⣿⣯⡁⠀⠀⠀⠀⠘⠿⠀⣴⣾⣿⣿⣽⠀⠀⠀⠀⢠⣿⣿⣿⣿⣼⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⡠⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣽⣾⣿⣽⣿⣿⣿⣿⣿⣷⣿⣿⣿⣿⣿⣿⣾⣿⣿⣿⣄⡀⠀⠀⠀⠟⠀⢰⡿⣿⣿⡻⣟⠀⠀⠀⠀⡹⢿⠛⢿⣿⣿⣿⡇⠉⠻⣿⣿⡟⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠘⢀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢿⡿⣿⣿⣿⣿⣿⣿⣿⣻⣿⣿⣿⣿⣿⣿⣿⣿⢣⡄⠀⢀⠀⠀⠀⣽⣿⢿⠀⠡⠀⠀⠀⠀⢥⣈⡀⠀⢿⣿⣿⣿⡀⠀⠙⠏⢷⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢺⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢻⣿⠆⣼⣽⣿⣿⡟⣽⣿⡗⣹⣿⣿⣿⣿⣿⣿⣿⠇⠀⠀⠀⠀⢠⡁⠀⡙⢻⡇⠀⠀⠀⠀⠀⠀⣼⢿⣧⣷⣼⣿⣿⠿⠇⠀⠀⠀⠈⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣿⣿⡿⣻⣿⡗⣸⣿⣿⣿⣿⣿⣿⣿⣟⡠⠀⠀⠀⠀⡈⢧⠀⠙⢰⣷⠀⠀⠀⠀⠀⠀⣿⠉⣿⣿⣿⣿⣿⡀⠀⠐⣆⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣗⡏⣿⣿⣟⢱⣿⣿⣼⣾⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⢻⡄⢸⡁⠀⠀⠉⠀⠀⠀⠀⠀⠀⢻⡄⣿⣿⣿⣿⣿⣿⡀⠀⠈⠦⡀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠙⡤⠹⣿⡿⣿⢿⡿⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⢯⠀⠀⠀⣷⡏⠈⠇⠀⠀⠀⢸⠀⠀⠀⠀⢤⣼⣧⣿⣿⣿⣿⣿⣿⡇⠀⣠⡆⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⡀⢨⡿⢿⣿⣿⣿⣿⣿⣿⣿⣿⢿⠿⡿⣟⠼⠁⠀⠀⠀⠀⠷⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠷⡄⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢠⡾⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⢠⢐⠁⣾⣿⣏⣿⠉⣿⠟⠋⠀⠀⠀⠀⠀⢂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⣿⣿⣿⣿⣿⣿⣿⣿⠋⣿⢻⣷⡀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠠⠋⢀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⣈⠀⡋⣿⠃⡟⢸⣧⣶⣷⣷⣶⣶⣴⣶⣿⣿⣿⣤⢀⣶⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⢘⣸⣿⣿⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⡾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡕⣿⣿⣇⠀⠈⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⣾⣿⣿⣿⣿⣿⣿⣿⣿⠿⡀⢸⣿⣿⣿⣇⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠛⢿⡷⡀⢹⣿⣿⣿⣿⣿⣿⣿⣻⣿⣿⣿⣿⠀⠀⠀⠀⠂⠀⠀⠀⠀⠀⣹⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⡇⢸⣿⠃⢹⣿⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠺⠿⠛⠿⠀⠈⠛⢿⣿⣿⣿⣿⣿⡿⠛⠇⠀⠠⠀⠐⠀⠀⠀⠀⠀⠀⢤⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⣧⣾⡋⠀⠘⣿⡄⠀⠀⠀⠀
⠀⠀⠀⠀⠀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠃⠀⠀⣀⣄⢀⣠⡄⣀⠈⠻⣿⣿⠛⠀⢀⢠⢀⡀⠀⠀⠀⠀⠀⠀⠀⢰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⡼⠛⢷⡀⠀⢿⣧⠀⠀⠀⠀
⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡧⠀⠐⠛⠉⠀⠀⠠⡀⠀⠀⢻⣿⠀⢀⠀⠀⠀⠀⠉⠀⠀⠀⠀⠀⡰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠇⠀⣾⣿⡀⠀⠀⠀
⠀⠀⠀⠀⠸⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⣠⣦⠰⠂⠀⠀⠀⠀⢸⣇⠀⠈⠀⠀⠂⠤⢀⡀⠀⠀⠀⠘⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⠄⠀⠀⠀⢀⣹⣿⡇⠀⠀⠀
⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣵⡇⠀⡉⢁⠀⠀⠀⠀⢀⣠⣿⣿⣆⡀⠀⠀⠀⠄⠀⠀⠀⠀⠀⣹⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠃⠀⠀⠀⠀⣿⣿⣷⠀⠀⠀
⠀⠀⠀⠀⢀⠏⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣯⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠇⠐⡇⠀⠀⠀⢀⣠⣷⣿⣿⣿⣿⣷⣄⠀⠀⠀⠃⠀⠀⠀⠰⡸⣷⣬⡻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⢠⣿⣿⣿⡇⠀⠀
⠀⠀⠀⠀⢠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣯⣆⠀⠀⠀⢀⣐⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠠⠀⠀⠀⠀⠀⠀⠣⣿⣿⣷⣼⣿⣿⣿⣿⣟⣿⣿⢿⣿⡏⠀⠀⠀⠀⢈⢸⣿⣿⣿⠀⠀
⠀⠀⠀⠀⣸⠟⣹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣇⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢷⣿⣶⣴⣿⣿⣿⡿⠿⢛⠿⢻⣿⣿⣿⢿⣿⣷⣶⠀⠀⠀⠀⢠⣷⠹⣿⣿⣿⣿⣿⣿⣿⡇⢿⣿⠀⠙⠁⠀⠀⢠⣠⣈⣴⣿⣿⣿⠀⠀
⠀⠀⠀⠰⠋⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠉⠉⠈⠁⠀⠉⡰⢾⣷⣇⠉⠀⠀⠀⠋⠁⠀⠂⢱⣿⣿⣧⢿⣿⣿⣿⣿⡻⢻⣧⠘⠇⠀⠀⠀⠀⠀⢈⠹⢹⣿⣿⣿⣿⡄⠀
⠀⠀⠀⢀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡁⠀⠀⠀⠀⠀⠀⠀⠘⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⣿⣿⣿⣿⣿⣿⣿⢡⠈⢰⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣶⣿⣿⣿⡇⠀
⠀⠀⠀⠈⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⡀⢸⢰⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣟⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⡄⠈⠀⣿⣿⣿⣿⡇⠀
⠀⠀⠀⣸⣿⣿⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣇⡄⡀⠀⠀⠀⠀⠃⠘⠀⠀⠀⠀⠀⠀⠀⠀⠀⣧⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⢴⠀⠀⠈⢸⣿⣿⣿⣇⠀
⠀⠀⠀⣿⣿⢏⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡆⣰⠀⠀⠀⠀⠀⢀⠀⠀⠀⠀⠀⢀⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⠆⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡆⠀⠀⣄⣿⣿⣿⣿⠀
⠀⠀⢰⣿⢋⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣾⣶⣿⣆⢀⣾⣤⣆⣤⣧⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢧⠀⠀⠀⠀⠀⠀⠀⢀⠀⠀⢸⣷⠁⢂⣿⣿⣿⣿⡿⠀
⠀⠀⣹⠇⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢋⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⢿⡆⠀⠀⠀⠀⠀⠀⢰⣿⣤⣧⠸⣿⠃⣼⡿⣿⣿⣿⡇⡀
⠀⢀⡿⣠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣾⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀⢠⡀⢸⣿⣧⣿⣷⣿⣷⡿⢷⣿⣿⣿⣿⡇
⠀⢸⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡅⠀⠀⠀⠀⠀⡀⢵⣜⣿⣿⣿⣿⣿⢿⣿⣸⣿⣿⣿⣿⣧
⠀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠃⠘⠁⠀⠀⠀⠀⣧⣽⣿⣿⣿⣿⣿⣿⣿⣆⣿⣿⣿⣿⣿⣿⣿       
]], '\n', { trimempty = true })
dashboard.section.header.opts.hl = 'Comment'
dashboard.section.buttons.val = {}
dashboard.section.footer.val = 'Flowres v8200'
dashboard.section.footer.opts.hl = 'Comment'
alpha.setup(dashboard.opts)
