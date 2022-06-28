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
-- https://github.com/wimstefan/dotfiles/blob/master/config/nvim/init.lua
-- https://github.com/ViRu-ThE-ViRuS/configs/blob/master/nvim/init.lua
-- https://www.littlehart.net/atthekeyboard/2021/11/12/grumpy-nvim-setup/
-- https://vonheikemen.github.io/devlog/tools/configuring-neovim-using-lua/
-- =============================================================================
-- Utilities/per-setup
-- =============================================================================
local nvim_dir = os.getenv("HOME") .. "/.config/nvim"

Reload = function(...)
	return require("plenary.reload").reload_module(...)
end

R = function (name)
	Reload(name)
	return require(name)
end

P = function (v)
	print(vim.inspect(v))
	return v
end

-- NOTE: Colorizer.lua is doing something weird and termguicolors is showing as not being set.
-- In an attempt to get around this, set the option prior to the plugin loading logic.
vim.o.termguicolors = true
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
	use { "nvim-treesitter/playground" }
	-- The theme itself is built using Lush. It has a nice DSL that allows for live updating, and there's a build tool that can then generate output for loads of other things (eg, creating a terminal theme). The downside is that to make use of it, the theme needs to be a plugin, so that's stored at `./sutor_theme.nvim/`. To get live updating when developing, open a buffer with the theme file and run `:Lushify<Cr>`
	use { "rktjmp/lush.nvim" }
	use {
		"~/.config/nvim/sutor_theme.nvim",
		as = "colorscheme",
	}
	use { "cocopon/iceberg.vim"}
	use { "EdenEast/nightfox.nvim", tag = "v1.0.0" }
	-- Which-key pops up a little UI on keypresses in normal/visual modes to show the available options. Not necessary, just nice-to-have.
	use { "folke/which-key.nvim" }
	-- Startup screen: a bit pointless but I like having it there.
	use { "goolord/alpha-nvim" }
	use { "kyazdani42/nvim-web-devicons" }
	-- Editorconfig keeps text editor config consistent across machines and means I don't have to specify the tab/space size in the vim config.
	use { "editorconfig/editorconfig-vim" }
	-- use { "gpanders/editorconfig.nvim" }
	-- Comment makes it easy to add/remove language-specific comments.
	use { "numToStr/Comment.nvim" }
	-- Colorizer automatically highlights Hex/RGB/etc colours; too useful for CSS work to leave out.
	use { "norcalli/nvim-colorizer.lua" }
	-- Treesitter + some treesitter-powered extras for syntax highlighting. This requires tree-sitter be installed on the machine.
	use { "nvim-treesitter/nvim-treesitter" }
	use { "nvim-treesitter/nvim-tree-docs" }
	-- REVIEW: this adds some virtual text showing the current context after the
	-- current block, function etc. This may be annoying, but should be v helpful
	-- in larger codebases.
	use	{ "haringsrob/nvim_context_vt" }
	-- Language server functionality. `nvim-lsp-installer` is a companion to `lspconfig`: it provides utilities for [auto] installing language servers (not *necessarily* a great idea, but I'll stick with it for now).
	-- A few language servers have additional requirements. In this case, the `schemastore` plugin is used to pull in JSON/YAML schemas for the JSON language server.
	use { "neovim/nvim-lspconfig" }
	use { "williamboman/nvim-lsp-installer" }
	use { "mfussenegger/nvim-dap" }
	use { "b0o/schemastore.nvim" }
	use { "simrat39/rust-tools.nvim" }
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
	use { "ranjithshegde/orgWiki.nvim" }
	-- REVIEW: in-development plugins
	use { nvim_dir .. "/plugin-dev/sutor_keyfob.nvim" }
	-- Finally, sync Packer if it's been bootstrapped and close off the setup function.
	if packer_bootstrap then
    require('packer').sync()
  end
end)

-- }}}
-- =============================================================================
-- {{{ Theme
-- =============================================================================
vim.env.nvim_tui_enable_true_color = 1
-- vim.cmd [[ colorscheme iceberg]]
vim.cmd [[colorscheme nightfox]]
-- vim.cmd [[ colorscheme sutor_dark]]
-- }}}
-- =============================================================================
-- {{{ Options
-- ============================================================================
-- ----------------------------------------------------------------------------
-- global options
-- ----------------------------------------------------------------------------

-- enable filetype.lua (opt-in, does not yet completely match all of the filetypes covered by filetype.vim)
vim.g.do_filetype_lua = 1
-- disable filetype.vim
vim.g.did_load_filetypes = 0
-- additional filetype detection
vim.filetype.add({
  extension = {
    conf = "config",
    config = "config",
		profile = "sh",
		workrc = "sh",
  },
  pattern = {
    ["tsconfig*.json"] = "jsonc",
		["Brewfile"] = "ruby",
  },
});

-- tab title
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
-- Keep undo history across sessions by storing it in a file
os.execute("mkdir -p " .. os.getenv("HOME") .. "/.config/nvim/undo")
vim.o.undodir = os.getenv("HOME") .. "/.config/nvim/undo/"
vim.o.undofile = true
vim.o.undolevels = 1000
vim.o.undoreload = 10000
-- show substitution live as I type. Yes pls
vim.o.inccommand = "nosplit"
-- hide some of the completion messages -- :h shortmess gives an explanation as to why
vim.o.shortmess = vim.o.shortmess .. "c"
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
		close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
	},
	severity_sort = true,
	update_in_insert = true,
}
-- ...and add the autocommands to allow that to show
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
	pattern = "*",
	callback = function ()
		vim.diagnostic.open_float(nil, { focus = false, scope = "cursor" })
	end,
	desc = "Open a diagnostic popup under the cursor",
})
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
augroup("FiletypeBasedAdjustments", { clear = true })

