-- Extra syntax tweaks (no plugin required)

-- Highlight dot-call names in Go, e.g., .New(), .QueryRow()
vim.api.nvim_create_autocmd('FileType', {
	pattern = 'go',
	callback = function()
		-- Window-local highlight for identifiers after a dot before '(' (e.g., .New())
		local function set_dotcall_match()
			if vim.b.go_dotcall_match_id then
				pcall(vim.fn.matchdelete, vim.b.go_dotcall_match_id)
			end
			vim.b.go_dotcall_match_id = vim.fn.matchadd('GoDotCall', [[\v\.\zs[A-Za-z_][A-Za-z0-9_]*\ze\s*\(]])
		end
		set_dotcall_match()

		vim.api.nvim_create_autocmd({ 'BufWinEnter', 'WinEnter' }, {
			buffer = 0,
			callback = function()
				set_dotcall_match()
			end,
		})
	end,
})


-- Ensure rule is present after the Go syntax file defines its groups
vim.api.nvim_create_autocmd('Syntax', {
	pattern = 'go',
	callback = function()
		vim.cmd([[syntax match GoDotCall /\v\.\zs[A-Za-z_][A-Za-z0-9_]*\ze\s*\(/]])
	end,
})

