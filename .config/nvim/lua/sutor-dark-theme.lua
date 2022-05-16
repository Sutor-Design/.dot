-- Colour ramps are generated from https://grayscale.design/app
-- They use an 11-colour scale using a bell curve preset, which seems to give
-- the best weighting at the extremities (need a few quite small variations in
-- dark/light, middle I don't care too much about).
-- Using this generator then allows easy generation of colours, but the theme
-- should ideally work without other colours.
local primary = {
	[50] = hsluv.hsluv_to_hex({ 224, 20.80, 97.12 }),
	[100] = hsluv.hsluv_to_hex({ 224, 20.80, 95.39 }),
	[200] = hsluv.hsluv_to_hex({ 224, 20.80, 93.19 }),
	[300] = hsluv.hsluv_to_hex({ 224, 20.80, 89.27 }),
	[400] = hsluv.hsluv_to_hex({ 224, 20.80, 83.54 }),
	[500] = hsluv.hsluv_to_hex({ 224, 20.80, 74.28 }),
	[600] = hsluv.hsluv_to_hex({ 224, 20.80, 62.86 }),
	[700] = hsluv.hsluv_to_hex({ 224, 20.80, 52.49 }),
	[800] = hsluv.hsluv_to_hex({ 224, 20.80, 41.23 }),
	[900] = hsluv.hsluv_to_hex({ 224, 20.80, 29.91 }),
	[1000] = hsluv.hsluv_to_hex({ 224, 20.80, 17.82 }),
}

local error = hsluv.hsluv_to_hex({ 13.4, 84.2, 50.7 })
local warn = hsluv.hsluv_to_hex({ 34.7, 89.5, 61.3 })
local info = hsluv.hsluv_to_hex({ 223.1, 69.7, 75 })

local theme = {
	-- The base highlight group is `Normal` -- *almost* everything else will fall
	-- back to this.
	-- NOTE: As long as highlight groups are present (not commented), Lush
	-- will fall back. If they are commented, it's going to fall back to general
	-- defaults, which may well not be what is wanted.
	Normal = { bg = primary[1000], fg = primary[200] },
	NormalFloat = {}, -- Normal text in floating windows.
	NormalNC = {}, -- normal text in non-current windows
	-- GUI font basics, will work in most modern terminals:
	Underlined = { underline = true }, -- (preferred) text that stands out, HTML links
	Bold = { bold = true },
	Italic = { italic = true },
	-- I normally want hidden characters (spaces, tabs, eol etc) displayed, but they
	-- need to be nearly invisible.
	SpecialKey = { fg = primary[900] }, -- Unprintable characters: text displayed differently from what it really is.  But not 'listchars' whitespace. |hl-Whitespace|
	Whitespace = { fg = primary[900] }, -- "nbsp", "space", "tab" and "trail" in 'listchars'
	NonText = { fg = primary[900] }, -- '@' at the end of the window, characters from 'showbreak' and other characters that do not really exist in the text (e.g., ">" displayed when a double-wide character doesn't fit at the end of the line). See also |hl-EndOfBuffer|.
	-- One exception is the filler lines at the end of the buffer, which I hate
	EndOfBuffer = { fg = primary[1000], bg = primary[1000] }, -- filler lines (~) after the end of the buffer.  By default, this is highlighted like |hl-NonText|.
	-- Comments I want faded/dimmed a bit so as not to distract attention too much
	Comment = { fg = primary[500],italic = true }, -- any comment
	-- I like the cursorline set so I can see where I am:
	CursorLine = { bg = primary[900] }, -- Screen-line at the cursor, when 'cursorline' is set.  Low-priority if foreground (ctermfg OR guifg) is not set.
	CursorColumn = {}, -- Screen-column at the cursor, when 'cursorcolumn' is set.
	-- If the ColorColumn (set at preferred line length) is on, then if it *isn't*
	-- the same style as the CursorLine it looks weird:
	ColorColumn = { bg = primary[900] }, -- used for the columns set with 'colorcolumn'
	-- Then line numbers can be relative except the current one, which needs to
	-- stand out.
	-- REVIEW: Other side column UI needs definition here as well.
	LineNr = { fg = primary[800], bold = true }, -- Line number for ":number" and ":#" commands, and when 'number' or 'relativenumber' option is set.
	CursorLineNr = { bold = true }, -- Like LineNr when 'cursorline' or 'relativenumber' is set for the cursor line.
	SignColumn = { bold = true }, -- column where |signs| are displayed
	FoldColumn = { fg = primary[800] }, -- 'foldcolumn'
	-- Similarly, the cursor needs to stand out as well:
	-- REVIEW: fiddle with this.
	Cursor = { inverse = true }, -- character under the cursor
	CursorIM = {}, -- like Cursor, but used when in IME mode |CursorIM|
	-- REVIEW: Interactive UI. As rely quite heavily on LSP/completions, getting
	-- this correct is quite important
	Pmenu = { fg = primary[900], bg = primary[200] }, -- Popup menu: normal item.
	PmenuSbar = {}, -- Popup menu: scrollbar.
	PmenuSel = { fg = primary[1000], bg = primary[400] }, -- Popup menu: selected item.
	PmenuThumb = {}, -- Popup menu: Thumb of the scrollbar.
	WildMenu = { fg = primary[1000], bg = primary[400] }, -- current match in 'wildmenu' completion
	-- REVIEW: selection UI
	IncSearch = {}, -- 'incsearch' highlighting; also used for the text replaced with ":s///c"
	Visual = { bg = primary[800] }, -- Visual mode selection
	VisualNOS = {}, -- Visual mode selection when vim is "Not Owning the Selection".
	Search = {}, -- Last search pattern highlighting (see 'hlsearch').  Also used for similar items that need to stand out.
	Substitute = { inverse = true }, -- |:substitute| replacement text highlighting
	-- REVIEW: status and message bars. I want a bit more of a visual separation
	-- here, needs work
	StatusLine = {}, -- status line of current window
	StatusLineNC = {}, -- status lines of not-current windows Note: if this is equal to "StatusLine" Vim will use "^^^" in the status line of the current window.
	MsgArea = {}, -- Area for messages and cmdline
	MsgSeparator = {}, -- Separator for scrolled messages, `msgsep` flag of 'display'

	-- TODO
	Conceal = {}, -- placeholder characters substituted for concealed text (see 'conceallevel')
	DiffAdd = {}, -- diff mode: Added line |diff.txt|
	DiffChange = {}, -- diff mode: Changed line |diff.txt|
	DiffDelete = {}, -- diff mode: Deleted line |diff.txt|
	DiffText = {}, -- diff mode: Changed text within a changed line |diff.txt|
	Directory = { bold = true }, -- directory names (and other special names in listings)
	ErrorMsg = { fg = error }, -- error messages on the command line
	Folded = { bg = primary[800] }, -- line used for closed folds
	MatchParen = { fg = warn, bold = true }, -- The character under the cursor or just before it, if it is a paired bracket, and its match. |pi_paren.txt|
	ModeMsg = {}, -- 'showmode' message (e.g., "-- INSERT -- ")
	MoreMsg = {}, -- |more-prompt|
	Question = {}, -- |hit-enter| prompt and yes/no questions
	QuickFixLine = {}, -- Current |quickfix| item in the quickfix window. Combined with |hl-CursorLine| when the cursor is there.
	SpellBad = { fg = warn }, -- Word that is not recognized by the spellchecker. |spell| Combined with the highlighting used otherwise.
	SpellCap = {}, -- Word that should start with a capital. |spell| Combined with the highlighting used otherwise.
	SpellLocal = {}, -- Word that is recognized by the spellchecker as one that is used in another region. |spell| Combined with the highlighting used otherwise.
	SpellRare = {}, -- Word that is recognized by the spellchecker as one that is hardly ever used.  |spell| Combined with the highlighting used otherwise.
	TabLine = {}, -- tab pages line, not active tab page label
	TabLineFill = {}, -- tab pages line, where there are no labels
	TabLineSel = {}, -- tab pages line, active tab page label
	TermCursor = {}, -- cursor in a focused terminal
	TermCursorNC = {}, -- cursor in an unfocused terminal
	Title = {}, -- titles for output from ":set all", ":autocmd" etc.
	VertSplit = { bg = primary[1000] }, -- the column separating vertically split windows
	WarningMsg = { fg = warn }, -- warning messages
	lCursor = {}, -- the character under the cursor when |language-mapping| is used (see 'guicursor')

	-- These groups are not listed as default vim groups,
	-- but they are defacto standard group names for syntax highlighting.
	-- commented out groups should chain up to their "preferred" group by
	-- default,
	-- Uncomment and edit if you want more specific syntax highlighting.

	Constant = { bold = true }, -- (preferred) any constant
	String = { italic = true }, --   a string constant: "this is a string"
	Character = {}, --  a character constant: 'c', '\n'
	Number = {}, --   a number constant: 234, 0xff
	Boolean = {}, --  a boolean constant: TRUE, false
	Float = {}, --    a floating point constant: 2.3e10

	Identifier = { bold = true }, -- (preferred) any variable name
	Function = { bold = true }, -- function name (also: methods for classes)

	Statement = {}, -- (preferred) any statement
	Conditional = {}, --  if, then, else, endif, switch, etc.
	Repeat = {}, --   for, do, while, etc.
	Label = {}, --    case, default, etc.
	Operator = {}, -- "sizeof", "+", "*", etc.
	Keyword = {}, --  any other keyword
	Exception = {}, --  try, catch, throw

	PreProc = {}, -- (preferred) generic Preprocessor
	Include = {}, --  preprocessor #include
	Define = {}, --   preprocessor #define
	Macro = {}, --    same as Define
	PreCondit = {}, --  preprocessor #if, #else, #endif, etc.

	Type = {}, -- (preferred) int, long, char, etc.
	StorageClass = {}, -- static, register, volatile, etc.
	Structure = {}, --  struct, union, enum, etc.
	Typedef = {}, --  A typedef

	Special = {}, -- (preferred) any special symbol
	SpecialChar = {}, --  special character in a constant
	Tag = {}, --    you can use CTRL-] on this
	Delimiter = {}, --  character that needs attention
	SpecialComment = {}, -- special things inside a comment
	Debug = {}, --    debugging statements

	-- ("Ignore", below, may be invisible...)
	-- Ignore         = { }, -- (preferred) left blank, hidden  |hl-Ignore|
	Error = { fg = error }, -- (preferred) any erroneous construct
	Todo = { fg = warn, bold = true }, --  (preferred) anything that needs extra attention; mostly the keywords TODO FIXME and XXX
	TodoExtra = { fg = warn, bold = true },

	-- These groups are for the native LSP client and diagnostic system. Some
	-- other LSP clients may use these groups, or use their own. Consult your
	-- LSP client's documentation.

	-- See :h lsp-highlight, some groups may not be listed, submit a PR fix to lush-template!
	--
	-- LspReferenceText            = { } , -- used for highlighting "text" references
	-- LspReferenceRead            = { } , -- used for highlighting "read" references
	-- LspReferenceWrite           = { } , -- used for highlighting "write" references
	-- LspCodeLens                 = { } , -- Used to color the virtual text of the codelens. See |nvim_buf_set_extmark()|.
	-- LspCodeLensSeparator        = { } , -- Used to color the seperator between two or more code lens.
	LspSignatureActiveParameter = { fg = info }, -- Used to highlight the active parameter in the signature help. See |vim.lsp.handlers.signature_help()|.

	-- See :h diagnostic-highlights, some groups may not be listed, submit a PR fix to lush-template!
	--
	DiagnosticError = { fg = error }, -- Used as the base highlight group. Other Diagnostic highlights link to this by default (except Underline)
	DiagnosticWarn = { fg = warn }, -- Used as the base highlight group. Other Diagnostic highlights link to this by default (except Underline)
	DiagnosticInfo = { fg = info }, -- Used as the base highlight group. Other Diagnostic highlights link to this by default (except Underline)
	DiagnosticHint = { fg = primary[100] }, -- Used as the base highlight group. Other Diagnostic highlights link to this by default (except Underline)
	-- DiagnosticVirtualTextError = { } , -- Used for "Error" diagnostic virtual text.
	-- DiagnosticVirtualTextWarn  = { } , -- Used for "Warn" diagnostic virtual text.
	-- DiagnosticVirtualTextInfo  = { } , -- Used for "Info" diagnostic virtual text.
	-- DiagnosticVirtualTextHint  = { } , -- Used for "Hint" diagnostic virtual text.
	-- DiagnosticUnderlineError   = { } , -- Used to underline "Error" diagnostics.
	-- DiagnosticUnderlineWarn    = { } , -- Used to underline "Warn" diagnostics.
	-- DiagnosticUnderlineInfo    = { } , -- Used to underline "Info" diagnostics.
	-- DiagnosticUnderlineHint    = { } , -- Used to underline "Hint" diagnostics.
	-- DiagnosticFloatingError    = { } , -- Used to color "Error" diagnostic messages in diagnostics float. See |vim.diagnostic.open_float()|
	-- DiagnosticFloatingWarn     = { } , -- Used to color "Warn" diagnostic messages in diagnostics float.
	-- DiagnosticFloatingInfo     = { } , -- Used to color "Info" diagnostic messages in diagnostics float.
	-- DiagnosticFloatingHint     = { } , -- Used to color "Hint" diagnostic messages in diagnostics float.
	-- DiagnosticSignError        = { } , -- Used for "Error" signs in sign column.
	-- DiagnosticSignWarn         = { } , -- Used for "Warn" signs in sign column.
	-- DiagnosticSignInfo         = { } , -- Used for "Info" signs in sign column.
	-- DiagnosticSignHint         = { } , -- Used for "Hint" signs in sign column.

	-- See :h nvim-treesitter-highlights, some groups may not be listed, submit a PR fix to lush-template!
	--
	-- TSAttribute          = { } , -- Annotations that can be attached to the code to denote some kind of meta information. e.g. C++/Dart attributes.
	-- TSBoolean            = { } , -- Boolean literals: `True` and `False` in Python.
	-- TSCharacter          = { } , -- Character literals: `'a'` in C.
	-- TSComment            = { } , -- Line comments and block comments.
	-- TSConditional        = { } , -- Keywords related to conditionals: `if`, `when`, `cond`, etc.
	-- TSConstant           = { } , -- Constants identifiers. These might not be semantically constant. E.g. uppercase variables in Python.
	-- TSConstBuiltin       = { } , -- Built-in constant values: `nil` in Lua.
	-- TSConstMacro         = { } , -- Constants defined by macros: `NULL` in C.
	-- TSConstructor        = { } , -- Constructor calls and definitions: `{}` in Lua, and Java constructors.
	-- TSError              = { } , -- Syntax/parser errors. This might highlight large sections of code while the user is typing still incomplete code, use a sensible highlight.
	-- TSException          = { } , -- Exception related keywords: `try`, `except`, `finally` in Python.
	-- TSField              = { } , -- Object and struct fields.
	-- TSFloat              = { } , -- Floating-point number literals.
	-- TSFunction           = { } , -- Function calls and definitions.
	-- TSFuncBuiltin        = { } , -- Built-in functions: `print` in Lua.
	-- TSFuncMacro          = { } , -- Macro defined functions (calls and definitions): each `macro_rules` in Rust.
	-- TSInclude            = { } , -- File or module inclusion keywords: `#include` in C, `use` or `extern crate` in Rust.
	-- TSKeyword            = { } , -- Keywords that don't fit into other categories.
	-- TSKeywordFunction    = { } , -- Keywords used to define a function: `function` in Lua, `def` and `lambda` in Python.
	-- TSKeywordOperator    = { } , -- Unary and binary operators that are English words: `and`, `or` in Python; `sizeof` in C.
	-- TSKeywordReturn      = { } , -- Keywords like `return` and `yield`.
	-- TSLabel              = { } , -- GOTO labels: `label:` in C, and `::label::` in Lua.
	-- TSMethod             = { } , -- Method calls and definitions.
	-- TSNamespace          = { } , -- Identifiers referring to modules and namespaces.
	-- TSNone               = { } , -- No highlighting (sets all highlight arguments to `NONE`). this group is used to clear certain ranges, for example, string interpolations. Don't change the values of this highlight group.
	-- TSNumber             = { } , -- Numeric literals that don't fit into other categories.
	-- TSOperator           = { } , -- Binary or unary operators: `+`, and also `->` and `*` in C.
	-- TSParameter          = { } , -- Parameters of a function.
	-- TSParameterReference = { } , -- References to parameters of a function.
	-- TSProperty           = { } , -- Same as `TSField`.
	-- TSPunctDelimiter     = { } , -- Punctuation delimiters: Periods, commas, semicolons, etc.
	-- TSPunctBracket       = { } , -- Brackets, braces, parentheses, etc.
	-- TSPunctSpecial       = { } , -- Special punctuation that doesn't fit into the previous categories.
	-- TSRepeat             = { } , -- Keywords related to loops: `for`, `while`, etc.
	-- TSString             = { } , -- String literals.
	-- TSStringRegex        = { } , -- Regular expression literals.
	-- TSStringEscape       = { } , -- Escape characters within a string: `\n`, `\t`, etc.
	-- TSStringSpecial      = { } , -- Strings with special meaning that don't fit into the previous categories.
	-- TSSymbol             = { } , -- Identifiers referring to symbols or atoms.
	-- TSTag                = { } , -- Tags like HTML tag names.
	-- TSTagAttribute       = { } , -- HTML tag attributes.
	-- TSTagDelimiter       = { } , -- Tag delimiters like `<` `>` `/`.
	-- TSText               = { } , -- Non-structured text. Like text in a markup language.
	-- TSStrong             = { } , -- Text to be represented in bold.
	-- TSEmphasis           = { } , -- Text to be represented with emphasis.
	-- TSUnderline          = { } , -- Text to be represented with an underline.
	-- TSStrike             = { } , -- Strikethrough text.
	-- TSTitle              = { } , -- Text that is part of a title.
	-- TSLiteral            = { } , -- Literal or verbatim text.
	-- TSURI                = { } , -- URIs like hyperlinks or email addresses.
	-- TSMath               = { } , -- Math environments like LaTeX's `$ ... $`
	-- TSTextReference      = { } , -- Footnotes, text references, citations, etc.
	-- TSEnvironment        = { } , -- Text environments of markup languages.
	-- TSEnvironmentName    = { } , -- Text/string indicating the type of text environment. Like the name of a `\begin` block in LaTeX.
	TSNote = { fg = warn, bold = true }, -- Text representation of an informational note.
	-- TSWarning            = { } , -- Text representation of a warning note.
	-- TSDanger             = { } , -- Text representation of a danger note.
	-- TSType               = { } , -- Type (and class) definitions and annotations.
	-- TSTypeBuiltin        = { } , -- Built-in types: `i32` in Rust.
	-- TSVariable           = { } , -- Variable names that don't fit into other categories.
	-- TSVariableBuiltin    = { } , -- Variable names defined by the language: `this` or `self` in Javascript.

	-- The following are groupds defined in the config. They may go out of date
	-- or get missed or whatever. Anyway:
	CmpGhostText = { fg = primary[900] },
}

for hg, opts in pairs(theme) do
	vim.api.nvim_set_hl(0, hg, opts)
end
