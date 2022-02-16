-- vim:fileencoding=utf-8:foldmethod=marker
-- =============================================================================
-- Dan Couper
-- danielcouper.sutor@gmail.com
-- https://github.com/DanCouper
--
-- NOTE: Requires HEAD (currently on v0.7). Probably. Some stuff might break if
-- not on HEAD but whatever, YOLO.
-- NOTE: Cribbed from a number of sources, in particular:
--       - https://github.com/mjlbach/defaults.nvim
--       - https://github.com/neovim/nvim-lspconfig/wiki
--       - https://github.com/mukeshsoni/config/blob/master/.config/nvim/init.lua
--       - https://github.com/evantravers/dotfiles/blob/master/nvim/.config/nvim/init.lua
--       - https://neovim.discourse.group/t/the-300-line-init-lua-challenge/227
--       - https://github.com/nanotee/nvim-lua-guide/
--			 - https://gist.github.com/ammarnajjar/3bdd9236cf62513a79db20520ba8467d
--			 - https://github.com/tjdevries/config_manager/blob/master/xdg_config/nvim/lua/tj/plugins.lua
--			 - https://github.com/creativenull/dotfiles (see particularly the way plugin setup works)
-- =============================================================================
-- {{{ Plugins
-- =============================================================================
-- Automatically ensure that Packer installs itself if it isn't already present.
local install_path = vim.fn.stdpath "data"
	.. "/site/pack/packer/start/packer.nvim"

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
	vim.fn.execute(
		"!git clone https://github.com/wbthomason/packer.nvim " .. install_path
	)
end

vim.api.nvim_exec(
	[[
		augroup Packer
			autocmd!
			autocmd BufWritePost init.lua PackerCompile
		augroup end
	]],
	false
)
-- ...then define plugins
require("packer").startup(function(use)
	-- Packer --------------------------------------------------------------------
	-- NOTE: Package manager written in Lua. Add packages here. Save. Run
	-- `:source %`. Run `:PackerSync`.
	use { "wbthomason/packer.nvim" }
	-- Profiling etc -------------------------------------------------------------
	-- NOTE: Stuff here is for dev on Nvim only, not important to actual editing
	use { "dstein64/vim-startuptime" }
	-- Colour theme --------------------------------------------------------------
	-- NOTE: Using Lush to build this. It has a nice DSL that allows for live
	-- updating, and there's a build tool that can then generate output for
	-- loads of other things (eg, creating a terminal theme). The downside is
	-- that to make use of it, the theme needs to be a plugin, so that's
	-- stored at `./sutor_theme.nvim/`. To get live updating when developing, open
	-- a buffer with the theme file and run `:Lushify<Cr>`
	use { "rktjmp/lush.nvim" }
	use { "~/.config/nvim/sutor_theme.nvim", as = "colorscheme" }
	-- New NVim UI ---------------------------------------------------------------
	-- NOTE: NVim is *starting* to implement UI stuff. It's a little raw atm, but
	-- there are a few plugin authors making it all a bit more approachable.
	-- IMPORTANT: this stuff a. requires somewhat bleeding-edge version of NVim,
	-- and b. is going to go out of date pretty quickly, so be careful.
	use { "stevearc/dressing.nvim" }
	-- Editorconfig --------------------------------------------------------------
	-- NOTE: editorconfig keeps text editor config consistent across machines and
	-- means I don't have to specify the tab/space size in the vim config.
	use { "editorconfig/editorconfig-vim" }
	-- Treesitter ----------------------------------------------------------------
	-- NOTE: setting it to auto run update. Otherwise need to ensure that
	-- treesitter packages are installed for each language, treesitter itself
	-- won't do anything otherwise.
	use { "nvim-treesitter/nvim-treesitter" }
	-- Plus some treesitter-powered stuff, just testing!
	-- REVIEW: this adds some virtual text showing the current context after the
	-- current block, function etc. This may be annoying, but should be v helpful
	-- in larger codebases.
	use { "haringsrob/nvim_context_vt" }
	-- Language servers ----------------------------------------------------------
	-- NOTE: This gets a bit complicated the more functionality I add, so
	-- delegating the configs to a separate module. nvim-lsp-installer is a
	-- companion to lspconfig; provides utilities for [auto] installing language
	-- servers (not *necessarily* a great idea, but I'll stick with it for now).
	use { "neovim/nvim-lspconfig" }
	use { "williamboman/nvim-lsp-installer" }
	use { "jose-elias-alvarez/null-ls.nvim" }
	use { "b0o/schemastore.nvim" }
	-- Completions & Snippets ----------------------------------------------------
	-- NOTE: Bit of a faff to set up; cmp is the core autocomplete plugin, but
	-- then need a lod of other stuff to get plugins &c.
	-- NOTE: Snippets have been commented out rather than completely removed;
	-- just testing to see if I miss them. They are extremely annoying at times,
	-- so if I can nix them, then good.
	use { "hrsh7th/nvim-cmp" }
	use { "hrsh7th/cmp-nvim-lsp" }
	use { "hrsh7th/cmp-buffer" }
	use { "hrsh7th/cmp-path" }
	use { "saadparwaiz1/cmp_luasnip" }
	use { "onsails/lspkind-nvim" }
	use { "l3mon4d3/luasnip" }
	-- use { "rafamadriz/friendly-snippets" }
	-- Fuzzy find ----------------------------------------------------------------
	use { "nvim-telescope/telescope.nvim" }
	use { "nvim-lua/plenary.nvim" }
	use { "nvim-telescope/telescope-project.nvim" }
	use { "nvim-telescope/telescope-file-browser.nvim" }
	-- Commenting ----------------------------------------------------------------
	use { "numToStr/Comment.nvim" }
	-- Orgmode -------------------------------------------------------------------
	use { "nvim-orgmode/orgmode" }
	-- Which-key -----------------------------------------------------------------
	use { "folke/which-key.nvim" }
	------------------------------------------------------------------------------
end)

-- for plugins that use `setup`:
require("plugins").setup()
-- }}}
-- =============================================================================
-- {{{ Theme
-- =============================================================================
-- Need termguicolors set to get owt fancy
vim.env.nvim_tui_enable_true_color = 1
vim.o.termguicolors = true
vim.cmd [[ colorscheme sutor_dark]]
-- }}}
-- =============================================================================
-- {{{ Options
-- ============================================================================
-- ----------------------------------------------------------------------------
-- global options
-- ----------------------------------------------------------------------------
vim.o.title = true
vim.o.titlestring = " %t"
-- set highlight on search
vim.o.hlsearch = false
-- enable mouse mode
vim.o.mouse = "a"
-- highlight current line
vim.o.cursorline = true
-- show autocomplete menu on <tab>
vim.o.wildmenu = true
-- don't redraw as much
vim.o.lazyredraw = true
-- highlight matching [({})]...
vim.o.showmatch = true
-- ...after 1/10 of a second
vim.o.matchtime = 1
-- show non-visible characters
vim.o.list = true
vim.o.listchars =
	"eol:↴,extends:…,nbsp:▴,precedes:…,space:⋅,tab:> ,trail:-"
-- at least 8 lines visible at top & bottom of screen unless at start/end. nice,
-- keeps the cursor in a more sensible position, can see what's above/below.
vim.o.scrolloff = 8
-- same for horizontal scrolling
vim.o.sidescrolloff = 8
--case insensitive searching unless /c or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true
--decrease update time
vim.o.updatetime = 250
-- code folding
-- adds character space to left of screen. leave this in regradless because i
-- like a bit of padding and padding is quite difficult to get with vim so i'll
-- take it where i can
vim.o.foldcolumn = "1"
-- NOTE: maybe turn off for the minute, i think it's possibly more annoying than
-- useful *in general*. for specific filetypes it's extremely useful, so
-- ideally i want it enabled only for them, but i need to actually note which
-- ones during usage.
vim.o.foldenable = true
-- NOTE: however maybe I just want it turned off for this file as it was
-- driving me nuts?? even just using the markers is driving me nuts.
-- anyway, maybe i just want it off for this file, in which case, modeline opts:
vim.o.modelines = 2
vim.bo.modeline = true
-- having now accidentally fatfingered my way through losing a large chunk of
-- work due to fucking swapfile recovery I did not need recovering, turn off
-- the fucking swapfile recovery stuff, yolo etc.
vim.o.writebackup = false
vim.o.swapfile = false
-- show substitution live as I type. Yes pls
vim.o.inccommand = "nosplit"
-- completion-related
vim.o.inccommand = "nosplit"
-- hide some of the completion messages -- :h shortmess gives an explanation as to why
vim.cmd [[set shortmess+=c]]
-- ----------------------------------------------------------------------------
-- window options
-- ----------------------------------------------------------------------------
-- make line numbers default
vim.wo.number = true
-- use relative numbering to make it easier to j and k around
vim.wo.relativenumber = true
-- show the sign column. the sign column is for stuff like highlighting lines
-- with errors or git integration stuff.
vim.wo.signcolumn = "yes"
-- in the sign column, I want diagnostic hints to be a symbol, with colour
-- denoting level; I don't really like the default letter.
local signs = {
	-- { name = "DiagnosticSignError", text = "" },
	-- { name = "DiagnosticSignWarn", text = "" },
	-- { name = "DiagnosticSignHint", text = "" },
	-- { name = "DiagnosticSignInfo", text = "" },
	{ name = "DiagnosticSignError", text = "※" },
	{ name = "DiagnosticSignWarn", text = "※" },
	{ name = "DiagnosticSignHint", text = "※" },
	{ name = "DiagnosticSignInfo", text = "※" },
}

for _, sign in ipairs(signs) do
	vim.fn.sign_define(
		sign.name,
		{ texthl = sign.name, text = sign.text, numhl = "" }
	)
end
-- the colorcolunm is just a visual reminder of the ideal max width. 80 is
-- good for me i think, maybe i'm probably doing something too nested or verbose
-- if i go over it, who knows.
-- NOTE: yes, it's set to 81.
vim.wo.colorcolumn = "81"
-- turn *off* wordwrap by default, only want it for prose.
vim.wo.wrap = false
-- ----------------------------------------------------------------------------
-- lsp-, completion- and syntax-related options
-- ----------------------------------------------------------------------------
-- put the diagnostics in a float, it's driving me nuts not being able to
-- read them
vim.diagnostic.config {
	virtual_text = false,
	signs = true,
	float = { border = "single" },
	severity_sort = true,
	update_in_insert = true,
}
-- ...and add the autocommands to allow that to show
vim.cmd [[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, { focus = false, scope = "cursor" })]]
-- markdown syntax highlighting
vim.g.markdown_fenced_languages = {
	"ts=typescript",
}
-- which key to use when confirming completions
vim.g.completion_confirm_key = ""
-- extra completions stuff
vim.g.completion_matching_strategy_list = { "exact", "substring", "fuzzy" }
-- I mean this is supposed to weight things but it really doesn't seem to do
-- great, hey ho. I still generally get "text" as the most common option above
-- useful stuff like LSP results.
vim.g.completion_chain_complete_list = {
	complete_items = {
		"lsp",
		"buffers",
	},
	mode = {
		"<c-p>",
		"<c-n>",
	},
}
-- hide some of the completion messages -- :h shortmess gives an explanation as
-- to why.
vim.cmd [[set shortmess+=c]]
-- }}}
-- =============================================================================
-- {{{ Commands
-- =============================================================================
-- Highlight on yank
vim.api.nvim_exec(
	[[
		augroup YankHighlight
			autocmd!
			autocmd TextYankPost * silent! lua vim.highlight.on_yank()
		augroup end
	]],
	false
)
-- remove trailing whitespaces
vim.cmd [[autocmd BufWritePre * %s/\s\+$//e]]
-- remove trailing newline
vim.cmd [[autocmd BufWritePre * %s/\n\+\%$//e]]

-- set wrap for specific filetypes *only*
vim.api.nvim_exec(
	[[
		augroup WrapLineInProseFiles
			autocmd!
			autocmd FileType md setlocal wrap
		augroup END
	]],
	false
)
-- }}}
-- =============================================================================
-- {{{ Keymaps
-- =============================================================================
-- don't break across lines, thanx:
-- stylua: ignore start
-- Remap space as leader key
vim.keymap.set( "", "<Space>", "<Nop>")
vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- Copy/pasting help
vim.keymap.set("v", [[<Leader>y]], [["+y]], { desc = "Copy to system clipboard" })
vim.keymap.set("v", [[<Leader>p]], [["+p]], { desc = "Paste contents of system clipboard below" })
vim.keymap.set("v", [[<Leader>P]], [["+P]], { desc = "Paste contents of system clipboard above" })
-- A few commands for quickly accessing and saving Neovim config
vim.keymap.set("n", [[<Leader>ve]], [[:e $MYVIMRC<Cr>]], { desc = "Edit Neovim's init.lua" })
vim.keymap.set("n", [[<Leader>vE]], [[:view $MYVIMRC<Cr>]], { desc = "Open Neovim's init.lua in read-only mode" })
vim.keymap.set("n", [[<Leader>vs]], [[:w<Cr> :luafile $MYVIMRC<Cr>]], { desc = "Save and reload Neovim's init.lua file" })
vim.keymap.set("n", [[<Leader>vx]], [[<Cmd>lua require("plugins.telescope").find_config_files()<CR>]], { desc = "Telescope into Neovim's config directory" })
-- keep the cursor in the same place when using n, n and j so it does't go radge
-- and jump around the screen
-- vim.keymap.set("n", "nzzzv", "n")
-- vim.keymap.set("n", "nzzzv", "n")
-- vim.keymap.set("n", "mzj`z", "j")
-- Telescope mappings
vim.keymap.set("n", "<Leader>ff", [[<Cmd>lua require("plugins.telescope").find_files()<Cr>]], { desc = "Telescope files in cwd" })
vim.keymap.set("n", "<Leader>fg", [[<Cmd>lua require("plugins.telescope").live_grep()<Cr>]], { desc = "Grep files in cwd" })
vim.keymap.set("n", "<Leader><Space>", [[<Cmd>lua require("plugins.telescope").buffers()<Cr>]], { desc = "Show currently open buffers in window" })
vim.keymap.set("n", "<Leader>fh", [[<Cmd>lua require("plugins.telescope").help_tags()<Cr>]], { desc = "Search [n]vim help tags" })
vim.keymap.set("n", "<Leader>fo", [[<Cmd>lua require("plugins.telescope").recent_files()<Cr>]], { desc = "List recently opened files" })
vim.keymap.set("n", "<Leader>fp", [[<Cmd>lua require("plugins.telescope").projects()<Cr>]], { desc = "List projects" })
vim.keymap.set("n", "<Leader>fb", [[<Cmd>lua require("plugins.telescope").file_browser()<Cr>]], { desc = "Browse files in a popup" })
-- stylua: ignore end
-- =============================================================================
-- }}}
-- =============================================================================
-- {{{ Additional functionality not covered above
-- =============================================================================
-- Conveniences for netrw. If I move this to a file and `require` it, everything
-- fucks up, so here it is. Mainly `Vex` related:
-- TODO: If I use % to create a new file, it opens the file in the netrw window.
-- I don't want this to happen, I want it to open in the previous window, *ie*
-- have identical behaviour to opening an existing file. How do I do this?
-- That banner doesn't seem very useful. If I can pluck out details of it might
-- be, but just hide it for now by default.
vim.g.netrw_banner = 0
-- open files in previous window by default.
vim.g.netrw_browse_split = 4
-- NOTE: controlled by `a`, but default hidden files to "show all", I normally
-- want to see dotfiles etc.
vim.g.netrw_hide = 0
-- 1 is "keep current dir immune from the browsing dir", 0 keeps the current dir
-- the same as the browsing dir. 1 is the default, but I _think_ I'm going to
-- want this toggleable.
vim.g.netrw_keepdir = 0
-- set the default list style to "tree"
vim.g.netrw_liststyle = 3
vim.g.netrw_altv = 1
-- <tab> map supporting shrinking/expanding a window enabled
vim.g.netrw_usetab = 1
vim.g.netrw_winsize = 25
vim.g.NetrwTopLvlMenu = "Vex"

function ToggleNetrw()
	if vim.g.NetrwIsOpen then
		local i = vim.fn.bufnr "$"
		while i >= 1 do
			if vim.fn.getbufvar(i, "&filetype") == "netrw" then
				vim.cmd("bwipeout" .. i)
				break
			end
			i = i - 1
		end
		vim.g.NetrwIsOpen = false
	else
		vim.g.NetrwIsOpen = true
		vim.cmd "Vexplore"
	end
end

vim.keymap.set("n", "<C-n>", [[:lua ToggleNetrw()<CR>]])

vim.cmd [[
	augroup AutoDeleteNetrwHiddenBuffers
		autocmd!
		autocmd FileType netrw setlocal bufhidden=wipe
	augroup END
]]
