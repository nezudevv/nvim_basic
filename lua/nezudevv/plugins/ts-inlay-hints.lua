local SymbolKind = vim.lsp.protocol.SymbolKind

return {
    -- lsp-lens.nvim (your existing config)
    {
        "VidocqH/lsp-lens.nvim",
        lazy = false, -- Or a specific event if you prefer
        opts = {
            enable = true,
            include_declaration = false,
            sections = {
                definition = false,
                references = true,
                implements = true,
                git_authors = true,
            },
            ignore_filetype = {
                "prisma",
            },
            target_symbol_kinds = { SymbolKind.Function, SymbolKind.Method, SymbolKind.Interface },
            wrapper_symbol_kinds = { SymbolKind.Class, SymbolKind.Struct },
        },
    },

    -- litee.nvim (ensure this is loaded before litee-calltree.nvim)
    {
        "ldelossa/litee.nvim",
        event = "VeryLazy", -- This is generally fine, but if you have issues, try 'LspAttach'
        opts = {
            notify = { enabled = false },
            panel = {
                orientation = "bottom",
                panel_size = 10,
            },
        },
        config = function(_, opts)
            require("litee.lib").setup(opts)
        end,
    },

    -- litee-calltree.nvim (this is the key)
    {
        "ldelossa/litee-calltree.nvim",
        dependencies = { "ldelossa/litee.nvim" }, -- Correctly specified as a table
        event = "VeryLazy", -- Use 'VeryLazy' or 'LspAttach' based on your preference
        opts = {
            on_open = "panel",
            map_resize_keys = false,
        },
        config = function(_, opts)
            require("litee.calltree").setup(opts)

            -- Keymaps are still useful for convenience, even if the direct LSP calls work.
            -- You can decide if you want these or just rely on the LSP calls directly.
            vim.keymap.set("n", "<leader>ci", "<cmd>lua vim.lsp.buf.incoming_calls()<CR>", { desc = "Show Incoming Calls (Calltree)" })
            vim.keymap.set("n", "<leader>co", "<cmd>lua vim.lsp.buf.outgoing_calls()<CR>", { desc = "Show Outgoing Calls (Calltree)" })
            -- Or a toggle that might decide for you
            -- vim.keymap.set("n", "<leader>ct", "<cmd>LiteeCalltreeToggle<CR>", { desc = "Toggle Call Tree" })
        end,
    },
}
