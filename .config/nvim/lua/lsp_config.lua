local M = {}

M.config = function()
	local lsp = require("lspconfig")
	local lsp_installer_servers = require("nvim-lsp-installer.servers")
	local lsp_cmp = require("cmp_nvim_lsp")

	local on_attach = function(client, bufnr)
		vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

		-- if client.resolved_capabilities.document_formatting then
		-- vim.api.nvim_command([[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()]])
		-- end
	end

	local lsp_capabilities = vim.lsp.protocol.make_client_capabilities()
	lsp_capabilities.textDocument.completion.completionItem.snippetSupport = true

	local function organize_imports()
		local params = {
			command = "_typescript.organizeImports",
			arguments = { vim.api.nvim_buf_get_name(0) },
			title = "",
		}
		vim.lsp.buf.execute_command(params)
	end

	local servers = {
		cssls = {
			on_attach = on_attach,
			capabilities = lsp_cmp.update_capabilities(lsp_capabilities),
		},
		-- denols = {
		-- 	on_attach = on_attach,
		-- 	capabilities = lsp_cmp.update_capabilities(lsp_capabilities),
		-- 	init_options = {
		-- 		lint = true,
		-- 	},
		-- 	root_dir = function(fname)
		-- 		return require("lspconfig").util.root_pattern("deno.json")(fname)
		-- 	end,
		-- },
		html = {
			on_attach = on_attach,
			capabilities = lsp_cmp.update_capabilities(lsp_capabilities),
		},
		jsonls = {
			on_attach = on_attach,
			capabilities = lsp_cmp.update_capabilities(lsp_capabilities),
			filetypes = { "json", "jsonc" },
			flags = {
				debounce_text_changes = 150,
			},
			json = {
				-- Schemas https://www.schemastore.org
				schemas = {
					{
						description = "TypeScript compiler configuration file",
						fileMatch = { "tsconfig.json", "tsconfig.*.json" },
						url = "https://json.schemastore.org/tsconfig.json",
					},
					{
						description = "Babel configuration",
						fileMatch = { ".babelrc.json", ".babelrc", "babel.config.json" },
						url = "https://json.schemastore.org/babelrc.json",
					},
					{
						description = "ESLint config",
						fileMatch = { ".eslintrc.json", ".eslintrc" },
						url = "https://json.schemastore.org/eslintrc.json",
					},
					{
						description = "Bucklescript config",
						fileMatch = { "bsconfig.json" },
						url = "https://raw.githubusercontent.com/rescript-lang/rescript-compiler/master/docs/docson/build-schema.json",
					},
					{
						description = "Prettier config",
						fileMatch = {
							".prettierrc",
							".prettierrc.json",
							"prettier.config.json",
						},
						url = "https://json.schemastore.org/prettierrc.json",
					},
				},
			},
		},
		rust_analyzer = {
			on_attach = on_attach,
			capabilities = lsp_cmp.update_capabilities(lsp_capabilities),
			settings = {
				["rust-analyzer"] = {
            assist = {
                importGranularity = "module",
                importPrefix = "by_self",
            },
            cargo = {
                loadOutDirsFromCheck = true
            },
						checkOnSave = {
							command = "clippy"
						},
            procMacro = {
                enable = true
            },
        }
			},
		},
		sumneko_lua = {
			on_attach = on_attach,
			capabilities = lsp_cmp.update_capabilities(lsp_capabilities),
			settings = {
				Lua = {
					diagnostics = {
						-- The Lua language server is only being used for Neovim stuff,
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
		tsserver = {
			on_attach = function(client, bufnr)
				vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
				client.resolved_capabilities.document_formatting = false
			end,
			capabilities = lsp_cmp.update_capabilities(lsp_capabilities),
			commands = {
				OrganizeImports = {
					organize_imports,
					description = "Organize Imports",
				},
			},
			-- root_dir = function(fname)
			-- 	return not require("lspconfig").util.root_pattern("deno.json")(fname)
			-- end,
		},
		yamlls = {
			on_attach = on_attach,
			capabilities = lsp_cmp.update_capabilities(lsp_capabilities),
			settings = {
				yaml = {
					-- Schemas https://www.schemastore.org
					schemas = {
						["https://yarnpkg.com/configuration/yarnrc.json"] = {
							".yarnrc.yml",
						},
						["https://json.schemastore.org/circleciconfig.json"] = ".circleci/**/*.{yml,yaml}",
					},
				},
			},
		},
	}

	for server, server_setup in next, servers, nil do
		print("Registering server: " .. server)
		local server_available, requested_server = lsp_installer_servers.get_server(
			server
		)
		if server_available then
			requested_server:on_ready(function()
				requested_server:setup(server_setup)
			end)

			if not requested_server:is_installed() then
				-- Queue the server to be installed
				requested_server:install()
			end
		end
	end

	vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
		vim.lsp.diagnostic.on_publish_diagnostics,
		{
			-- underline
			underline = true,
			-- virtual text
			virtual_text = true,
			-- signs
			signs = true,
			-- delay update diagnostics
			update_in_insert = false,
		}
	)
end

return M
