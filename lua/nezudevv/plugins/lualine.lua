return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("lualine").setup({
			sections = {
				lualine_a = {},
				lualine_b = { "mode", "branch", "diff", "diagnostics" },
				lualine_c = {},
				lualine_x = { "encoding", "fileformat" },
				lualine_y = { "location" },
				lualine_z = {},
				-- lualine_c = { "filename" },
				-- lualine_x = { "encoding", "fileformat", "filetype" },
				-- lualine_y = { "progress" },
			},
			tabline = {
				lualine_a = { "buffers" },
				lualine_b = {},
				lualine_c = {},
				lualine_x = {},
				lualine_y = {},
				lualine_z = { "tabs" },
			},
		})
	end,
}
