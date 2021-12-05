local M = {}

M.config = function ()
	local lsp = require("lspconfig")
	local lsp_installer_servers = require("nvim-lsp-installer.servers")
	local lsp_cmp = require("cmp_nvim_lsp")
	-- specialised setup for specific lsps
	-- local lsp_rust_helper = require("rust-tools")

	local on_attach = function(_, bufnr)
		vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

		vim.cmd [[ command! Format execute "lua vim.lsp.buf.formatting()" ]]
	end

	local lsp_capabilities = vim.lsp.protocol.make_client_capabilities()
	lsp_capabilities.textDocument.completion.completionItem.snippetSupport = true

	local servers = {
		"cssls",
		"denols",
		"html",
		"jsonls",
		"sumneko_lua",
		"tsserver",
		"yamlls"
	}

	local function organize_imports()
		local params = {
			command = "_typescript.organizeImports",
			arguments = {vim.api.nvim_buf_get_name(0)},
			title = ""
		}
		vim.lsp.buf.execute_command(params)
	end

	local json_schemas = {
		{
			description = 'TypeScript compiler configuration file',
			fileMatch = {'tsconfig.json', 'tsconfig.*.json'},
			url = 'http://json.schemastore.org/tsconfig'
		},
		{
			description = 'Lerna config',
			fileMatch = {'lerna.json'},
			url = 'http://json.schemastore.org/lerna'
		},
		{
			description = 'Babel configuration',
			fileMatch = {'.babelrc.json', '.babelrc', 'babel.config.json'},
			url = 'http://json.schemastore.org/lerna'
		},
		{
			description = 'ESLint config',
			fileMatch = {'.eslintrc.json', '.eslintrc'},
			url = 'http://json.schemastore.org/eslintrc'
		},
		{
			description = 'Bucklescript config',
			fileMatch = {'bsconfig.json'},
			url = 'https://bucklescript.github.io/bucklescript/docson/build-schema.json'
		},
		{
			description = 'Prettier config',
			fileMatch = {'.prettierrc', '.prettierrc.json', 'prettier.config.json'},
			url = 'http://json.schemastore.org/prettierrc'
		},
		{
			description = 'Vercel Now config',
			fileMatch = {'now.json'},
			url = 'http://json.schemastore.org/now'
		},
		{
			description = 'Stylelint config',
			fileMatch = {'.stylelintrc', '.stylelintrc.json', 'stylelint.config.json'},
			url = 'http://json.schemastore.org/stylelintrc'
		},
	}

	for _, server in ipairs(servers) do
		local server_available, requested_server = lsp_installer_servers.get_server(server)
		if server_available then
			requested_server:on_ready(function ()
				if server == "sumneko_lua" then
					requested_server:setup({
						on_attach = on_attach,
						capabilities = lsp_cmp.update_capabilities(lsp_capabilities),
						settings = {
							Lua = {
								diagnostics = {
									-- The Lua language server is only being used for Neovim stuff,
									-- globals listed relate to Neovim development.
									globals = { 'use', 'vim' },
								},
								workspace = {
									-- Make the server aware of Neovim runtime files
									library = vim.api.nvim_get_runtime_file('', true),
								},
							},
						},
					})
				elseif server == "jsonls" then
					requested_server:setup({
						on_attach = on_attach,
						capabilities = lsp_cmp.update_capabilities(lsp_capabilities),
						flags = {
							debounce_text_changes = 150,
						},
						json = {
							schemas = json_schemas,
						},
					})
				elseif server == "tsserver" then
					requested_server:setup({
						on_attach = on_attach,
						capabilities = lsp_cmp.update_capabilities(lsp_capabilities),
						commands = {
							OrganizeImports = {
								organize_imports,
								description = "Organize Imports"
							}
						},
						root_dir = require("lspconfig").util.root_pattern("package.json"),
					})
				elseif server == "denols" then
					requested_server:setup({
						on_attach = on_attach,
						capabilities = lsp_cmp.update_capabilities(lsp_capabilities),
						init_options = {
							lint = true,
						},
						root_dir = require("lspconfig").util.root_pattern("deno.json"),
					})
				else
					requested_server:setup({
						on_attach = on_attach,
						capabilities = lsp_cmp.update_capabilities(lsp_capabilities),
						flags = {
							debounce_text_changes = 150,
						},
					})
				end
			end)
			if not requested_server:is_installed() then
				-- Queue the server to be installed
				requested_server:install()
			end
		end
	end

	vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
		vim.lsp.diagnostic.on_publish_diagnostics, {
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
