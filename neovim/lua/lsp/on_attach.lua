local function on_attach(client, bufnr)
	local opts = { buffer = bufnr, noremap = true, silent = true }

	-- Basic LSP keymaps
	vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
	vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
	vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
	vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
	vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
	vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
	vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)

	-- Diagnostics
	vim.keymap.set('n', 'gh', vim.diagnostic.open_float, opts)
	vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
	vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)

	-- Formatting (buffer-local; avoid clobbering global <leader>f)
	vim.keymap.set('n', '<leader>lf', function()
		vim.lsp.buf.format({ async = false })
	end, opts)

	-- Enable semantic tokens (method/function/property coloring without Treesitter)
	if client.server_capabilities.semanticTokensProvider then
		vim.lsp.semantic_tokens.start(bufnr, client.id)
	end
end

return on_attach


