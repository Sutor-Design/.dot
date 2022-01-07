local g = vim.g
local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event


-- That banner doesn't seem ver useful. If I can pluck out details of it might
-- be, but just hide it for now by default.
g.netrw_banner = 0
-- open files in previous window by default.
g.netrw_browse_split = 4
-- NOTE: controlled by `a`, but default hidden files to "show all", I normally
-- want to see dotfiles etc.
g.netrw_hide = 0
-- 1 is "keep current dir immune from the browsing dir", 0 keeps the current dir
-- the same as the browsing dir. 1 is the default, but I _think_ I'm going to
-- want this toggleable.
g.netrw_keepdir = 1
-- set the default list style to "tree"
g.netrw_liststyle = 3

g.netrw_altv = 1
-- <tab> map supporting shrinking/expanding a window enabled
g.netrw_usetab = 1

g.netrw_winsize = 25

g.NetrwTopLvlMenu = "Vex"

function ToggleNetrwInPopup()
    if vim.g.NetrwIsOpen then
        local i = vim.fn.bufnr("$")
        while (i >= 1)
        do
            if (vim.fn.getbufvar(i, "&filetype") == "netrw") then
                vim.cmd("bwipeout" .. i)
                break
            end
            i = i - 1
        end
        vim.g.NetrwIsOpen = false
    else
			-- see `:h expand()`, `:h filename-modifiers` and `:h %`
			local current_buf_path = vim.fn.expand("%:p:h")
			local vex_popup = Popup({
				enter = true,
				focusable = true,
				border = {
					style = "rounded",
				},
				position = "50%",
				relative = "editor",
				size = {
					width = "80%",
					height ="60%",
				},
			})
			vex_popup:mount()
			-- set netrw variavles for this exploration.
			g.netrw_preview = 1

			vim.cmd("Explore" .. current_buf_path)
			vim.g.NetrwIsOpen = true
    end
end

function ToggleNetrw()
    if vim.g.NetrwIsOpen then
        local i = vim.fn.bufnr("$")
        while (i >= 1)
        do
            if (vim.fn.getbufvar(i, "&filetype") == "netrw") then
                vim.cmd("bwipeout" .. i)
                break
            end
            i = i - 1
        end
        vim.g.NetrwIsOpen = false
    else
        vim.g.NetrwIsOpen = true
        vim.cmd("Vexplore")
    end
end

vim.api.nvim_set_keymap("n", "<C-m>", [[:lua ToggleNetrwInPopup()<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-n>", [[:lua ToggleNetrw()<CR>]], { noremap = true, silent = true })

vim.cmd [[
	augroup AutoDeleteNetrwHiddenBuffers
		autocmd!
		autocmd FileType netrw setlocal bufhidden=wipe
	augroup END
]]
