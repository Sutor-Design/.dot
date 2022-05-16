-- Certain plugins require quite a bit of setup.
-- This will automatically run `init` or `setup` functions for those plugins.
local currentmod = (...)
local M = {}

local function add(modname)
	local modulepath = string.format("%s.%s", currentmod, modname)
	local success, results = pcall(require, modulepath)
	if not success then
		vim.api.nvim_err_writeln(results)
		return
	end

	return results
end

M.init = function()
	-- nothing to see here atm
end

M.setup = function()
	add("cmp")
	add("comment")
	add("lsp")
	add("luasnip")
	add("org")
	add("telescope")
	add("treesitter")
	add("which-key")
	add("alpha")
	add("colorizer")
end

return M
