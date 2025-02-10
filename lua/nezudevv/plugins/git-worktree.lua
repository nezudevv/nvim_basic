return {
	"ThePrimeagen/git-worktree.nvim",
	config = function()
		local Worktree = require("git-worktree")
		-- Add hooks
		Worktree.on_tree_change(function(op, metadata)
			if op == Worktree.Operations.Create then
				print("Switched to worktree: " .. metadata.path)

				-- Add a delay of 2 seconds (2000 milliseconds)
				vim.defer_fn(function()
					print("Running setup after delay...")
					-- Mapping for shared .env files
					local env_mappings = {
						["es-sync"] = "~/shared-envs/es-sync.env",
						["event-broker"] = "~/shared-envs/event-broker.env",
						["event-worker"] = "~/shared-envs/event-worker.env",
						nucleus = "~/shared-envs/nucleus.env",
						["rates-service"] = "~/shared-envs/rates-service.env",
						root = "~/shared-envs/root.env",
						["vendor-routing"] = "~/shared-envs/vendor-routing.env",
						web = "~/shared-envs/web.env",
						webvue = "~/shared-envs/webvue.env",
					}

					for app, shared_env in pairs(env_mappings) do
						shared_env = vim.fn.expand(shared_env) -- Expand tilde (~)
						print(string.format("Using shared .env file: %s", shared_env))

						-- Correct target path for symlink inside services/{app}
						local target_path
						if app == "nucleus" then
							target_path = string.format("services/nucleus/nestjs/.env")
						elseif app == "root" then
							target_path = string.format(".env")
						else
							target_path = string.format("services/%s/.env", app)
						end

						-- Check if the target directory exists
						local target_dir = vim.fn.fnamemodify(target_path, ":h") -- Extract target directory
						local dir_exists = vim.fn.isdirectory(target_dir) == 1

						if dir_exists then
							-- Create the symlink
							local symlink_command = string.format("ln -sf %s %s", shared_env, target_path)
							print(string.format("Executing symlink command: %s", symlink_command))
							local symlink_result = os.execute(symlink_command)

							-- Verify symlink creation
							if symlink_result then
								print(string.format("Symlinked %s to %s", shared_env, target_path))
								os.execute(string.format("ls -l %s", target_path)) -- Debugging output
							else
								print(string.format("Failed to create symlink for %s", app))
							end
						else
							print(
								string.format("Skipping symlink for %s: Directory %s does not exist", app, target_dir)
							)
						end
					end
				end, 2000) -- Delay of 2000 milliseconds (2 seconds)

				-- Run startdev.sh script
				local startdev_path = string.format("/startdev.sh")
				if vim.fn.filereadable(startdev_path) == 1 then
					print("Running startdev.sh...")
					local startdev_command = string.format("bash %s", startdev_path)
					local startdev_result = os.execute(startdev_command)

					if startdev_result then
						print("startdev.sh executed successfully.")
					else
						print("Failed to execute startdev.sh.")
					end
				else
					print("Skipping startdev.sh: File does not exist.")
				end
			end
		end)
	end,
}
