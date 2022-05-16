-- vim:fileencoding=utf-8:foldmethod=marker
-- =============================================================================
-- Dan Couper
-- danielcouper.sutor@gmail.com
-- https://github.com/DanCouper
-- NOTE: Requires v7+ of Nvim

-- =============================================================================
-- Prior Art
-- =============================================================================
-- https://github.com/mjlbach/defaults.nvim
-- https://github.com/neovim/nvim-lspconfig/wiki
-- https://github.com/mukeshsoni/config/blob/master/.config/nvim/init.lua
-- https://github.com/evantravers/dotfiles/blob/master/nvim/.config/nvim/init.lua
-- https://neovim.discourse.group/t/the-300-line-init-lua-challenge/227
-- https://github.com/nanotee/nvim-lua-guide/
-- https://gist.github.com/ammarnajjar/3bdd9236cf62513a79db20520ba8467d
-- https://github.com/tjdevries/config_manager/blob/master/xdg_config/nvim/lua/tj/plugins.lua
-- https://github.com/creativenull/dotfiles (see particularly the way plugin setup works)
-- =============================================================================
-- Utilities
-- =============================================================================
-- REVIEW: So, if I use this instead of the standard `require` it'll make sure my modules are executed everytime I source $MYVIMRC.
-- cribbed from https://www.reddit.com/r/neovim/comments/um3epn/comment/i7zf32l/?utm_source=share&utm_medium=web2x&context=3
-- Issue is that if used for LSP stuff (for example) it goes into a loop and keeps adding clients over and over.
local load = function(mod)
  package.loaded[mod] = nil
  return require(mod)
