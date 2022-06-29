local zenmode = require "zen-mode";

zenmode.setup {
	window = {
		options = {
      signcolumn = "no", -- disable signcolumn
      number = false, -- disable number column
      relativenumber = false, -- disable relative numbers
      cursorline = false, -- disable cursorline
      cursorcolumn = false, -- disable cursor column
      foldcolumn = "0", -- disable fold column
      list = false, -- disable whitespace characters
    },
	},
	plugins = {
		options = {
			showcmd = true,
		},
		twighlight = {
			enabled = true,
		},
		kitty = {
			enabled = true,
		}
	}
}
