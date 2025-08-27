-- Appearance / UI
vim.opt.termguicolors = true
vim.wo.signcolumn = "yes"
vim.g.netrw_banner = 0

vim.opt.cmdheight = 0
vim.opt.laststatus = 3   -- 3 = global statusline (one bar, not per window)

-- OneDark-like palette
local palette = {
  bg        = "#282c34",
  bg_alt    = "#21252b",
  fg        = "#abb2bf",
  fg_dim    = "#9da5b4",
  comment   = "#5c6370",
  gutter    = "#4b5263",
  cursorln  = "#2c323c",
  select    = "#3e4451",
  black     = "#1e222a",
  red       = "#e06c75",
  green     = "#98c379",
  yellow    = "#e5c07b",
  blue      = "#61afef",
  magenta   = "#c678dd",
  cyan      = "#56b6c2",
  orange    = "#d19a66",
}

-- Main editing area
vim.api.nvim_set_hl(0, "Normal",       { bg = palette.bg,     fg = palette.fg })
vim.api.nvim_set_hl(0, "NormalNC",     { bg = palette.bg_alt, fg = palette.fg_dim })
vim.api.nvim_set_hl(0, "NonText",      { fg = palette.gutter })
vim.api.nvim_set_hl(0, "Whitespace",   { fg = palette.gutter })
vim.api.nvim_set_hl(0, "LineNr",       { fg = palette.gutter })
vim.api.nvim_set_hl(0, "CursorLine",   { bg = palette.cursorln })
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = palette.yellow, bold = true })
vim.api.nvim_set_hl(0, "ColorColumn",  { bg = palette.bg_alt })
vim.api.nvim_set_hl(0, "SignColumn",   { bg = palette.bg })
vim.api.nvim_set_hl(0, "Visual",       { bg = palette.select })
vim.api.nvim_set_hl(0, "MatchParen",   { bg = palette.select, bold = true })

-- Popups / Menus / Floats
vim.api.nvim_set_hl(0, "Pmenu",       { bg = palette.bg_alt, fg = palette.fg })
vim.api.nvim_set_hl(0, "PmenuSel",    { bg = palette.select, fg = palette.fg })
vim.api.nvim_set_hl(0, "PmenuSbar",   { bg = palette.bg_alt })
vim.api.nvim_set_hl(0, "PmenuThumb",  { bg = palette.select })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = palette.bg_alt, fg = palette.fg })
vim.api.nvim_set_hl(0, "FloatBorder", { bg = palette.bg_alt, fg = palette.gutter })
vim.api.nvim_set_hl(0, "WinSeparator",{ fg = palette.gutter })

-- Statusline + Command area
vim.api.nvim_set_hl(0, "StatusLine",     { fg = palette.fg,     bg = palette.bg_alt })
vim.api.nvim_set_hl(0, "StatusLineNC",   { fg = palette.fg_dim, bg = palette.bg_alt })
vim.api.nvim_set_hl(0, "StatusLineSep",  { fg = palette.gutter, bg = palette.bg_alt })
vim.api.nvim_set_hl(0, "MsgArea",        { fg = palette.fg,     bg = palette.bg_alt })
vim.api.nvim_set_hl(0, "StatusLineTerm", { fg = palette.fg,     bg = palette.bg_alt })
vim.api.nvim_set_hl(0, "StatusLineTermNC",{ fg = palette.fg_dim, bg = palette.bg_alt })

-- Search
vim.api.nvim_set_hl(0, "Search",    { bg = palette.yellow, fg = palette.black, bold = true })
vim.api.nvim_set_hl(0, "IncSearch", { bg = palette.orange, fg = palette.black, bold = true })

-- Diff
vim.api.nvim_set_hl(0, "DiffAdd",    { fg = palette.green })
vim.api.nvim_set_hl(0, "DiffChange", { fg = palette.yellow })
vim.api.nvim_set_hl(0, "DiffDelete", { fg = palette.red })
vim.api.nvim_set_hl(0, "DiffText",   { fg = palette.blue })

-- Diagnostics
vim.api.nvim_set_hl(0, "DiagnosticError", { fg = palette.red })
vim.api.nvim_set_hl(0, "DiagnosticWarn",  { fg = palette.yellow })
vim.api.nvim_set_hl(0, "DiagnosticInfo",  { fg = palette.blue })
vim.api.nvim_set_hl(0, "DiagnosticHint",  { fg = palette.cyan })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { undercurl = true, sp = palette.red })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn",  { undercurl = true, sp = palette.yellow })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo",  { undercurl = true, sp = palette.blue })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint",  { undercurl = true, sp = palette.cyan })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = palette.red,    bg = palette.bg_alt })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn",  { fg = palette.yellow, bg = palette.bg_alt })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo",  { fg = palette.blue,   bg = palette.bg_alt })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint",  { fg = palette.cyan,   bg = palette.bg_alt })

