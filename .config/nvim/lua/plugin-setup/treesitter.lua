local treesitter_configs = require "nvim-treesitter.configs"

-- NOTE: commenting the following out. OSX' Clang compiler doesn't
-- support C++11 by default, and I can't figure out how to make it so.
-- Therefore I can't compile this parser :(
-- local treesitter_parsers = require "nvim-treesitter.parsers"
--
-- treesitter_parsers.get_parser_configs().just = {
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
	tree_docs = {
		enable = true,
	}
}
