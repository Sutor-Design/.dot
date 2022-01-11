local telescope = require 'telescope'
local telescope_builtin = require 'telescope.builtin'
local telescope_actions = require 'telescope.actions'

telescope.load_extension('project')

local M = {}

telescope.setup {
  defaults = {
    prompt_position = 'top',
    layout_strategy = 'horizontal',
    sorting_strategy = 'ascending',
    use_less = false
  }
}

M.find_files = function()
  telescope_builtin.find_files({
		find_command = { 'rg', '--files', '--iglob', '!.DS_Store', 'node_modules', '--hidden' },
	})
end

M.find_config_files = function()
  local config_dir = vim.env.HOME .. '/.config/nvim'
  telescope_builtin.find_files({
		search_dirs = { config_dir }
  })
end

M.live_grep = function()
  telescope_builtin.live_grep()
end


M.buffers = function()
  telescope_builtin.buffers()
end

M.help_tags = function()
	telescope_builtin.help_tags()
end

M.recent_files = function()
	telescope_builtin.oldfiles()
end

M.projects = function()
	telescope.extensions.project.project({ display_type = 'full' })
end

return M
