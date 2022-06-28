local telescope = require "telescope"
local telescope_actions = require "telescope.actions"
local telescope_builtin = require "telescope.builtin"

telescope.setup {
	defaults = {
		prompt_position = "top",
		layout_strategy = "horizontal",
		sorting_strategy = "ascending",
		use_less = false,
	},
	pickers = {
		find_files = {
			hidden = true,
		},
		live_grep = {},
		buffers = {
			ignore_current_buffer = true,
			mappings = {
				i = {
					["<C-u>"] = false,
					["<C-d>"] = telescope_actions.delete_buffer + telescope_actions.move_to_top,
				},
			},
		},
	},
	extensions = {
		file_browser = {
			hidden = true,
			grouped = true,
		},
		projects = {
			display_type = "full",
		},
	},
}
telescope.load_extension "project"
telescope.load_extension "file_browser"
