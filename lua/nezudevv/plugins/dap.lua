local js_based_languages = {
	"typescript",
	"javascript",
	"typescriptreact",
	"javascriptreact",
	"vue",
}

return {
	-- NOTE: Yes, you can install new plugins here!
	"mfussenegger/nvim-dap",
	-- NOTE: And you can specify dependencies as well
	dependencies = {
		-- Creates a beautiful debugger UI
		"rcarriga/nvim-dap-ui",

		-- Required dependency for nvim-dap-ui
		"nvim-neotest/nvim-nio",

		-- Installs the debug adapters for you
		"williamboman/mason.nvim",
		"jay-babu/mason-nvim-dap.nvim",
		"microsoft/vscode-js-debug",

		-- Add your own debuggers here
		-- "leoluz/nvim-dap-go",
	},
	keys = function(_, keys)
		local dap = require("dap")
		local dapui = require("dapui")
		return {
			-- Basic debugging keymaps, feel free to change to your liking!
			{ "<F5>", dap.continue, desc = "Debug: Start/Continue" },
			{ "<F1>", dap.step_into, desc = "Debug: Step Into" },
			{ "<F2>", dap.step_over, desc = "Debug: Step Over" },
			{ "<F3>", dap.step_out, desc = "Debug: Step Out" },
			{
				"<leader>da",
				function()
					if vim.fn.filereadable(".vscode/launch.json") then
						local dap_vscode = require("dap.ext.vscode")
						dap_vscode.load_launchjs(nil, {
							["pwa-node"] = js_based_languages,
							["chrome"] = js_based_languages,
							["pwa-chrome"] = js_based_languages,
						})
					end
					require("dap").continue()
				end,
				desc = "Run with Args",
			},

			{ "<leader>db", dap.toggle_breakpoint, desc = "Debug: Toggle Breakpoint" },
			{
				"<leader>dB",
				function()
					dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
				end,
				desc = "Debug: Set Breakpoint",
			},
			-- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
			{ "<F7>", dapui.toggle, desc = "Debug: See last session result." },
			unpack(keys),
		}
	end,
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		require("mason-nvim-dap").setup({
			-- Makes a best effort to setup the various debuggers with
			-- reasonable debug configurations
			automatic_installation = true,

			-- You can provide additional configuration to the handlers,
			-- see mason-nvim-dap README for more information
			handlers = {},

			-- You'll need to check that you have the required things installed
			-- online, please don't ask me how to install them :)
			ensure_installed = {
				-- Update this to ensure that you have the debuggers for the langs you want
				-- "delve",
				"pwa-node",
			},
		})

		-- Dap UI setup
		-- For more information, see |:help nvim-dap-ui|
		dapui.setup({
			-- Set icons to characters that are more likely to work in every terminal.
			--    Feel free to remove or use ones that you like more! :)
			--    Don't feel like these are good choices.
			floating = {
				max_height = nil, -- Use default max height
				max_width = nil, -- Use default max width
				border = "rounded", -- Rounded borders for popups
				mappings = {
					close = { "q", "<Esc>" },
				},
			},
			layouts = {
				{
					elements = {
						{ id = "scopes", size = 0.25 },
						{ id = "breakpoints", size = 0.25 },
						{ id = "stacks", size = 0.25 },
						{ id = "watches", size = 0.25 },
					},
					size = 40,
					position = "left", -- Can be "left" or "right"
				},
				{
					elements = {
						{ id = "repl", size = 0.5 },
						{ id = "console", size = 0.5 },
					},
					size = 10,
					position = "bottom", -- Can be "top" or "bottom"
				},
			},
			force_buffers = true,
			render = {
				max_type_length = nil, -- Use default length
				indent = 1,
			},
			element_mappings = {},
			mappings = {},
			expand_lines = true,
			icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
			controls = {
				enabled = true,
				element = "repl",
				icons = {
					pause = "⏸",
					play = "▶",
					step_into = "⏎",
					step_over = "⏭",
					step_out = "⏮",
					step_back = "b",
					run_last = "▶▶",
					terminate = "⏹",
					disconnect = "⏏",
				},
			},
		})

		-- 				-- Debug nodejs processes (make sure to add --inspect when you run the process)

		local dap_vscode = require("dap.ext.vscode") -- ✅ Fix: Define dap_vscode inside config
		-- ✅ Fix: Load launch.json if available
		if vim.fn.filereadable(".vscode/launch.json") == 1 then
			dap_vscode.load_launchjs(nil, {
				["pwa-node"] = js_based_languages,
				["chrome"] = js_based_languages,
				["pwa-chrome"] = js_based_languages,
			})
			print("Loaded VSCode launch.json")
		end

		-- ✅ Fix: Extract Port from Launch Configurations
		local function get_debug_port()
			-- Read the VSCode launch.json configurations
			if vim.fn.filereadable(".vscode/launch.json") == 1 then
				local launch_config = dap_vscode.load_launchjs(nil, {
					["pwa-node"] = js_based_languages,
					["chrome"] = js_based_languages,
					["pwa-chrome"] = js_based_languages,
				})

				-- Try to find a port in the launch configurations
				for _, config in pairs(launch_config) do
					if config.port then
						return tonumber(config.port)
					end
				end
			end

			-- Default to 9229 if no port is found
			return 9229
		end

		-- ✅ Fix: Dynamically Determine the Port Instead of Using `config.port`
		dap.adapters["pwa-node"] = function(callback, config)
			local port = get_debug_port() -- Get the port from launch.json or fallback

			if config and type(config) == "table" then
				if config.processId then
					port = tonumber(config.processId) -- Attach to process ID
				elseif config.args and type(config.args) == "table" then
					for _, arg in ipairs(config.args) do
						local matched_port = string.match(arg, "--inspect%-port=(%d+)")
						if matched_port then
							port = tonumber(matched_port)
							break
						end
					end
				end
			end

			-- ✅ Ensure `port` is a valid number
			if type(port) ~= "number" then
				print("Invalid port detected, defaulting to 9229")
				port = 9229
			end

			callback({
				type = "server",
				host = "localhost",
				port = port,
				executable = {
					command = "node",
					args = {
						vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
						"${port}",
					},
				},
			})
		end

		-- Attach to the correct process dynamically
		dap.configurations.javascript = {
			{
				type = "pwa-node",
				request = "attach",
				name = "Attach to Process",
				processId = require("dap.utils").pick_process,
				cwd = vim.fn.getcwd(),
				sourceMaps = true,
				before = function()
					if vim.fn.filereadable(".vscode/launch.json") == 1 then
						dap_vscode.load_launchjs(nil, {
							["pwa-node"] = js_based_languages,
							["chrome"] = js_based_languages,
							["pwa-chrome"] = js_based_languages,
						})
						print("Loaded VSCode launch.json")
					end
				end,
			},
		}

		dap.listeners.after.event_initialized["dapui_config"] = dapui.open
		dap.listeners.before.event_terminated["dapui_config"] = dapui.close
		dap.listeners.before.event_exited["dapui_config"] = dapui.close

		-- Install golang specific config
		-- require("dap-go").setup({
		-- 	delve = {
		-- 		-- On Windows delve must be run attached or it crashes.
		-- 		-- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
		-- 		detached = vim.fn.has("win32") == 0,
		-- 	},
		-- })
	end,
}

