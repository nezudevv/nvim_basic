return {
	"pmizio/typescript-tools.nvim",
	lazy = true,
	dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
	opts = {
		settings = {
			tsserver = {
				logVerbosity = "verbose",
			},
		},
	},
	ft = {
		"typescript",
		-- "typescriptreact", -- TypeScript
		"javascript",
		-- "javascriptreact", -- JavaScript
		"vue",
		"html", -- Vue & AngularJS
	},
}