-- Syntax
vim.api.nvim_set_hl(0, "Comment",        { fg = palette.comment, italic = true })
vim.api.nvim_set_hl(0, "Constant",       { fg = palette.orange })
vim.api.nvim_set_hl(0, "String",         { fg = palette.green })
vim.api.nvim_set_hl(0, "Character",      { fg = palette.green })
vim.api.nvim_set_hl(0, "Number",         { fg = palette.orange })
vim.api.nvim_set_hl(0, "Boolean",        { fg = palette.orange })
vim.api.nvim_set_hl(0, "Float",          { fg = palette.orange })
vim.api.nvim_set_hl(0, "Identifier",     { fg = palette.blue })
vim.api.nvim_set_hl(0, "Function",       { fg = palette.blue })
vim.api.nvim_set_hl(0, "Statement",      { fg = palette.magenta })
vim.api.nvim_set_hl(0, "Conditional",    { fg = palette.magenta })
vim.api.nvim_set_hl(0, "Repeat",         { fg = palette.magenta })
vim.api.nvim_set_hl(0, "Label",          { fg = palette.magenta })
vim.api.nvim_set_hl(0, "Operator",       { fg = palette.cyan })
vim.api.nvim_set_hl(0, "Keyword",        { fg = palette.magenta })
vim.api.nvim_set_hl(0, "Exception",      { fg = palette.magenta })
vim.api.nvim_set_hl(0, "PreProc",        { fg = palette.yellow })
vim.api.nvim_set_hl(0, "Include",        { fg = palette.yellow })
vim.api.nvim_set_hl(0, "Define",         { fg = palette.yellow })
vim.api.nvim_set_hl(0, "Macro",          { fg = palette.yellow })
vim.api.nvim_set_hl(0, "PreCondit",      { fg = palette.yellow })
vim.api.nvim_set_hl(0, "Type",           { fg = palette.yellow })
vim.api.nvim_set_hl(0, "StorageClass",   { fg = palette.yellow })
vim.api.nvim_set_hl(0, "Structure",      { fg = palette.yellow })
vim.api.nvim_set_hl(0, "Typedef",        { fg = palette.yellow })
vim.api.nvim_set_hl(0, "Special",        { fg = palette.blue })
vim.api.nvim_set_hl(0, "SpecialChar",    { fg = palette.blue })
vim.api.nvim_set_hl(0, "Tag",            { fg = palette.blue })
vim.api.nvim_set_hl(0, "Delimiter",      { fg = palette.fg_dim })
vim.api.nvim_set_hl(0, "SpecialComment", { fg = palette.comment, italic = true })
vim.api.nvim_set_hl(0, "Debug",          { fg = palette.red })
vim.api.nvim_set_hl(0, "Underlined",     { underline = true })
vim.api.nvim_set_hl(0, "Ignore",         { fg = palette.gutter })
vim.api.nvim_set_hl(0, "Error",          { fg = palette.red })
vim.api.nvim_set_hl(0, "Todo",           { bg = palette.yellow, fg = palette.black, bold = true })

-- Treesitter: nvim 0.9+ highlight groups (method/function emphasis)
vim.api.nvim_set_hl(0, "@function",        { fg = palette.blue })
vim.api.nvim_set_hl(0, "@function.call",   { fg = palette.blue })
vim.api.nvim_set_hl(0, "@method",          { fg = palette.cyan })
vim.api.nvim_set_hl(0, "@method.call",     { fg = palette.cyan })
vim.api.nvim_set_hl(0, "@property",        { fg = palette.yellow })
vim.api.nvim_set_hl(0, "@field",           { fg = palette.yellow })

-- LSP semantic tokens → link to Treesitter-like groups
vim.api.nvim_set_hl(0, "@lsp.type.function", { link = "@function" })
vim.api.nvim_set_hl(0, "@lsp.type.method",   { link = "@method" })
vim.api.nvim_set_hl(0, "@lsp.type.property", { link = "@property" })
vim.api.nvim_set_hl(0, "@lsp.type.member",   { link = "@field" })

-- Go runtime syntax groups (fallback if Treesitter/semantics don't mark calls)
vim.api.nvim_set_hl(0, "goFunctionCall", { fg = palette.blue })
vim.api.nvim_set_hl(0, "goMethodCall",   { fg = palette.cyan, bold = false })
vim.api.nvim_set_hl(0, "GoDotCall",      { fg = palette.cyan })

local function lsp_status()
    local attached_clients = vim.lsp.get_clients({ bufnr = 0 })
    if #attached_clients == 0 then
        return ""
    end
    local names = vim.iter(attached_clients)
        :map(function(client)
            local name = client.name:gsub("language.server", "ls")
            return name
        end)
        :totable()
    return "[" .. table.concat(names, ", ") .. "]"
end

vim.opt.statusline = table.concat({
    "%=",                       -- everything on the right
    "%f",                       -- filename
    "%h%w%m%r",
    lsp_status(),
})


