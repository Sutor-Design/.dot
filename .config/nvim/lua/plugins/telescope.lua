local telescope = require "telescope"
local telescope_builtin = require "telescope.builtin"

telescope.load_extension "project"
telescope.load_extension "file_browser"

local M = {}

telescope.setup {
	defaults = {
		prompt_position = "top",
		layout_strategy = "horizontal",
		sorting_strategy = "ascending",
		use_less = false,
	},
}

M.find_files = function()
	telescope_builtin.find_files {
		hidden = true,
	}
end

M.find_config_files = function()
	local config_dir = vim.env.HOME .. "/.config/nvim"
	telescope_builtin.find_files {
		hidden = true,
		search_dirs = { config_dir },
	}
end

M.live_grep = function()
	telescope_builtin.live_grep()
end

M.buffers = function()
	telescope_builtin.buffers {
		ignore_current_buffer = true,
		mappings = {
			i = {
				["<C-u>"] = false,
				-- FIXME: this currently errors for me
				-- ["<C-d>"] = "delete_buffer",
			},
		},
	}
end

M.help_tags = function()
	telescope_builtin.help_tags()
end

M.recent_files = function()
	telescope_builtin.oldfiles()
end

M.projects = function()
	telescope.extensions.project.project { display_type = "full" }
end

M.file_browser = function()
	telescope.extensions.file_browser.file_browser {
		hidden = true,
	}
end

return M