-- config from youtube video, that seems to work but not sure how to make it work outside of lazy distro
-- { "nvim-neotest/nvim-nio" },
-- {
-- 	"mfussenegger/nvim-dap",
-- 	config = function()
-- 		local dap = require("dap")
--
-- 		-- local Config = require("lazyvim.config")
-- 		vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
--
-- 		-- for name, sign in pairs(Config.icons.dap) do
-- 		-- 	sign = type(sign) == "table" and sign or { sign }
-- 		-- 	vim.fn.sign_define(
-- 		-- 		"Dap" .. name,
-- 		-- 		{ text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
-- 		-- 	)
-- 		-- end
--
-- 		for _, language in ipairs(js_based_languages) do
-- 			dap.configurations[language] = {
-- 				-- Debug single nodejs files
-- 				{
-- 					type = "pwa-node",
-- 					request = "launch",
-- 					name = "Launch file",
-- 					program = "${file}",
-- 					cwd = vim.fn.getcwd(),
-- 					sourceMaps = true,
-- 				},
-- 				-- Debug nodejs processes (make sure to add --inspect when you run the process)
-- 				{
-- 					type = "pwa-node",
-- 					request = "attach",
-- 					name = "Attach",
-- 					processId = require("dap.utils").pick_process,
-- 					cwd = vim.fn.getcwd(),
-- 					sourceMaps = true,
-- 				},
-- 				-- Debug web applications (client side)
-- 				{
-- 					type = "pwa-chrome",
-- 					request = "launch",
-- 					name = "Launch & Debug Chrome",
-- 					url = function()
-- 						local co = coroutine.running()
-- 						return coroutine.create(function()
-- 							vim.ui.input({
-- 								prompt = "Enter URL: ",
-- 								default = "http://localhost:3000",
-- 							}, function(url)
-- 								if url == nil or url == "" then
-- 									return
-- 								else
-- 									coroutine.resume(co, url)
-- 								end
-- 							end)
-- 						end)
-- 					end,
-- 					webRoot = vim.fn.getcwd(),
-- 					protocol = "inspector",
-- 					sourceMaps = true,
-- 					userDataDir = false,
-- 				},
-- 				-- Divider for the launch.json derived configs
-- 				{
-- 					name = "----- ↓ launch.json configs ↓ -----",
-- 					type = "",
-- 					request = "launch",
-- 				},
-- 			}
-- 		end
-- 	end,
-- 	keys = {
-- 		{
-- 			"<leader>db",
-- 			function()
-- 				require("dap").toggle_breakpoint()
-- 			end,
-- 			desc = "Step Out",
-- 		},
-- 		{
-- 			"<leader>dO",
-- 			function()
-- 				require("dap").step_out()
-- 			end,
-- 			desc = "Step Out",
-- 		},
-- 		{
-- 			"<leader>do",
-- 			function()
-- 				require("dap").step_over()
-- 			end,
-- 			desc = "Step Over",
-- 		},
-- 		{
-- 			"<leader>da",
-- 			function()
-- 				if vim.fn.filereadable(".vscode/launch.json") then
-- 					local dap_vscode = require("dap.ext.vscode")
-- 					dap_vscode.load_launchjs(nil, {
-- 						["pwa-node"] = js_based_languages,
-- 						["chrome"] = js_based_languages,
-- 						["pwa-chrome"] = js_based_languages,
-- 					})
-- 				end
-- 				require("dap").continue()
-- 			end,
-- 			desc = "Run with Args",
-- 		},
-- 	},
-- 	dependencies = {
-- 		-- Install the vscode-js-debug adapter
-- 		{
-- 			"microsoft/vscode-js-debug",
-- 			-- After install, build it and rename the dist directory to out
-- 			build = "npm install --legacy-peer-deps --no-save && npx gulp vsDebugServerBundle && rm -rf out && mv dist out",
-- 			version = "1.*",
-- 		},
-- 		{
-- 			"mxsdev/nvim-dap-vscode-js",
-- 			config = function()
-- 				---@diagnostic disable-next-line: missing-fields
-- 				require("dap-vscode-js").setup({
-- 					-- Path of node executable. Defaults to $NODE_PATH, and then "node"
-- 					-- node_path = "node",
--
-- 					-- Path to vscode-js-debug installation.
-- 					debugger_path = vim.fn.resolve(vim.fn.stdpath("data") .. "/lazy/vscode-js-debug"),
--
-- 					-- Command to use to launch the debug server. Takes precedence over "node_path" and "debugger_path"
-- 					-- debugger_cmd = { "js-debug-adapter" },
--
-- 					-- which adapters to register in nvim-dap
-- 					adapters = {
-- 						"chrome",
-- 						"pwa-node",
-- 						"pwa-chrome",
-- 						"pwa-msedge",
-- 						"pwa-extensionHost",
-- 						"node-terminal",
-- 					},
--
-- 					-- Path for file logging
-- 					-- log_file_path = "(stdpath cache)/dap_vscode_js.log",
--
-- 					-- Logging level for output to file. Set to false to disable logging.
-- 					-- log_file_level = false,
--
-- 					-- Logging level for output to console. Set to false to disable console output.
-- 					-- log_console_level = vim.log.levels.ERROR,
-- 				})
-- 			end,
-- 		},
-- {
-- 	"Joakker/lua-json5",
-- 	build = "./install.sh",
-- },
-- },
-- },
