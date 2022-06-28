local lsp = vim.lsp
local lspconfig = require "lspconfig"
local lsp_utils = require "lspconfig.util"
local lsp_installer = require "nvim-lsp-installer"
local lsp_cmp = require "cmp_nvim_lsp"
local schemastore = require "schemastore"
local dap = require "dap"
local rust_tools = require "rust-tools"

local lsp_capabilities = lsp.protocol.make_client_capabilities()
lsp_capabilities.textDocument.completion.completionItem.snippetSupport = true

-- stylua: ignore start
local default_keymaps = {
	["go to declaration"] = { mode = "n", lhs = "lgD", rhs = "<Cmd>lua vim.lsp.buf.declaration()<CR>" },
	["go to definition"] = { mode = "n", lhs = "lgd", rhs = "<Cmd>lua vim.lsp.buf.definition()<CR>" },
	["hover info"] = { mode = "n", lhs = "lk", rhs = "<Cmd>lua vim.lsp.buf.hover()<CR>" },
	["show implementation/s"] = { mode = "n", lhs = "lgi", rhs = "<Cmd>lua vim.lsp.buf.implementation()<CR>" },
	["add workspace folder"] = { mode = "n", lhs = "lwa", rhs = "<Cmd>lua vim.lsp.buf.add_workspace_folder()<CR>" },
	["remove workspace folder"] = { mode = "n", lhs = "lwr", rhs = "<Cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>" },
	["list workspace folders"] = { mode = "n", lhs = "lwl", rhs = "<Cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>" },
	["type definition"] = { mode = "n", lhs = "lD", rhs = "<Cmd>lua vim.lsp.buf.type_definition()<CR>" },
	["rename symbols"] = { mode = "n", lhs = "lrn", rhs = "<Cmd>lua vim.lsp.buf.rename()<CR>" },
	["references"] = { mode = "n", lhs = "lgr", rhs = "<Cmd>lua vim.lsp.buf.references()<CR>" },
	["code actions"] = { mode = "n", lhs = "lca", rhs = "<Cmd>lua vim.lsp.buf.code_action()<CR>" },
	["code actions (range)"] = { mode = "n", lhs = "lca", rhs = "<Cmd>lua vim.lsp.buf.range_code_action()<CR>" },
	["show line diagnostics"] = { mode = "n", lhs = "le", rhs = "<Cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>" },
	["prev diagnostic"] = { mode = "n", lhs = "l[", rhs = "<Cmd>lua vim.lsp.diagnostic.goto_prev()<CR>" },
	["next diagnostic"] = { mode = "n", lhs = "l]", rhs = "<Cmd>lua vim.lsp.diagnostic.goto_next()<CR>" },
	["diagnostics to loclist"] = { mode = "n", lhs = "lq", rhs = "<Cmd>lua vim.lsp.diagnostic.set_loclist()<CR>" },
	["show document symbols"] = { mode = "n", lhs = "lso", rhs = [[<Cmd>lua require("telescope.builtin").lsp_document_symbols()<CR>]] },
	["signature help"] = { mode = "n", lhs = "lK", rhs = "<Cmd>lua vim.lsp.buf.signature_help()<CR>" },
}
-- stylua: ignore end

local on_attach = function(client, bufnr)
	vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

	for desc, mapping in pairs(default_keymaps) do
		vim.keymap.set(mapping.mode, "<Leader>" .. mapping.lhs, mapping.rhs, { buffer = bufnr, desc = "LSP (" .. client.name .. "): " .. desc })
	end
end

local organize_imports = function()
	local params = {
		command = "_typescript.organizeImports",
		arguments = { vim.api.nvim_buf_get_name(0) },
		title = "",
	}
	vim.lsp.buf.execute_command(params)
end

local servers = {
	cssls = {},
	denols = {
		commands = {
			Format = {
				vim.lsp.buf.format,
				description = "Format the current buffer using deno fmt",
			}
		},
		init_options = {
			lint = true,
		},
		root_dir = lsp_utils.root_pattern("mod.ts", "mod.js", "deno.json", "deno.jsonc"),
	},
	elixirls = {
		cmd = {
			"/Users/daniel.couper/.local/share/nvim/lsp_servers/elixirls/elixir-ls/language_server.sh",
		},
		commands = {
			Format = {
				vim.lsp.buf.format,
				description = "Format the current buffer using mix fmt",
			},
		},
		settings = {
			dialyzerEnabled = true,
			fetchDeps = false,
		}
	},
	erlangls = {},
	eslint = {
		settings = {
			validate = 'on',
			packageManager = 'npm',
			useESLintClass = false,
			codeActionOnSave = {
				enable = false,
				mode = 'all',
			},
			format = false,
			quiet = false,
			onIgnoredFiles = 'off',
			rulesCustomizations = {},
			run = 'onType',
			-- nodePath configures the directory in which the eslint server should start its node_modules resolution.
			-- This path is relative to the workspace folder (root dir) of the server instance.
			nodePath = '',
			-- use the workspace folder location or the file location (if no workspace folder is open) as the working directory
			workingDirectory = { mode = 'location' },
			codeAction = {
				disableRuleComment = {
					enable = true,
					location = 'separateLine',
				},
				showDocumentation = {
					enable = true,
				},
			},
		},
	},
	html = {
		filetypes = {
			"html",
			"html-eex",
		}
	},
	jsonls = {
		settings = {
			json = {
				schemas = schemastore.json.schemas(),
			},
		}
	},
	sumneko_lua = {
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
	tailwindcss = {},
	tsserver = {
		commands = {
			OrganizeImports = {
				organize_imports,
				description = "Organize Imports",
			},
		},
	},
}

lsp_installer.setup({})
for server_name, additional_server_setup in pairs(servers) do
	local setup_options = {
		capabilities = lsp_cmp.update_capabilities(lsp_capabilities),
	}

	for k, v in pairs(additional_server_setup) do
		setup_options[k] = v
	end

	if setup_options.on_attach == nil then
		setup_options.on_attach = on_attach
	end

	lspconfig[server_name].setup(setup_options)
end

-- Using rust-tools for ease instead of manually setting up rust-analyzer
-- see https://sharksforarms.dev/posts/neovim-rust/
rust_tools.setup({
	tools = { -- rust-tools options
		autoSetHints = true,
		hover_with_actions = true,
		inlay_hints = {
				show_parameter_hints = false,
				parameter_hints_prefix = "",
				other_hints_prefix = "",
		},
	},
	-- all the opts to send to nvim-lspconfig
	-- these override the defaults set by rust-tools.nvim
	-- see https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#rust_analyzer
	server = {
		on_attach = on_attach,
		settings = {
			-- to enable rust-analyzer settings visit:
			-- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
			["rust-analyzer"] = {
				-- enable clippy on save
				checkOnSave = {
						command = "clippy"
				},
			}
		}
	},
})

dap.adapters.mix_task = {
	type = "executable",
	command = "/Users/daniel.couper/.local/share/nvim/lsp_servers/elixirls/elixir-ls/debugger.sh",
	args = {},
}

dap.configurations.elixir = {
	type = "mix_task",
	name = "mix test",
	task = "test",
	taskArgs = {"--trace"},
	request = "launch",
	startApps = true,
	projectDir = "${workspaceFolder}",
	requireFiles = {
		"test/**/test_helper.exs",
		"test/**/*_test.exs",
	},
}
