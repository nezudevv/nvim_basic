return {
	"supermaven-inc/supermaven-nvim",
	lazy = false,
	config = function()
		require("supermaven-nvim").setup({
			keymaps = {
				accept_suggestion = "<C-CR>",
				clear_suggestion = "<C-]>",
				accept_word = "<C-j>",
			},
			color = {
				cterm = 244,
			},
			log_level = "info",
			disable_inline_completion = false,
			disable_keymaps = false,
		})
	end,
}