local nvim_config_filepaths = {
	os.getenv("HOME") .. "/.config/nvim/init.lua",
	os.getenv("HOME") .. "/.config/nvim/lua/plugins/*.lua",
	".nvimrc.lua"
}

-- FIXME: this fails with an error, don't have time to investigate atm, uncomment to see error
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

-- REVIEW: WHAY DO I NEED TO DO THIS?!
autocmd({ "BufEnter" }, {
	group = "FiletypeBasedAdjustments",
	pattern = { "*.html", "*.heex" },
	callback = function ()
		vim.bo.shiftwidth = 2
		vim.bo.tabstop = 2
	end,
	desc = "Force 2 spaces for tabs for HTML. WHY???"
})
-- }}}
-- =============================================================================
-- {{{ Keymaps
-- =============================================================================
-- Remap space as leader key
vim.keymap.set( "", "<Space>", "<Nop>")
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- stylua: ignore start
local keymaps = {
	-- Copy/paste help
	["Copy to system clipboard"] = { mode = "v", lhs = "y", rhs = [["+y]] },
	["Paste contents of system clipboard below"] = { mode = "v", lhs = "p", rhs = [["+p]] },
	["Paste contents of system clipboard above"] = { mode = "v", lhs = "P", rhs = [["+P]] },
	-- Fuzzy find
	["Find files in cwd"] = { mode = "n", lhs = "ff", rhs = [[<Cmd>lua require("telescope.builtin").find_files()<Cr>]] },
	["Grep files in cwd"] = { mode = "n", lhs = "fg", rhs = [[<Cmd>lua require("telescope.builtin").live_grep()<Cr>]] },
	["List open buffers"] = { mode = "n", lhs = "f<Space>", rhs = [[<Cmd>lua require("telescope.builtin").buffers()<Cr>]] },
	["Search nvim help tags"] = { mode = "n", lhs = "fh", rhs = [[<Cmd>lua require("telescope.builtin").help_tags()<Cr>]]},
	["List recently opened files"] = { mode = "n", lhs = "fo", rhs = [[<Cmd>lua require("telescope.builtin").oldfiles()<Cr>]] },
	["List projects"] = { mode = "n", lhs = "fp", rhs = [[<Cmd>lua require("telescope").extensions.project.project()<Cr>]] },
	["Browse files in cwd"] = { mode = "n", lhs = "fb", rhs = [[<Cmd>lua require("telescope").extensions.file_browser.file_browser()<Cr>]] },
	["List key mappings"] = { mode = "n", lhs = "fm", rhs = [[<Cmd>lua require("telescope.builtin").keymaps()<Cr>]] },
	-- A few commands for quickly accessing and saving Neovim config
	["Edit Neovim's init.lua"] = { mode = "n", lhs = "ve", rhs = [[:e $MYVIMRC<Cr>]] },
	["Open Neovim's init.lua in read-only mode"] = { mode = "n", lhs = "vE", rhs = [[:view $MYVIMRC<Cr>]] },
	["Save and reload Neovim's init.lua file"] = { mode = "n", lhs = "vs", rhs = [[:w<Cr> :luafile $MYVIMRC<Cr>]] },
	["Save current file and source it"] = { mode = "n", lhs = "vw", rhs = ":w<Cr> :source %<Cr>" },
	["List file/s in Neovim's config directory"] = { mode = "n", lhs = "vx", rhs = function() require("telescope.builtin").find_files({ hidden = true, search_dirs = { vim.env.HOME .. "/.config/nvim" } }) end },
	-- Toggles
	["Toggle word wrap"] = { mode = "n", lhs = "tw", rhs = [[<Cmd>ToggleWordWrap<Cr>]] },
	["Toggle HEX/RGB/etc colour highlighting in buffer"] = { mode = "n", lhs = "tc", rhs = [[<Cmd>ColorizerToggle<Cr>]] },
}
-- stylua: ignore end

for desc, mapping in pairs(keymaps) do
	vim.keymap.set(mapping.mode, "<Leader>" .. mapping.lhs, mapping.rhs, { desc = desc })
end
-- =============================================================================
-- }}}
-- =============================================================================
-- {{{ Plugin setup
-- =============================================================================
-- for plugins that require setup, delegate to seperate modules:
require("plugin-setup/telescope")
require("plugin-setup/cmp")
require("plugin-setup/comment")
require("plugin-setup/lsp")
require("plugin-setup/luasnip")
require("plugin-setup/org")
require("plugin-setup/treesitter")
require("plugin-setup/alpha")
require("plugin-setup/colorizer")
require("plugin-setup/which-key")
-- }}}
