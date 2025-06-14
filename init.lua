--  NOTE: remaps and sets must happen before plugins are loaded (otherwise wrong leader will be used)
require("nezudevv")
-- vim.lsp.set_log_level("debug")
-- vim.lsp.set_logging_file("/tmp/nvim_lsp_debug.log") -- Use this specific path

-- Neovide Specific Config
vim.g.neovide_cursor_vfx_mode = "pixiedust"
vim.g.neovide_scale_factor = 1.1
vim.g.neovide_refresh_rate = 120


vim.diagnostic.config({ virtual_text = true })
