-- vim:fileencoding=utf-8:foldmethod=marker
-- ============================================================================
-- Dan Couper
-- danielcouper.sutor@gmail.com
-- https://github.com/DanCouper
--
-- NOTE: Requires HEAD (currently on v0.7). Probably. Some stuff might break if
-- not on HEAD but whatever, YOLO.
-- NOTE: Cribbed from a number of sources, in particular:
--
--       - https://github.com/mjlbach/defaults.nvim
--       - https://github.com/neovim/nvim-lspconfig/wiki
--       - https://github.com/mukeshsoni/config/blob/master/.config/nvim/init.lua
--       - https://github.com/evantravers/dotfiles/blob/master/nvim/.config/nvim/init.lua
--       - https://neovim.discourse.group/t/the-300-line-init-lua-challenge/227
--       - https://github.com/nanotee/nvim-lua-guide/
--			 - https://gist.github.com/ammarnajjar/3bdd9236cf62513a79db20520ba8467d
--			 - https://github.com/tjdevries/config_manager/blob/master/xdg_config/nvim/lua/tj/plugins.lua
-- ============================================================================
-- {{{ Plugins
-- ============================================================================
-- TODO: rip all these configs out please. Ideally just a set of `use` calls,
-- but I think that's optimistic.
-- Automatically ensure that Packer installs itself if it isn't already present.
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
		use "wbthomason/packer.nvim"
		-- startup time profiling
		use "dstein64/vim-startuptime"
		-- build colour scheme
		use "rktjmp/lush.nvim"
		-- just delegate preferences to an editorconfig file
		use "editorconfig/editorconfig-vim"
		use {
			"nvim-treesitter/nvim-treesitter",
			config = function ()
				require("nvim-treesitter.configs").setup {
					ensure_installed = "maintained",
					highlight = {
						enable = true,
					},
				}
			end
		}
		use {
			"neovim/nvim-lspconfig",
			requires = {
				"williamboman/nvim-lsp-installer",
				"hrsh7th/cmp-nvim-lsp",
			},
			config = function()
				-- local lsp = require("lspconfig")
				local lsp_installer_servers = require("nvim-lsp-installer.servers")
				local lsp_cmp = require("cmp_nvim_lsp")

				local on_attach = function(client, bufnr)
					vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

					if client.resolved_capabilities.document_formatting then
						vim.api.nvim_command([[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()]])
					end
				end

				local lsp_capabilities = vim.lsp.protocol.make_client_capabilities()
				lsp_capabilities.textDocument.completion.completionItem.snippetSupport = true

				local servers = {
					sumneko_lua = {
						on_attach = on_attach,
						capabilities = lsp_cmp.update_capabilities(lsp_capabilities),
						settings = {
							Lua = {
								diagnostics = {
									-- The Lua language server is being used for Neovim stuff,
									-- globals listed relate to Neovim development.
									globals = { "use", "vim" },
								},
								workspace = {
									-- Make the server aware of Neovim runtime files
									library = vim.api.nvim_get_runtime_file("", true),
								},
							},
						},
					},
				}

				for server, server_setup in next, servers, nil do
					local server_available, requested_server = lsp_installer_servers.get_server(
						server
					)
					if server_available then
						requested_server:on_ready(function()
							requested_server:setup(server_setup)
						end)

						if not requested_server:is_installed() then
							-- Queue the server to be installed
							requested_server:install()
						end
					end
				end

				vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
					vim.lsp.diagnostic.on_publish_diagnostics,
					{
						underline = true,
						virtual_text = true,
						signs = true,
						update_in_insert = false,
					}
				)
			end
		}
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
				-- this works in tandem with the lsp stuff
				local cmp = require("cmp")
				local luasnip = require("luasnip")
				local lspkind = require("lspkind")

				local has_words_before = function()
					local line, col = unpack(vim.api.nvim_win_get_cursor(0))
					return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
				end

				cmp.setup({
					completion = {
						completeopt = "menu,menuone,noinsert",
					},
					snippet = {
						expand = function(args)
							luasnip.lsp_expand(args.body)
						end,
					},
					mapping = {
						["<C-d>"] = cmp.mapping.scroll_docs(-4),
						["<C-f>"] = cmp.mapping.scroll_docs(4),
						["<C-space>"] = cmp.mapping.complete(),
						["<C-e>"] = cmp.mapping.close(),
						["<Cr>"] = cmp.mapping.confirm({ select = true }),
						["<Tab>"] = cmp.mapping(function(fallback)
							if cmp.visible() then
								cmp.select_next_item()
							elseif luasnip.expand_or_jumpable() then
								luasnip.expand_or_jump()
							elseif has_words_before() then
								cmp.complete()
							else
								fallback()
							end
						end, { "i", "s" }),
						["<S-Tab>"] = cmp.mapping(function(fallback)
							if cmp.visible() then
								cmp.select_prev_item()
							elseif luasnip.jumpable(-1) then
								luasnip.jump(-1)
							else
								fallback()
							end
						end, { "i", "s" }),
					},
					sources = {
						{ name = "nvim_lsp" },
						{ name = "luasnip" },
						{ name = "buffer" },
						-- { name = "orgmode" },
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
			"l3mon4d3/luasnip",
			config = function ()
				require "luasnip/loaders/from_vscode".lazy_load()
			end
		}

		use "rafamadriz/friendly-snippets"

	end
})
-- }}}
-- ============================================================================
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
-- the colorcolunm is just a visual reminder of the ideal max width. 80 is
-- good for me i think, maybe i'm probably doing something too nested or verbose
-- if i go over it, who knows.
-- NOTE: yes, it's set to 81.
vim.wo.colorcolumn = "81"
-- turn *off* wordwrap by default, only want it for prose.
vim.wo.wrap = false
-- ----------------------------------------------------------------------------
-- completion- and syntax-related options
-- ----------------------------------------------------------------------------
-- markdown syntax highlighting
vim.g.markdown_fenced_languages = {
	"ts=typescript"
}
-- which key to use when confirming completions
vim.g.completion_confirm_key = ""
-- extra completions stuff
vim.g.completion_matching_strategy_list = {"exact", "substring", "fuzzy"}
-- I mean this is supposed to weight things but it really doesn't seem to do
-- great, hey ho. I still generally get "text" as the most common option above
-- useful stuff like LSP results.
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
-- hide some of the completion messages -- :h shortmess gives an explanation as
-- to why.
vim.cmd([[set shortmess+=c]])
-- }}}
