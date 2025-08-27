-- Autopairs configuration
local autopairs = { ["("] = ")", ["{"] = "}", ["["] = "]", ['"'] = '"', ["'"] = "'", ["`"] = "`" }

-- Function to skip over closing char if next char matches
function _G.vim_pairs_skip(char)
    if vim.fn.strpart(vim.fn.getline("."), vim.fn.col(".") - 1, 1) == char then
        return vim.api.nvim_replace_termcodes("<Right>", true, false, true)
    else
        return char
    end
end

-- Setup mappings
for open_char, close_char in pairs(autopairs) do
    local open = open_char
    local close = close_char

    if open == close then
        vim.api.nvim_set_keymap(
            "i",
            open,
            "",
            {
                expr = true,
                noremap = true,
                silent = true,
                desc = "Skip quote " .. open,
                callback = function()
                    local next_char = vim.fn.strpart(vim.fn.getline("."), vim.fn.col(".") - 1, 1)
                    if next_char == open then
                        return vim.api.nvim_replace_termcodes("<Right>", true, false, true)
                    else
                        return open
                    end
                end
            }
        )
    else
        vim.api.nvim_set_keymap(
            "i",
            open,
            open .. close .. "<Left>",
            { noremap = true, silent = true, desc = "Autopair " .. open }
        )

        vim.api.nvim_set_keymap(
            "i",
            close,
            "",
            {
                expr = true,
                noremap = true,
                silent = true,
                desc = "Skip pair " .. close,
                callback = function() return _G.vim_pairs_skip(close) end
            }
        )
    end
end

-- Enter between pairs: split to new indented line
function _G.vim_pairs_enter()
	local line = vim.fn.getline(".")
	local col = vim.fn.col(".") - 1
	if col < 1 then
		return vim.api.nvim_replace_termcodes("<CR>", true, false, true)
	end
	local prev = string.sub(line, col, col)
	local next_char = string.sub(line, col + 1, col + 1)
	local pairs = { ["("] = ")", ["{"] = "}", ["["] = "]" }
	local close = pairs[prev]
	if close and next_char == close then
		return vim.api.nvim_replace_termcodes("<CR><Esc>O", true, false, true)
	end
	return vim.api.nvim_replace_termcodes("<CR>", true, false, true)
end

vim.keymap.set("i", "<CR>", function()
	return _G.vim_pairs_enter()
end, { expr = true, noremap = true, silent = true, desc = "Split pairs on Enter" })