end
-- =============================================================================
-- {{{ Plugins
-- =============================================================================
-- [Packer](https://github.com/wbthomason/packer.nvim) is used to manage plugins. Because some options, commands and keymaps are based on certain plugins being installed, this is the first item configured.
-- Packer itself will automatically self-install and set itself up on any machine this configuration is cloned to -- this is copied directly from [the Packer README](https://github.com/wbthomason/packer.nvim#bootstrapping).
-- Automatically ensure that Packer installs itself if it isn't already present.
local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
local packer_bootstrap = nil

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  packer_bootstrap = vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end
-- ...then define plugins
require("packer").startup(function()
	use { "wbthomason/packer.nvim" }
	-- Useful utility/profiling/debugging tools for Neovim itself:
	use { "nvim-lua/plenary.nvim" }
	use { "dstein64/vim-startuptime" }
	-- The theme itself is built using Lush. It has a nice DSL that allows for live updating, and there's a build tool that can then generate output for loads of other things (eg, creating a terminal theme). The downside is that to make use of it, the theme needs to be a plugin, so that's stored at `./sutor_theme.nvim/`. To get live updating when developing, open a buffer with the theme file and run `:Lushify<Cr>`
	use { "rktjmp/lush.nvim" }
	use {
		"~/.config/nvim/sutor_theme.nvim",
		as = "colorscheme",
	}
	-- Which-key pops up a little UI on keypresses in normal/visual modes to show the available options. Not necessary, just nice-to-have.
	use { "folke/which-key.nvim" }
	-- Startup screen: a bit pointless but I like having it there.
	use { "goolord/alpha-nvim" }
	use { "kyazdani42/nvim-web-devicons" }
	-- Editorconfig keeps text editor config consistent across machines and means I don't have to specify the tab/space size in the vim config.
	use { "editorconfig/editorconfig-vim" }
	-- Comment makes it easy to add/remove language-specific comments.
	use { "numToStr/Comment.nvim" }
	-- Colorizer automatically highlights Hex/RGB/etc colours; too useful for CSS work to leave out.
	use { "norcalli/nvim-colorizer.lua" }
	-- Treesitter + some treesitter-powered extras for syntax highlighting. This requires tree-sitter be installed on the machine.
	use {
		"nvim-treesitter/nvim-treesitter",
		requires = {
			"nvim-treesitter/nvim-tree-docs",
			-- REVIEW: this adds some virtual text showing the current context after the
			-- current block, function etc. This may be annoying, but should be v helpful
			-- in larger codebases.
			"haringsrob/nvim_context_vt",
		}
	}
	-- Language server functionality. `nvim-lsp-installer` is a companion to `lspconfig`: it provides utilities for [auto] installing language servers (not *necessarily* a great idea, but I'll stick with it for now).
	-- A few language servers have additional requirements. In this case, the `schemastore` plugin is used to pull in JSON/YAML schemas for the JSON language server.
	use { "neovim/nvim-lspconfig" }
	use { "williamboman/nvim-lsp-installer" }
	use { "b0o/schemastore.nvim" }
	-- Completions & snippets are a bit of a faff to set up; cmp is the core autocomplete plugin, but that needs a load of other stuff to cover a variety of autocomplete needs.
	use {
		"hrsh7th/nvim-cmp",
		requires = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-nvim-lua",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"saadparwaiz1/cmp_luasnip",
			"onsails/lspkind-nvim",
			"l3mon4d3/luasnip",
			"rafamadriz/friendly-snippets",
		}
	}
	-- Telescope is used to find stuff.
	use {
		"nvim-telescope/telescope.nvim",
		requires = {
			"nvim-telescope/telescope-project.nvim",
			"nvim-telescope/telescope-file-browser.nvim",
		}
	}
	-- Orgmode is used to organise stuff. Not a patch on the Emacs original it would seem, but necessary.
	-- NOTE: Orgzly should be installed on any mobile devices (and everything should be synced between machines).
	use { "nvim-orgmode/orgmode"}

	-- Finally, sync Packer if it's been bootstrapped and close off the setup function.
	if packer_bootstrap then
    require('packer').sync()
  end
end)

-- for plugins that require setup, delegate to seperate modules:
require("plugin-setup/cmp")
require("plugin-setup/comment")
require("plugin-setup/lsp")
require("plugin-setup/luasnip")
require("plugin-setup/org")
require("plugin-setup/telescope")
require("plugin-setup/treesitter")
require("plugin-setup/which-key")
require("plugin-setup/alpha")
require("plugin-setup/colorizer")
-- }}}
-- =============================================================================
-- {{{ Theme
-- =============================================================================
-- Need termguicolors set to get owt fancy
vim.o.termguicolors = true
vim.env.nvim_tui_enable_true_color = 1
-- require("sutor-dark-theme")
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
	float = {
		border = "single",
		severity_sort = true,
		close_events = { 'BufLeave', 'CursorMoved', 'InsertEnter', 'FocusLost' },
	},
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
local usercmd = vim.api.nvim_create_user_command
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

usercmd("ToggleWordWrap", "set wrap!", {});

augroup("Configs", { clear = true })
augroup("BufferUIEffects", { clear = true })
augroup("FileCleanupOnSave", { clear = true })

local nvim_config_filepaths = {
	os.getenv("HOME") .. "/.config/nvim/init.lua",
	os.getenv("HOME") .. "/.config/nvim/lua/plugins/*.lua",
	".nvimrc.lua"
}

-- autocmd({ "BufWritePost" }, {
-- 	group = "Configs",
-- 	pattern = nvim_config_filepaths,
-- 	callback = function() vim.cmd("PackerCompile") end,
-- 	desc = "Ensure all plugins are up-to-date when any Neovim config files are saved",
-- })

autocmd({ "BufWritePost" }, {
    group = "Configs",
    pattern = nvim_config_filepaths,
    command = "source $MYVIMRC",
		desc = "Source Neovim config files when they are saved.",
})

autocmd({ "TextYankPost" }, {
	group = "BufferUIEffects",
	pattern = "*",
	callback = function() vim.highlight.on_yank({ on_visual = true }) end,
	desc = "Highlight on yank",
})

autocmd({ "BufNewFile", "BufRead" }, {
	pattern = "tsconfig*.json",
	callback = function()
			vim.bo.filetype = "jsonc"
	end,
	desc = "Set perceived filetype of tsconfig files to jsonc",
})

autocmd({ "BufWritePre" }, {
	group = "FileCleanupOnSave",
	pattern = "*",
	command = [[%s/\s\+$//e]],
	desc = "Remove trailing whitespace"
})

autocmd({ "BufWritePre" }, {
	group = "FileCleanupOnSave",
	pattern = "*",
	command = [[%s/\n\+\%$//e]],
	desc = "Remove trailing newline"
})
-- }}}
-- =============================================================================
-- {{{ Keymaps
-- =============================================================================
local keymap = vim.keymap.set
-- Remap space as leader key
keymap( "", "<Space>", "<Nop>")
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- stylua: ignore start
local leader_vmaps = {
	-- Copy/pasting help
	["y"] = { cmd = [["+y]], desc = "Copy to system clipboard" },
	["p"] = { cmd = [["+p]], desc = "Paste contents of system clipboard below" },
	["P"] = { cmd = [["+P]], desc = "Paste contents of system clipboard above" },
}

local leader_nmaps = {
	-- A few commands for quickly accessing and saving Neovim config
	["ve"] = { cmd = [[:e $MYVIMRC<Cr>]], desc = "Edit Neovim's init.lua" },
	["vE"] = { cmd = [[:view $MYVIMRC<Cr>]], desc = "Open Neovim's init.lua in read-only mode" },
	["vs"] = { cmd = [[:w<Cr> :luafile $MYVIMRC<Cr>]], desc = "Save and reload Neovim's init.lua file" },
	["vx"] = { cmd = require("plugin-setup.telescope").find_config_files, desc = "Telescope into Neovim's config directory" },
	-- require("plugin-setup.telescope") mappings
	["ff"] = { cmd = require("plugin-setup.telescope").find_files, desc = "Telescope files in cwd" },
	["fg"] = { cmd = require("plugin-setup.telescope").live_grep, desc = "Grep files in cwd" },
	["<Space>"] = { cmd = require("plugin-setup.telescope").buffers, desc = "Show currently open buffers in window" },
	["fh"] = { cmd = require("plugin-setup.telescope").help_tags, desc = "Search [n]vim help tags" },
	["fo"] = { cmd = require("plugin-setup.telescope").recent_files, desc = "List recently opened files" },
	["fp"] = { cmd = require("plugin-setup.telescope").projects, desc = "List projects" },
	["fb"] = { cmd = require("plugin-setup.telescope").file_browser, desc = "Browse files in a popup" },
	-- Toggles
	["tw"] = { cmd = [[<Cmd>ToggleWordWrap<Cr>]], desc = "Toggle word wrap" },
	["tc"] = { cmd = [[<Cmd>ColorizerToggle<Cr>]], desc = "Toggle HEX/RGB/etc colour highlighting in buffer" },
}
-- stylua: ignore end

for mapping, conf in pairs(leader_vmaps) do
	keymap("v", "<Leader>" .. mapping, conf.cmd, { desc = conf.desc })
end

for mapping, conf in pairs(leader_nmaps) do
	keymap("n", "<Leader>" .. mapping, conf.cmd, { desc = conf.desc })
end
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
