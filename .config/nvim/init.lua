-- vim:fileencoding=utf-8:foldmethod=marker
-- ============================================================================
-- Dan Couper
-- danielcouper.sutor@gmail.com
-- https://github.com/DanCouper
--
-- NOTE: Probably requires nvim HEAD (currently on 0.6 testing releases)
-- NOTE: Cribbed from a number of sources, in particular:
--
--       - https://github.com/mjlbach/defaults.nvim
--       - https://github.com/neovim/nvim-lspconfig/wiki
--       - https://github.com/mukeshsoni/config/blob/master/.config/nvim/init.lua
--       - https://github.com/evantravers/dotfiles/blob/master/nvim/.config/nvim/init.lua
--       - https://neovim.discourse.group/t/the-300-line-init-lua-challenge/227
--       - https://github.com/nanotee/nvim-lua-guide/
--			 - https://gist.github.com/ammarnajjar/3bdd9236cf62513a79db20520ba8467d
-- ============================================================================
-- {{{ Initial setup and general options
-- ============================================================================
-- Remap space as leader key
vim.api.nvim_set_keymap("", "<Space>", "<Nop>", { noremap = true, silent = true })
vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- }}}
-- ============================================================================
-- {{{ Plugins
-- ============================================================================
-- Automatically ensure that Packer installs itself if it isn't already present...
local install_path = vim.fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
	vim.fn.execute("!git clone https://github.com/wbthomason/packer.nvim " .. install_path)
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
require("packer").startup({
	function()
  -- ---------------------------------------------------------------------------
	-- Packer {{{
	-- desc: Package manager written in Lua. Add packages here. Save. Run
	--			 `:source %`. Run `:PackerInstall`. To update packages, run
	--			 `:PackerUpdate`. NOTE: Is this necessarily needed? It makes things
	--			 easier, sure, but with Packer I am installing into a global cache.
	--			 Whereas Plug installs plugins nicely into the local config folder.
	-- docs: https://github.com/wbthomason/packer.nvim
	use "wbthomason/packer.nvim"
	-- }}}
  -- ---------------------------------------------------------------------------
	-- Plenary {{{
	-- desc: Useful Lua functions for NVim
	-- docs: https://github.com/nvim-lua/plenary.nvim
	use "nvim-lua/plenary.nvim"
	-- }}}
  -- ---------------------------------------------------------------------------
	-- Treesitter {{{
	-- desc: syntax parsing using the tree-sitter library. Obseletes most previous
	--       syntax highlighting plugins IN THEORY. 0.6 will, when complete, include this out
	--       of the box, but for now need the plugin.
	--       NOTE: setting it to auto run update. Otherwise need to ensure that
	--       treesitter packages are installed for each language, treesitter itself
	--       won't do anything otherwise.
	-- docs: https://github.com/nvim-treesitter/nvim-treesitter
	use {
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
		config = function ()
			require("nvim-treesitter.configs").setup {
				ensure_installed = "maintained",
				highlight = {
					enable = true,
				},
			}
		end
	}
	-- }}}
  -- ---------------------------------------------------------------------------
	-- Telescope {{{
	-- desc: Magic finder thing. Provides a UI to select things (files, grep
	--       results, open buffers...)
	-- docs: https://github.com/nvim-telescope/telescope.nvim
	use {
		"nvim-telescope/telescope.nvim",
		requires = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-project.nvim"
		},
		config = function ()
			require('telescope').load_extension('projects')
			require("telescope").setup {
				defaults = {
					mappings = {
					i = {
							["<C-u>"] = false,
							["<C-d>"] = "delete_buffer",
						},
					},
				},
			}
		end
	}
	-- }}}
  -- ---------------------------------------------------------------------------
	-- nvim-lspconfig {{{
  -- desc: nvim v0.5+ comes with a language server built-in. This plugin just
 	--			 contains common configs to make things easier.
  -- docs: https://github.com/neovim/nvim-lspconfig
	use {
		"neovim/nvim-lspconfig",
		requires = {
			"williamboman/nvim-lsp-installer",
			"simrat39/rust-tools.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = require("lsp_config").config()
	}
	-- }}}
  -- ---------------------------------------------------------------------------
	-- nvim-lsp-installer {{{
  -- desc: Companion to lspconfig. Provides utilities for [auto] installing
	--			 language servers.
  -- docs: https://github.com/williamboman/nvim-lsp-installer
	use "williamboman/nvim-lsp-installer"
	-- }}}
  -- ---------------------------------------------------------------------------
	-- rust-tools.nvim {{{
  -- desc: Adds some extra functionality over Rust Analyzer & does the setup yo.
	-- docs: https://github.com/simrat39/rust-tools.nvim
	use {
		"simrat39/rust-tools.nvim",
		require = {
			"nvim-lua/popup.nvim",
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
		},
		-- config = function ()
		-- 	require("rust-tools").setup {
		-- 		tools = {
		-- 			autoSetHints = true,
		-- 			hover_with_actions = true,
		-- 			inlay_hints = {
		-- 				show_parameter_hints = false,
		-- 				parameter_hints_prefix = "",
		-- 				other_hints_prefix = "",
		-- 			},
		-- 		},
		-- 		-- all the opts to send to nvim-lspconfig
		-- 		-- these override the defaults set by rust-tools.nvim
		-- 		-- see https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#rust_analyzer
		-- 		server = {
		-- 			-- on_attach is a callback called when the language server attachs to the buffer
		-- 			-- on_attach = on_attach,
		-- 			settings = {
		-- 				-- to enable rust-analyzer settings visit:
		-- 				-- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
		-- 				["rust-analyzer"] = {
		-- 					-- enable clippy on save
		-- 					checkOnSave = {
		-- 						command = "clippy"
		-- 					},
		-- 				}
		-- 			}
		-- 		},
		-- 	}
		-- end,
	}
	-- }}}
  -- ---------------------------------------------------------------------------
	-- Completion {{{
	-- desc: autocompletions
	-- docs: https://github.com/hrsh7th/nvim-cmp
	use {
		"hrsh7th/nvim-cmp",
		requires = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"saadparwaiz1/cmp_luasnip",
			"onsails/lspkind-nvim",
		},
		config = function ()
			-- This works in tandem with the LSP stuff
			local cmp = require("cmp")
			local lspkind = require("lspkind")
			cmp.setup({
				completion = {
					completeopt = "menu,menuone,noinsert",
				},
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				mapping = {
					["<C-d>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.close(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 's' }),
				},
				sources = {
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "orgmode" },
					{ name = "path" },
				},
				formatting = {
					format = lspkind.cmp_format(),
				},
				experimental = {
					native_menu = false,
					ghost_text = false,
				}
			})
		end
	}
	use {
		"L3MON4D3/LuaSnip",
		config = function ()
			require "luasnip/loaders/from_vscode".lazy_load()
		end
	}

	use {
		"rafamadriz/friendly-snippets"
	}
	-- }}}
  -- ---------------------------------------------------------------------------
	-- Commentary {{{
	-- desc: Easy commenting.
	-- docs: https://github.com/tpope/vim-commentary
	use {
		"tpope/vim-commentary",
	}
	-- }}}
  -- ---------------------------------------------------------------------------
	-- Unimpaired {{{
	-- desc: Easy movement.
	-- docs: https://github.com/tpope/vim-unimpaired
	use "tpope/vim-unimpaired"
	-- }}}
  -- ---------------------------------------------------------------------------
	-- Editorconfig {{{
	-- desc: Editorconfig keeps text editor config consistent across machines.
  -- docs: https://github.com/editorconfig/editorconfig-vim
	use {
		"editorconfig/editorconfig-vim",
	}
	-- }}}
  -- ---------------------------------------------------------------------------
	-- Which-key {{{
	-- desc: Displays a popup with possible key bindings of the command just typed.
	--			 What Spacemacs does, basically. NOTE: this is designed to build on,
	--			 to document my keybindings as I add them.
  -- docs: https://github.com/folke/which-key.nvim
	use {
		"folke/which-key.nvim",
		config = require("key_mappings").config()
	}
	-- }}}
  -- ---------------------------------------------------------------------------
	-- nvim-tree {{{
  -- desc: honestly, I tried to stick with just telescope + just use Explorer
	--			 when necessary, but it's too useful having a nice file explorer
	--			 available.
  -- docs: https://github.com/kyazdani42/nvim-tree.lua
	use {
    "kyazdani42/nvim-tree.lua",
    requires = "kyazdani42/nvim-web-devicons",
		config = function ()
			-- NOTE: global definitions need to go *before* setup
			-- NOTE: keep an eye on updates for nvim-tree, globals are gradually being migrated
			--       to the setup function config, so eventually should be able to remove all
			--       these.
			vim.g.nvim_tree_auto_ignore_ft = {
				"alpha",
			}
			-- this option shows indent markers when folders are open
			vim.g.nvim_tree_indent_markers = 1
			-- will enable file highlight for git attributes (can be used without the icons).
			vim.g.nvim_tree_git_hl = 1
			-- will enable folder and file icon highlight for opened files/directories.
			vim.g.nvim_tree_highlight_opened_files = 1
			-- append a trailing slash to folder names
			vim.g.nvim_tree_add_trailing = 1
			-- change cwd of nvim-tree to that of new buffer's when opening nvim-tree.
			vim.g.nvim_tree_respect_buf_cwd = 1
			vim.g.nvim_tree_disable_window_picker = 1

			require("nvim-tree").setup {
				auto_close = true,
				hijack_cursor = true,
				nvim_tree_ignore = {
					--".git",
					"node_modules",
					".cache"
				},
				tree_follow = 1,
				tree_follow_update_path = 1,
				update_cwd = true,
				update_focused_file = {
					enable = true,
					update_cwd = true,
				},
				view = {
					width = 40
				}
			}
		end
	}
	-- }}}
  -- ---------------------------------------------------------------------------
	-- Persistence {{{
  -- desc: Persists sessions. This is built into Vim, but is faffy. *Not* having
	--       this feature automagically available without having to think about
	--       it turns out to be very annoying.
  -- docs: https://github.com/folke/persistence.nvim
	use{
		"folke/persistence.nvim",
		-- this will only start session saving when an actual file was opened:
		event = "BufReadPre",
		module = "persistence",
		config = function()
			require("persistence").setup()
		end,
	}
	-- }}}
  -- ---------------------------------------------------------------------------
	-- Project {{{
  -- desc: Like persistence, and ability to have and then easily access projects
	--       turns out to be extremely useful.
  -- docs: https://github.com/ahmedkhalf/project.nvim
	use {
		"ahmedkhalf/project.nvim",
		config = function()
			require("project_nvim").setup {
				-- Manual mode doesn't automatically change your root directory, so you have
				-- the option to manually do so using `:ProjectRoot` command.
				manual_mode = false,
				-- Methods of detecting the root directory. **"lsp"** uses the native neovim
				-- lsp, while **"pattern"** uses vim-rooter like glob pattern matching. Here
				-- order matters: if one is not detected, the other is used as fallback. You
				-- can also delete or rearrange the detection methods.
				detection_methods = { "lsp", "pattern" },
				-- All the patterns used to detect root dir, when **"pattern"** is in
				-- detection_methods
				patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json" },
				-- Show hidden files in telescope
				show_hidden = true,
			}
		end
	}
	-- }}}
  -- ---------------------------------------------------------------------------
	-- Iceberg (theme) {{{
	-- desc: Well thought-out theme, not my favourite but author has a phenomenal
	--       presentation on colour schemes that is an inspiration.
	-- docs: https://github.com/cocopon/iceberg.vim
	use "cocopon/iceberg.vim"
	-- }}}
  -- ---------------------------------------------------------------------------
	-- Table mode {{{
	-- desc: a mode for creating ascii tables. Really good!
	-- docs: https://github.com/dhruvasagar/vim-table-mode
	use {
		"dhruvasagar/vim-table-mode"
	}
	-- }}}
  -- ---------------------------------------------------------------------------
	-- Indent Blankline {{{
	-- desc: adds visual indentation guides to all lines
	-- docs: https://github.com/lukas-reineke/indent-blankline.nvim
	use {
		"lukas-reineke/indent-blankline.nvim",
		config = function()
			vim.opt.list = true
			vim.opt.listchars:append("space:⋅")
			vim.opt.listchars:append("eol:↴")

			require("indent_blankline").setup {
				filetype_exclude = {
					"help",
					"terminal",
					"dashboard",
					"packer",
					"alpha",
				},
				buftype_exclude = {
					"terminal",
				},
				show_current_context = true,
				show_end_of_line = true,
				space_char_blankline = " ",
			}
		end,
	}
	-- }}}
  -- ---------------------------------------------------------------------------
	-- Lualine {{{
	-- desc: I give in, I want a nice status line
	-- docs: https://github.com/nvim-lualine/lualine.nvim
	use {
		"nvim-lualine/lualine.nvim",
		requires = {"kyazdani42/nvim-web-devicons", opt = true},
		config = function ()
			require("lualine").setup {
				options = {
					icons_enabled = true,
					theme = "iceberg_dark",
					component_separators = { left = "", right = ""},
					section_separators = { left = "", right = ""},
				},
				sections = {
					lualine_a = {'mode'},
					lualine_b = {'branch', 'diff', {
						'diagnostics',
						sources={ 'nvim_lsp'}
					}},
					lualine_c = {'filename'},
					lualine_x = {'encoding', 'fileformat', 'filetype'},
					lualine_y = {'progress'},
					lualine_z = {'location'}
				},
				extensions = {"nvim-tree"},
			}
		end,
	}
	-- }}}
  -- ---------------------------------------------------------------------------
	-- Alpha {{{
	-- desc: Nice startup screen. Lua version of startify/dashboard
	-- docs: https://github.com/gooloard/vim-alpha
	use {
		"goolord/alpha-nvim",
    config = function ()
        local alpha = require("alpha")
        local dashboard = require("alpha.themes.dashboard")

        dashboard.section.buttons.val = {
					dashboard.button( "f", "  > Find file", ":cd $HOME | Telescope find_files<CR>"),
					dashboard.button( "r", "  > Recent"   , ":Telescope oldfiles<CR>"),
					dashboard.button( "s", "  > Settings" , ":e $MYVIMRC<CR>"),
					dashboard.button( "p", "↺  > Sync packages", ":PackerSync<CR>"),
					dashboard.button( "q", "  > Quit NVIM", ":qa<CR>"),
					-- TODO: this obvs won't work, how could I make it work?
					-- dashboard.button( "x", "∀  > New strategy", ":lua strategy()<CR>"),
        }
        dashboard.section.footer.val = require("oblique_strategies")()

        alpha.setup(dashboard.opts)
    end,
	}
	-- }}}
  -- ---------------------------------------------------------------------------
	-- Orgmode.nvim {{{
	-- desc: Orgmode, for nvim. Does what it say on the tin.
	-- docs: https://github.com/kristijanhusak/orgmode.nvim
	use {
		'kristijanhusak/orgmode.nvim',
		config = function()
			local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
			parser_config.org = {
				install_info = {
					url = 'https://github.com/milisims/tree-sitter-org',
					revision = 'main',
					files = {'src/parser.c', 'src/scanner.cc'},
				},
				filetype = 'org',
			}

			require'nvim-treesitter.configs'.setup {
				-- If TS highlights are not enabled at all, or disabled via `disable` prop, highlighting will fallback to default Vim syntax highlighting
				highlight = {
					enable = true,
					disable = {'org'}, -- Remove this to use TS highlighter for some of the highlights (Experimental)
					additional_vim_regex_highlighting = {'org'}, -- Required since TS highlighter doesn't support all syntax features (conceal)
				},
				ensure_installed = {'org'}, -- Or run :TSUpdate org
			}

			require('orgmode').setup{
				org_agenda_files = {'~/Dropbox/orgfiles/*', '~/Personal/orgfiles/**/*'},
				org_default_notes_file = '~/Dropbox/orgfiles/refile.org',
			}
		end
	}
	-- }}}
  -- ---------------------------------------------------------------------------
	-- minimap.vim {{{
	-- desc: vim interface for a very nice minimap written in Rust.
	--       I find them extremely useful for big files, especially combined with
	--	     errors being highlighted in said minimap.
	-- docs: https://github.com/wfxr/minimap.vim
	use {
		"wfxr/minimap.vim",
	}
	-- }}}
  -- ---------------------------------------------------------------------------
	-- Copilot {{{
	-- desc: GitHub copilot integration
	-- docs: https://github.com/github/copilot.vim
	use {
		"github/copilot.vim",
		config = function ()
			-- remap copilot completion. I'd like to actually be able to use the tab key
			-- for tabs in insert mode, thanks
			vim.api.nvim_set_keymap("i", "<C-J>", [[:copilot#Accept<CR>]], { noremap = true, silent = true})
			vim.g.copilot_no_tab_map = true
		end
	}
	-- }}}
  -- ---------------------------------------------------------------------------
	-- Fugitive {{{
	-- desc: Git tooling
	-- docs: https://github.com/tpope/vim-fugitive
	use {
		"tpope/vim-fugitive",
	}
	-- }}}
  -- ---------------------------------------------------------------------------
	end,
	config = {
		display = {
			open_fn = require('packer.util').float,
		}
	}
})
-- }}}
-- ============================================================================
-- {{{ Colour Scheme
-- ============================================================================
-- NOTE: order is important here
vim.env.NVIM_TUI_ENABLE_TRUE_COLOR = 1
vim.o.termguicolors = true
vim.cmd [[colorscheme iceberg]]
-- }}}
-- ============================================================================
-- {{{ Options
-- ============================================================================
-- which key to use when confirming completions
vim.g.completion_confirm_key = ""
-- Extra completions stuff
vim.g.completion_matching_strategy_list = {"exact", "substring", "fuzzy"}
vim.g.completion_chain_complete_list = {
	complete_items = {
		"lsp",
		"buffers"
	},
	mode = {
		"<c-p>",
		"<c-n>",
	}
}
-- Markdown syntax highlighting
vim.g.markdown_fenced_languages = {
	"ts=typescript"
}
-- ----------------------------------------------------------------------------
-- Global Options
-- ----------------------------------------------------------------------------
vim.o.title = true
vim.o.titlestring = " %t"
-- Set highlight on search
vim.o.hlsearch = false
-- Enable mouse mode
vim.o.mouse = "a"
-- Highlight current line
vim.o.cursorline = true
-- Show autocomplete menu on <TAB>
vim.o.wildmenu = true
-- Don't redraw as much
vim.o.lazyredraw = true
-- Highlight matching [({})]...
vim.o.showmatch = true
-- ...after 1/10 of a second
vim.o.matchtime = 1
-- At least 3 lines visible at top & bottom of screen unless at start/end. Nice,
-- keeps the cursor in a more sensible position, can see what's above/below.
vim.o.scrolloff = 8
-- Save undo history
-- NOTE: would like some way to *NOT* have this local to the current directory
-- vim.opt.undofile = true
-- Hoy it in the .cache folder
-- vim.opt.undodir = ".nvim-undocache"
--Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true
--Decrease update time
vim.o.updatetime = 250
-- Code folding
-- Adds character space to left of screen. Leave this in regradless because I
-- like a bit of padding and padding is quite difficult to get with Vim so I'll
-- take it where I can
vim.o.foldcolumn = "1"
-- NOTE: maybe turn off for the minute, I think it's possibly more annoying than
-- useful *in general*. For specific filetypes it's extremely useful, so
-- ideally I want it enabled only for them, but I need to actually note which
-- ones during usage.
vim.o.foldenable = true
-- NOTE: however maybe I just want it turned off for this file as it was
-- driving me nuts?? Even just using the markers is driving me nuts.
-- Anyway, maybe I just want it off for this file, in which case, modeline opts:
vim.o.modelines = 2
vim.bo.modeline = true
-- Having now accidentally fatfingered my way through losing a large chunk of
-- work due to fucking swapfile recovery I did not need recovering, turn off
-- the fucking swapfile recovery stuff, YOLO etc.
vim.o.writebackup = false
vim.o.swapfile = false
-- ----------------------------------------------------------------------------
-- Window options
-- ----------------------------------------------------------------------------
-- Make line numbers default
vim.wo.number = true
-- Use relative numbering to make it easier to j and k around
vim.wo.relativenumber = true
-- Show the sign column. The sign column is for stuff like highlighting lines
-- with errors or git integration stuff.
vim.wo.signcolumn = "yes"
-- The colorcolunm is just a visual reminder of the ideal max width. 80 is
-- good for me I think, maybe I'm probably doing something too nested or verbose
-- if I go over it, who knows.
vim.wo.colorcolumn = "80"
-- Turn *off* wordwrap
vim.wo.wrap = false
-- }}}
-- ============================================================================
-- {{{ Commands
-- ============================================================================
vim.cmd("syntax enable")
vim.cmd("filetype plugin indent on")
-- ----------------------------------------------------------------------------
-- Autocommands
-- ----------------------------------------------------------------------------
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
vim.cmd([[autocmd BufWritePre * %s/\s\+$//e]])
-- remove trailing newline
vim.cmd([[autocmd BufWritePre * %s/\n\+\%$//e]])

-- set wrap for specific filetypes *only*
vim.api.nvim_exec(
	[[
		augroup WrapLineInTeXFile
			autocmd!
			autocmd FileType md setlocal wrap
		augroup END
	]],
	false
)
-- }}}
-- ============================================================================
-- Key Mappings {{{
-- ============================================================================
-- Use `jk` instead of <ESC> to exit insert mode.
vim.api.nvim_set_keymap("i", "jk", "<ESC>", { noremap = true })
--Remap for dealing with word wrap
vim.api.nvim_set_keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", { noremap = true, expr = true, silent = true })
vim.api.nvim_set_keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", { noremap = true, expr = true, silent = true })
-- Delete buffer without closing split. If `:bd` is used on a buffer in a split, then
-- it also kills that window. This is IMO v annoying behaviour. `:bp|bd #` was located here:
-- https://stackoverflow.com/a/4468491/1724802
--
-- "The bp command (“buffer previous”) moves us to a different buffer in the current window
-- (bn would work, too), then bd # (“buffer delete” “alternate file”) deletes the buffer we
-- just moved away from. See :help bp, :help bd, and :help alternate-file."
vim.api.nvim_set_keymap("n", "<leader>bd", ":bp|bd #<CR>", { noremap = true, silent = true})
-- Keep the cursor in the same place when usin n, N and J so it does't go radge
-- and jump around the screen
vim.api.nvim_set_keymap("n", "nzzzv", "n", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "Nzzzv", "N", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "mzJ`z", "J", { noremap = true, silent = true })
-- }}}
-- ============================================================================
-- Moar LSP {{{
-- ============================================================================
-- local lsp = require("lspconfig")

-- local on_attach = function(client, bufnr)
-- 	vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

-- 	vim.cmd [[ command! Format execute "lua vim.lsp.buf.formatting()" ]]
-- end

-- -- map buffer local keybindings when the language server attaches
-- local servers = { "tsserver" }

-- for _, server in ipairs(servers) do
--   lsp[server].setup {
--     on_attach = on_attach,
--     capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities()),
--     flags = {
--       debounce_text_changes = 150,
--     }
--   }
-- end

-- tsserver
-- lsp.tsserver.setup {
--     on_attach = function(client, bufnr)
-- 				require("completion").on_attach(client)
--         -- disable tsserver formatting: formatting comes via null-ls
--         client.resolved_capabilities.document_formatting = false
--         client.resolved_capabilities.document_range_formatting = false

-- 				-- define an alias
-- 				vim.cmd("command -buffer Formatting lua vim.lsp.buf.formatting()")
-- 				vim.cmd("command -buffer FormattingSync lua vim.lsp.buf.formatting_sync()")

-- 				-- format on save
-- 				vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()")


--         local ts_utils = require("nvim-lsp-ts-utils")

--         -- defaults
--         ts_utils.setup {
--             debug = false,
--             disable_commands = false,
--             enable_import_on_completion = true,

--             -- import all
--             import_all_timeout = 5000, -- ms
--             import_all_priorities = {
--                 buffers = 4, -- loaded buffer names
--                 buffer_content = 3, -- loaded buffer content
--                 local_files = 2, -- git files or files with relative path markers
--                 same_file = 1, -- add to existing import statement
--             },
--             import_all_scan_buffers = 100,
--             import_all_select_source = false,

--             -- eslint
--             eslint_enable_code_actions = true,
--             eslint_enable_disable_comments = true,
--             eslint_bin = "eslint",
--             eslint_enable_diagnostics = false,
--             eslint_opts = {},

--             -- formatting
--             enable_formatting = false,
--             formatter = "prettier",
--             formatter_opts = {},

--             -- update imports on file move
--             update_imports_on_move = false,
--             require_confirmation_on_move = false,
--             watch_dir = nil,

--             -- filter diagnostics
--             filter_out_diagnostics_by_severity = {},
--             filter_out_diagnostics_by_code = {},
--         }

--         -- required to fix code action ranges and filter diagnostics
--         ts_utils.setup_client(client)

--         -- no default maps, so you may want to define some here
--         local opts = { silent = true }
--         vim.api.nvim_buf_set_keymap(bufnr, "n", "gs", ":TSLspOrganize<CR>", opts)
--         vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", ":TSLspRenameFile<CR>", opts)
--         vim.api.nvim_buf_set_keymap(bufnr, "n", "gi", ":TSLspImportAll<CR>", opts)

--     end
-- }

-- Using a plugin to sort Lua out, that has a slightly different setup:
-- require("nlua.lsp.nvim").setup(lsp, {
--   on_attach = on_attach,
--   globals = {
--     "use"
-- 	}
-- })

-- vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
-- 	vim.lsp.diagnostic.on_publish_diagnostics, {
-- 		-- underline
-- 		underline = true,
-- 		-- virtual text
-- 		virtual_text = true,
-- 		-- signs
-- 		signs = true,
-- 		-- delay update diagnostics
-- 		update_in_insert = false,
-- 	}
-- )
-- }}}
-- ============================================================================
-- Completions {{{
-- ============================================================================
vim.o.inccommand = "nosplit"
-- Hide some of the completion messages -- :h shortmess gives an explanation as to why
vim.cmd([[set shortmess+=c]])
-- }}}
-- ============================================================================
