-- Load modular config
require('config.options')
require('config.keymaps')
require('config.autocmds')
require('config.ui')
require('config.syntax')
require('config.autopairs')

-- LSP servers
pcall(function()
	require('lsp.servers.gopls').setup()
end)

