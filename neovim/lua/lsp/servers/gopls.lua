local M = {}

function M.setup()
	local lspconfig = require('lspconfig')
	local on_attach = require('lsp.on_attach')

	lspconfig.gopls.setup({
		on_attach = on_attach,
		cmd = { 'gopls' },
		settings = {
			gopls = {
				completeUnimported = true,
				usePlaceholders = true,
				staticcheck = true,
				gofumpt = true,
			},
		},
	})

	-- Format Go files on save
	vim.api.nvim_create_autocmd('BufWritePre', {
		pattern = '*.go',
		callback = function()
			vim.lsp.buf.format({ async = false })
		end,
	})
end

return M


