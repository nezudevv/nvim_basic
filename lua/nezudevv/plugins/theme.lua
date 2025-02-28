return {
	-- themes
	"rebelot/kanagawa.nvim",
	config = function()
		require("kanagawa").setup({
			background = { -- map the value of 'background' option to a theme
				dark = "dragon", -- try "dragon" !
			},
		})
		vim.cmd("colorscheme kanagawa")
	end,
	-- {
	-- 	"dgox16/oldworld.nvim",
	-- 	config = function()
	-- 		require("oldworld").setup({
	-- 			styles = {
	-- 				booleans = { italic = false },
	-- 				comments = { italic = true }, -- style for comments
	-- 				keywords = { italic = false }, -- style for keywords
	-- 				identifiers = { italic = false }, -- style for identifiers
	-- 				functions = { italic = false }, -- style for functions
	-- 				variables = { italic = false }, -- style for variables
	-- 			},
	-- 		})
	-- 	end,
	-- 	lazy = false,
	-- 	priority = 1000,
	-- 	init = function()
	-- 		vim.cmd.colorscheme("oldworld")
	-- 	end,
	-- },
}
-- {
-- 	"nyoom-engineering/oxocarbon.nvim",
-- 	init = function()
-- 		-- theme
-- 		vim.opt.background = "dark" -- set this to dark or light
-- 		vim.cmd("colorscheme oxocarbon")
-- 		-- -- transparent
-- 		-- vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
-- 		-- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
-- 		-- vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
-- 	end,
-- 	-- Add in any other configuration;
-- 	--
-- 	--   event = foo,
-- 	--   config = bar
-- 	--   end,
-- },
-- { -- You can easily change to a different colorscheme.
-- 	-- Change the name of the colorscheme plugin below, and then
-- 	-- change the command in the config to whatever the name of that colorscheme is.
-- 	--
-- 	-- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
-- 	"sainnhe/sonokai",
-- 	priority = 1000, -- Make sure to load this before all the other start plugins.
-- 	init = function()
-- 		-- Load the colorscheme here.
-- 		-- Like many other themes, this one has different styles, and you could load
-- 		-- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
-- 		vim.cmd.colorscheme("sonokai")
--
-- 		-- You can configure highlights by doing something like:
-- 		vim.cmd.hi("Comment gui=none")
-- 	end,
-- },
