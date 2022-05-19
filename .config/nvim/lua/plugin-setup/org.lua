require('orgmode').setup_ts_grammar()

-- Tree-sitter configuration
require'nvim-treesitter.configs'.setup {
  -- If TS highlights are not enabled at all, or disabled via `disable` prop, highlighting will fallback to default Vim syntax highlighting
  highlight = {
    enable = true,
    disable = {'org'}, -- Remove this to use TS highlighter for some of the highlights (Experimental)
    additional_vim_regex_highlighting = {'org'}, -- Required since TS highlighter doesn't support all syntax features (conceal)
  },
  ensure_installed = {'org'}, -- Or run :TSUpdate org
}

require("orgmode").setup {
	org_agenda_files = { "~/Dropbox/Orgfiles/*" },
	org_agenda_templates = {
		t = { description = "Task", template = "* TODO %?\n %u" },
		n = { description = "Note", template = "* NOTE\n%?\n %u" },
	},
	org_default_notes_file = "~/Dropbox/Orgfiles/refile-desktop.org",
	win_split_mode = "float",
}

-- NOTE: following is experimental and may break at any time, at time of writing the plugin is 7 days old.
-- It's allows a subset of VimWiki features to be used with the .org filetype.
-- As such, belongs alongside the actual org configs.
require("orgWiki").setup {
	wiki_path = { "~/Dropbox/Orgfiles/" },
	diary_path = "~/Dropbox/Orgfiles/diary/",
}
