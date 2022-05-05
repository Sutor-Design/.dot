local lsp = vim.lsp
-- local lsp_installer = require "nvim-lsp-installer"
local lsp_installer_servers = require "nvim-lsp-installer.servers"
local lsp_cmp = require "cmp_nvim_lsp"
local schemastore = require "schemastore"


local lsp_capabilities = lsp.protocol.make_client_capabilities()
lsp_capabilities.textDocument.completion.completionItem.snippetSupport = true

local on_attach = function(client, bufnr)
	vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

	local opts = { buffer = bufnr }
	-- stylua: ignore start
	vim.keymap.set("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts)
	vim.keymap.set("n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)
	vim.keymap.set("n", "<space>k", "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
	vim.keymap.set("n", "gi", "<Cmd>lua vim.lsp.buf.implementation()<CR>", opts)
	vim.keymap.set("n", "<C-k>", "<Cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
	vim.keymap.set("n", "<Leader>wa", "<Cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
	vim.keymap.set("n", "<Leader>wr", "<Cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
	vim.keymap.set("n", "<Leader>wl", "<Cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts)
	vim.keymap.set("n", "<Leader>D", "<Cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
	vim.keymap.set("n", "<Leader>rn", "<Cmd>lua vim.lsp.buf.rename()<CR>", opts)
	vim.keymap.set("n", "gr", "<Cmd>lua vim.lsp.buf.references()<CR>", opts)
	vim.keymap.set("n", "<Leader>ca", "<Cmd>lua vim.lsp.buf.code_action()<CR>", opts)
	vim.keymap.set("v", "<Leader>ca", "<Cmd>lua vim.lsp.buf.range_code_action()<CR>", opts)
	vim.keymap.set("n", "<Leader>e", "<Cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", opts)
	vim.keymap.set("n", "[d", "<Cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", opts)
	vim.keymap.set("n", "]d", "<Cmd>lua vim.lsp.diagnostic.goto_next()<CR>", opts)
	vim.keymap.set("n", "<Leader>q", "<Cmd>lua vim.lsp.diagnostic.set_loclist()<CR>", opts)
	vim.keymap.set("n", "<Leader>so", [[<Cmd>lua require("telescope.builtin").lsp_document_symbols()<CR>]], opts)
	-- stylua: ignore end
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
	eslint = {
		on_attach = on_attach,
		capabilities = lsp_cmp.update_capabilities(lsp_capabilities),
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
	jsonls = {
		on_attach = on_attach,
		capabilities = lsp_cmp.update_capabilities(lsp_capabilities),
		settings = {
			json = {
				schemas = schemastore.json.schemas(),
			},
		}
	},
	sumneko_lua = {
		on_attach = on_attach,
		capabilities = lsp_cmp.update_capabilities(lsp_capabilities),
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
	tailwindcss = {
		on_attach = on_attach,
		capabilities = lsp_cmp.update_capabilities(lsp_capabilities),
	},
	tsserver = {
		on_attach = on_attach,
		capabilities = lsp_cmp.update_capabilities(lsp_capabilities),
		commands = {
			OrganizeImports = {
				organize_imports,
				description = "Organize Imports",
			},
		},
	},
}

for server, server_setup in next, servers, nil do
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
