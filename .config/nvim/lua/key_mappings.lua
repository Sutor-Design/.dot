local M = {}

M.config = function ()
		local wk = require("which-key")
		-- NOTE: most of this setup config is just the defaults. It easier to change
		-- the defaults if the options are right in front of me when I do so, so this
		-- contains everything.
		wk.setup({
			plugins = {
				-- shows a list of your marks on ' and `
				marks = true,
				-- shows your registers on " in NORMAL or <C-r> in INSERT mode
				registers = true,
				spelling = {
					-- enabling this will show WhichKey when pressing z= to select
					-- spelling suggestions
					enabled = false,
					-- how many suggestions should be shown in the list?
					suggestions = 20,
				},
				-- the presets plugin, adds help for a bunch of default keybindings
				-- NOTE: no actual key bindings are created
				presets = {
					-- adds help for operators like d, y, ... and registers them for
					-- motion/text object completion
					operators = true,
					-- adds help for motions
					motions = true,
					-- help for text objects triggered after entering an operator
					text_objects = true,
					-- default bindings on <c-w>
					windows = true,
					-- misc bindings to work with windows
					nav = true,
					-- bindings for folds, spelling and others prefixed with z
					z = true,
					-- bindings for prefixed with g
					g = true,
				},
			},
			-- add operators that will trigger motion and text object completion
			-- to enable all native operators, set the preset / operators plugin above
			operators = { gc = "Comments" },
			key_labels = {
				-- override the label used to display some keys. It doesn't effect
				-- WK in any other way.
				-- For example:
				-- ["<space>"] = "SPC",
				-- ["<cr>"] = "RET",
				-- ["<tab>"] = "TAB",
			},
			icons = {
				 -- symbol used in the command line area that shows your active key combo
				breadcrumb = "»",
				 -- symbol used between a key and it's label
				separator = "➜",
				 -- symbol prepended to a group
				group = "+",
			},
			window = {
				 -- none, single, double, shadow
				border = "none",
				 -- bottom, top
				position = "bottom",
				 -- extra window margin [top, right, bottom, left]
				margin = { 1, 0, 1, 0 },
				 -- extra window padding [top, right, bottom, left]
				padding = { 2, 2, 2, 2 },
			},
			layout = {
				 -- min and max height of the columns
				height = { min = 4, max = 25 },
				 -- min and max width of the columns
				width = { min = 20, max = 50 },
				 -- spacing between columns
				spacing = 3,
				 -- align columns left, center or right
				align = "left",
			},
			 -- enable this to hide mappings for which you didn't specify a label
			ignore_missing = false,
			 -- hide mapping boilerplate
			hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ "},
			 -- show help message on the command line when the popup is visible
			show_help = true,
			 -- automatically setup triggers
			triggers = "auto",
			-- define the trigger key (or specify a list manually)
			-- triggers = {"<leader>"}
			triggers_blacklist = {
				-- list of mode / prefixes that should never be hooked by WhichKey
				-- this is mostly relevant for key maps that start with a native binding
				-- most people should not need to change this
				i = { "j", "k" },
				v = { "j", "k" },
			},
		})

		local opts = {
      mode = "n", -- NORMAL mode
      prefix = "<leader>",
      buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
      silent = true, -- use `silent` when creating keymaps
      noremap = true, -- use `noremap` when creating keymaps
      nowait = true, -- use `nowait` when creating keymaps
    }

		local mappings = {
			["/"] = { [[:Commentary<CR>]], "[un]comment" },
			["<Space>"] = {[[<Cmd>lua require("telescope.builtin").buffers()<CR>]], "current buffers"},
			b = {
				name = "buffer",
				f = { [[<Cmd>lua require("telescope.builtin").current_buffer_fuzzy_find()<CR>]], "find in buffer" },
			},
			f = {
				name = "files",
				f = { [[<Cmd>lua require("telescope.builtin").find_files()<CR>]], "find files" },
				g = { [[<Cmd>lua require("telescope.builtin").live_grep()<CR>]], "live grep" },
				o = { [[<Cmd>lua require("telescope.builtin").oldfiles()<CR>]], "recent files" },
				p = { [[<Cmd>lua require("telescope").extensions.project.project({ display_type = 'full' })<CR>]], "projects" },
				x = { [[<Cmd>lua require("nvim-tree").toggle()<CR>]], "toggle file explorer" },
				n = {
					name = "nvim",
					e = { [[:e $MYVIMRC<CR>]], "edit init.lua" },
					E = { [[:view $MYVIMRC<CR>]], "view init.lua" },
					-- TODO: following command won"t quite work. Issue is that `require` calls will require cached
					-- modules. And `source`ing this file is not going to affect the cache. Plenary
	 				-- provides a reload function, but it works *per* required module, so would need
					-- to run reload on every single require, which is not ideal.
					s = { [[:w<CR> :luafile $MYVIMRC<CR>]], "source init.lua" },
					-- This might help??
					r = { [[<Cmd>lua require("telescope.builtin").reloader()<CR>]], "list Lua modules & reload on <CR>"},
					x = { [[<Cmd>lua require("telescope.builtin").find_files({ search_dirs = { "~/.config/nvim"}})<CR>]], "search in nvim config directory"}
				},
				s = { [[<Cmd>lua require("telescope.builtin").grep_string()<CR>]], "grep string under cursor"}
			},
			g = {
				name = "git",
				s = { [[:G<CR>]], "status"},
				a = { [[:diffget //2<CR>]], "use diff on left"},
				l = { [[:diffget //3<CR>]], "use diff on right"},
			},
			j = { [[:m .+1<CR>==]], "move line UP" },
			k = { [[:m .-2<CR>==]], "move line DOWN" },
			l = {
				name = "LSP",
				b = { [[<Cmd>lua require("telescope.builtin").lsp_document_diagnostics()<CR>]], "document diagnostics" },
				d = { [[<Cmd>lua require("telescope.builtin").lsp_definitions()<CR>]], "definition/s" },
				e = { [[<Cmd>lua vim.diagnostic.show_line_diagnostics()<CR>]], "open diagnostic float"},
				g = {
					name = "go to...",
					d = { [[<Cmd>lua vim.lsp.buf.definition()<CR>]], "definition"},
					D = { [[<Cmd>lua vim.lsp.buf.declaration()<CR>]], "declaration"},
					i = { [[<Cmd>lua vim.lsp.buf.implementation()<CR>]], "implementation"},
				},
				i = { [[<Cmd>lua require("telescope.builtin").lsp_implementations()<CR>]], "implementation/s" },
				K = { [[<Cmd>lua vim.lsp.buf.hover()<CR>]], "hover info" },
				r = { [[<Cmd>lua vim.lsp.buf.rename()<CR>]], "rename" },
				w = { [[<Cmd>lua require("telescope.builtin").lsp_workspace_diagnostics()<CR>]], "workspace diagnostics" },
			},
			-- o = {
			-- 	name = "orgmode",
			-- 	f = { [[<CMD>lua require('orgmode').action('capture.prompt')<CR>]], "capture" },
			-- 	c = { [[<CMD>lua require('orgmode').action('agenda.prompt')<CR>]], "agenda" },
			-- },
			q = { [[:wa<CR> :q<CR>]], "quit safely (save files)" },
			Q = { [[:q!<CR>]], "quit dangerously (save nothing!)"},
			t = {
				name = "toggle",
				m = { [[:MinimapToggle<CR>]], "minimap" },
				t = { [[:TableModeToggle<CR>]], "table mode" },
			},
			x = {
				name = "text",
					-- NOTE: following work by deleting to end of line, creating a new line
					-- above/below, entering a character (arbitrary, "q" is used), deleting
					-- it (this retains the indentation), escaping to normal mode then pasting.
				o = { [[vg_doq<BS><Esc>p]], "Split at cursor and paste below"},
				O = { [[vg_dOq<BS><Esc>p]], "Split at cursor and paste above"},
			},
		}

    local vopts = {
      mode = "v", -- VISUAL mode
      prefix = "<leader>",
      buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
      silent = true, -- use `silent` when creating keymaps
      noremap = true, -- use `noremap` when creating keymaps
      nowait = true, -- use `nowait` when creating keymaps
    }

		local vmappings = {
			["/"] = { [[:'<,'>Commentary<CR>]], "[un]comment region" },
			c = { [["*y]], "yank to system register" },
			v = { [["*p]], "paste from system register (after)" },
			V = { [["*P]], "paste from system register (before)" },
			j = { [[:m '>+1<CR>gv=gv]], "move highlighted region UP" },
			k = { [[:m '<-2<CR>gv=gv]], "move highlighted region DOWN" },
			w = { [[:set wrap!]], "toggle word wrap" },
		}

		wk.register(mappings, opts)
		wk.register(vmappings, vopts)
end

return M
-- TODO: LSP key mappings
-- local opts = { noremap = true, silent = true }
-- REVIEW: Key mappings
-- vim.api.nvim_buf_set_keymap(bufnr, "n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts)
-- vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)
-- vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
-- vim.api.nvim_buf_set_keymap(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
-- vim.api.nvim_buf_set_keymap(bufnr, "n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
-- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
-- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
-- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts)
-- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
-- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
-- vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
-- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
-- vim.api.nvim_buf_set_keymap(bufnr, "v", "<leader>ca", "<cmd>lua vim.lsp.buf.range_code_action()<CR>", opts)
-- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>e", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", opts)
-- vim.api.nvim_buf_set_keymap(bufnr, "n", "[d", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", opts)
-- vim.api.nvim_buf_set_keymap(bufnr, "n", "]d", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", opts)
-- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>q", "<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>", opts)
-- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>so", [[<cmd>lua require("telescope.builtin").lsp_document_symbols()<CR>]], opts)
