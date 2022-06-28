local treesitter_configs = require "nvim-treesitter.configs"

-- NOTE: commenting the following out. OSX' Clang compiler doesn't
-- support C++11 by default, and I can't figure out how to make it so.
-- Therefore I can't compile this parser :(
-- local treesitter_parsers = require "nvim-treesitter.parsers"
--
-- require("nvim-treesitter.parsers").get_parser_configs().just = {
--   install_info = {
--     url = "https://github.com/IndianBoy42/tree-sitter-just", -- local path or git repo
--     files = { "src/parser.c", "src/scanner.cc" },
--     branch = "main",
--   },
--   maintainers = { "@IndianBoy42" },
-- }

treesitter_configs.setup {
	ensure_installed = "all",
	-- Any parsers that have issues, add here
	ignore_install = {
		-- see https://github.com/claytonrcarter/tree-sitter-phpdoc/issues/15
		"phpdoc",
	},
	highlight = {
		enable = true,
	},
	incremental_selection = {
		enable = true,
		keymap = {
			init_selection = "<CR>",
			scope_incremental = "<CR>",
			node_incremental = "<TAB>",
			node_decremental = "<S-TAB>",
		},
	},
	indent = {
		enable = true,
	},
  playground = {
    enable = true,
    disable = {},
    updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
    persist_queries = false, -- Whether the query persists across vim sessions
    keybindings = {
      toggle_query_editor = 'o',
      toggle_hl_groups = 'i',
      toggle_injected_languages = 't',
      toggle_anonymous_nodes = 'a',
      toggle_language_display = 'I',
      focus_language = 'f',
      unfocus_language = 'F',
      update = 'R',
      goto_node = '<cr>',
      show_help = '?',
    },
  },
	tree_docs = {
		enable = true,
	}
}
