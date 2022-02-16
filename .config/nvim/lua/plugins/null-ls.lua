local null_ls = require "null-ls"

null_ls.setup {
	on_attach = function(client, bufnr)
		if client.resolved_capabilities.document_formatting then
			vim.keymap.set("n", "<Leader>f", "<Cmd>lua vim.lsp.buf.formatting_seq_sync()<Cr>", { buffer = bufnr })
			-- vim.api.nvim_command [[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_seq_sync()]]
		end
	end,
	sources = {
		null_ls.builtins.formatting.stylua,
		-- null_ls.builtins.formatting.prettier,
		null_ls.builtins.formatting.deno_fmt.with({
			filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "json", "jsonc", "markdown" },
			extra_args = { "--options-use-tabs", true },
		}),
		null_ls.builtins.diagnostics.eslint,
	},
}
