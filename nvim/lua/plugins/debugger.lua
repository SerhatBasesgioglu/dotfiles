return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"williamboman/mason.nvim",
		},
		config = function()
			local dap = require("dap")
			local ui = require("dapui")
			local dap_utils = require("dap.utils")
			dap.set_log_level("TRACE")
			local saved_cursorline = nil
			local debug_cursorline_active = false
			local dotnet_debug = {
				prefer_picker = true,
				search_glob = "**/*.csproj",
				remember_last = true,
				urls = "http://localhost:55001",
			}
			local last_csproj = nil
			local pre_debug_winrestcmd = nil

			require("dapui").setup()

			vim.api.nvim_set_hl(0, "DapStoppedLine", { bg = "#2a2f42" })
			dap.defaults.fallback.force_external_terminal = false

			pcall(vim.fn.sign_define, "DapStopped", {
				text = "▶",
				texthl = "DiagnosticInfo",
				linehl = "DapStoppedLine",
				numhl = "DiagnosticInfo",
			})

			local function set_debug_cursorline(enabled)
				if enabled then
					if not debug_cursorline_active then
						saved_cursorline = vim.wo.cursorline
						vim.wo.cursorline = true
						debug_cursorline_active = true
					end
				else
					if debug_cursorline_active then
						if saved_cursorline ~= nil then
							vim.wo.cursorline = saved_cursorline
						end
						saved_cursorline = nil
						debug_cursorline_active = false
					end
				end
			end

			local function find_csproj(start_dir)
				local dir = start_dir
				while dir and dir ~= "" do
					local matches = vim.fn.globpath(dir, "*.csproj", false, true)
					if #matches > 0 then
						table.sort(matches)
						return matches[1]
					end

					local parent = vim.fs.dirname(dir)
					if parent == dir then
						break
					end
					dir = parent
				end

				local cwd_matches = vim.fn.globpath(vim.fn.getcwd(), "**/*.csproj", false, true)
				if #cwd_matches > 0 then
					table.sort(cwd_matches)
					return cwd_matches[1]
				end

				return nil
			end

			local function find_all_csprojs()
				local matches = vim.fn.globpath(vim.fn.getcwd(), dotnet_debug.search_glob, false, true)
				if #matches == 0 then
					return matches
				end

				table.sort(matches)
				local deduped = {}
				local seen = {}
				for _, path in ipairs(matches) do
					local abs = vim.fn.fnamemodify(path, ":p")
					if not seen[abs] then
						seen[abs] = true
						table.insert(deduped, abs)
					end
				end

				return deduped
			end

			local function is_runnable_csproj(csproj)
				local lines = vim.fn.readfile(csproj)
				local content = table.concat(lines, "\n")
				if content:match('<Project%s+Sdk="Microsoft%.NET%.Sdk%.Web"') then
					return true
				end
				local output_type = content:match("<OutputType>%s*([^<]+)%s*</OutputType>")
				if output_type and output_type:lower() == "exe" then
					return true
				end
				return false
			end

			local function pick_csproj(on_done)
				local projects = find_all_csprojs()
				if #projects == 0 then
					on_done(nil)
					return
				end

				local runnable = {}
				for _, project in ipairs(projects) do
					if is_runnable_csproj(project) then
						table.insert(runnable, project)
					end
				end

				if #runnable > 0 then
					projects = runnable
				end

				vim.ui.select(projects, {
					prompt = "Select .csproj to debug",
					format_item = function(item)
						return vim.fn.fnamemodify(item, ":.")
					end,
				}, function(choice)
					on_done(choice)
				end)
			end

			local function get_project_info(csproj)
				local lines = vim.fn.readfile(csproj)
				local content = table.concat(lines, "\n")

				local tfm = content:match("<TargetFramework>%s*([^<]+)%s*</TargetFramework>")
				if not tfm then
					local tfms = content:match("<TargetFrameworks>%s*([^<]+)%s*</TargetFrameworks>")
					if tfms then
						tfm = vim.split(tfms, ";")[1]
					end
				end

				tfm = tfm or "net8.0"

				local assembly_name = content:match("<AssemblyName>%s*([^<]+)%s*</AssemblyName>")
				if not assembly_name or assembly_name == "" then
					assembly_name = vim.fn.fnamemodify(csproj, ":t:r")
				end

				local project_dir = vim.fn.fnamemodify(csproj, ":h")
				local dll = string.format("%s/bin/Debug/%s/%s.dll", project_dir, tfm, assembly_name)

				return {
					project_dir = project_dir,
					dll = dll,
					assembly_name = assembly_name,
				}
			end

			dap.adapters.coreclr = {
				type = "executable",
				command = (function()
					local arm64_manual = vim.fn.expand("$HOME/tools/netcoredbg-arm64/netcoredbg/netcoredbg")
					if vim.fn.executable(arm64_manual) == 1 then
						return arm64_manual
					end

					local from_path = vim.fn.exepath("netcoredbg")
					if from_path ~= nil and from_path ~= "" then
						return from_path
					end

					return "netcoredbg"
				end)(),
				args = { "--interpreter=vscode" },
			}

			dap.adapters.python = {
				type = "executable",
				command = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python",
				args = { "-m", "debugpy.adapter" },
			}

			dap.configurations.cs = {
				{
					type = "coreclr",
					name = "Launch .NET (prompt)",
					request = "launch",
					program = function()
						return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
					end,
					args = { "--urls", dotnet_debug.urls },
					console = "integratedTerminal",
					internalConsoleOptions = "neverOpen",
					env = {
						ASPNETCORE_ENVIRONMENT = "Development",
						ASPNETCORE_URLS = dotnet_debug.urls,
					},
				},
				{
					type = "coreclr",
					name = "Attach to dotnet process",
					request = "attach",
					processId = function()
						return dap_utils.pick_process({ filter = "dotnet" })
					end,
					cwd = "${workspaceFolder}",
				},
			}

			dap.configurations.python = {
				{
					type = "python",
					name = "Launch current file",
					request = "launch",
					program = "${file}",
					cwd = "${workspaceFolder}",
					python = function()
						local root = vim.fs.root(0, { "pyproject.toml", ".venv", ".git" }) or vim.fn.getcwd()
						local venv_python = root .. "/.venv/bin/python"
						if vim.fn.executable(venv_python) == 1 then
							return venv_python
						end
						return "python3"
					end,
					console = "integratedTerminal",
				},
			}

			local function run_dotnet_project(csproj)
				if not csproj then
					vim.notify("No .csproj selected/found", vim.log.levels.ERROR)
					return
				end

				if dotnet_debug.remember_last then
					last_csproj = csproj
				end

				local netcoredbg_cmd = dap.adapters.coreclr.command
				if vim.fn.executable(netcoredbg_cmd) ~= 1 then
					vim.notify(
						"netcoredbg not found. Install with :MasonInstall netcoredbg",
						vim.log.levels.ERROR
					)
					return
				end

				local project_info = get_project_info(csproj)
				local build_cmd = {
					"dotnet",
					"build",
					csproj,
					"-c",
					"Debug",
					"-v",
					"minimal",
				}

				vim.notify("Building " .. vim.fn.fnamemodify(csproj, ":t") .. "...", vim.log.levels.INFO)

				vim.fn.jobstart(build_cmd, {
					cwd = project_info.project_dir,
					stdout_buffered = true,
					stderr_buffered = true,
					on_exit = function(_, code)
						if code == 0 then
							vim.schedule(function()
								if vim.fn.filereadable(project_info.dll) ~= 1 then
									vim.notify("Built dll not found: " .. project_info.dll, vim.log.levels.ERROR)
									return
								end
								vim.notify("Build succeeded. Starting debugger...", vim.log.levels.INFO)
								vim.notify("Debug target: " .. project_info.dll, vim.log.levels.INFO)
								dap.run({
									type = "coreclr",
									name = "Debug " .. project_info.assembly_name,
									request = "launch",
									program = project_info.dll,
									cwd = project_info.project_dir,
									args = { "--urls", dotnet_debug.urls },
									stopAtEntry = false,
									console = "integratedTerminal",
									internalConsoleOptions = "neverOpen",
									env = {
										ASPNETCORE_ENVIRONMENT = "Development",
										ASPNETCORE_URLS = dotnet_debug.urls,
									},
								})
							end)
						else
							vim.schedule(function()
								vim.notify("Build failed. Run :messages for details.", vim.log.levels.ERROR)
							end)
						end
					end,
				})
			end

			local function build_and_debug_dotnet(opts)
				opts = opts or {}
				local buf = vim.api.nvim_buf_get_name(0)
				local start_dir = buf ~= "" and vim.fn.fnamemodify(buf, ":p:h") or vim.fn.getcwd()
				local nearest_csproj = find_csproj(start_dir)

				if opts.use_last and last_csproj and vim.fn.filereadable(last_csproj) == 1 then
					run_dotnet_project(last_csproj)
					return
				end

				if opts.force_picker or dotnet_debug.prefer_picker then
					pick_csproj(function(choice)
						if choice and choice ~= "" then
							run_dotnet_project(choice)
						elseif nearest_csproj then
							run_dotnet_project(nearest_csproj)
						else
							vim.notify("No .csproj selected/found", vim.log.levels.ERROR)
						end
					end)
					return
				end

				if nearest_csproj then
					run_dotnet_project(nearest_csproj)
				else
					vim.notify("No .csproj found from current file/cwd", vim.log.levels.ERROR)
				end
			end

			local function stop_debugger()
				local function close_debug_ui_and_restore()
					pcall(ui.close)
					pcall(dap.repl.close)
					set_debug_cursorline(false)
					if pre_debug_winrestcmd and pre_debug_winrestcmd ~= "" then
						pcall(vim.cmd, pre_debug_winrestcmd)
						pre_debug_winrestcmd = nil
					end
					pcall(vim.cmd, "wincmd =")
				end

				close_debug_ui_and_restore()

				local sessions = dap.sessions()
				local count = vim.tbl_count(sessions)
				if count == 0 then
					vim.notify("No active debug session (UI closed)", vim.log.levels.WARN)
					return
				end

				for _, session in pairs(sessions) do
					pcall(function()
						session:request("disconnect", { terminateDebuggee = true }, function() end)
					end)
				end

				pcall(dap.terminate)
				vim.defer_fn(function()
					pcall(dap.disconnect, { terminateDebuggee = true })
					pcall(dap.close)
					close_debug_ui_and_restore()
				end, 100)
			end

			local function dap_status()
				local sessions = dap.sessions()
				local count = vim.tbl_count(sessions)
				local adapter_cmd = dap.adapters.coreclr and dap.adapters.coreclr.command or "(none)"
				local project = last_csproj and vim.fn.fnamemodify(last_csproj, ":.") or "(none)"
				vim.notify(
					string.format("DAP sessions=%d | adapter=%s | last=%s", count, adapter_cmd, project),
					count > 0 and vim.log.levels.INFO or vim.log.levels.WARN
				)
			end

			vim.keymap.set("n", "<space>b", dap.toggle_breakpoint)
			vim.keymap.set("n", "<space>gb", dap.run_to_cursor)

			-- Eval var under cursor
			vim.keymap.set("n", "<space>?", function()
				require("dapui").eval(nil, { enter = true })
			end)

			vim.keymap.set("n", "<F1>", build_and_debug_dotnet, { desc = "Build + Debug nearest .NET project" })
			vim.keymap.set("n", "<leader>dp", function()
				build_and_debug_dotnet({ force_picker = true })
			end, { desc = "Pick .NET project and debug" })
			vim.keymap.set("n", "<leader>dl", function()
				build_and_debug_dotnet({ use_last = true })
			end, { desc = "Debug last picked .NET project" })
			vim.keymap.set("n", "<leader>dd", function()
				dap.run(dap.configurations.python[1])
			end, { desc = "Debug current Python file" })
			vim.keymap.set("n", "<F2>", dap.step_into)
			vim.keymap.set("n", "<F3>", dap.step_over)
			vim.keymap.set("n", "<F4>", dap.step_out)
			vim.keymap.set("n", "<F5>", dap.continue)
			vim.keymap.set("n", "<F6>", stop_debugger, { desc = "Stop debugger" })
			vim.keymap.set("n", "<F13>", dap.restart)
			vim.keymap.set("n", "<leader>da", function()
				dap.run(dap.configurations.cs[2])
			end, { desc = "Attach to dotnet process" })
			vim.keymap.set("n", "<leader>ds", dap_status, { desc = "DAP status" })
			vim.api.nvim_create_user_command("DapStatus", dap_status, {})

			dap.listeners.after.event_initialized.dap_notify = function()
				vim.notify("Debugger attached", vim.log.levels.INFO)
			end
			dap.listeners.after.event_terminated.dap_notify = function()
				vim.notify("Debugger terminated", vim.log.levels.WARN)
			end
			dap.listeners.after.event_exited.dap_notify = function()
				vim.notify("Debuggee exited", vim.log.levels.WARN)
			end

			local function open_debug_ui()
				pre_debug_winrestcmd = vim.fn.winrestcmd()
				ui.open()
				set_debug_cursorline(true)
			end

			local function close_debug_ui_and_restore()
				pcall(ui.close)
				pcall(dap.repl.close)
				set_debug_cursorline(false)
				if pre_debug_winrestcmd and pre_debug_winrestcmd ~= "" then
					pcall(vim.cmd, pre_debug_winrestcmd)
					pre_debug_winrestcmd = nil
				end
				pcall(vim.cmd, "wincmd =")
			end

			dap.listeners.before.attach.dapui_config = function()
				open_debug_ui()
			end
			dap.listeners.before.launch.dapui_config = function()
				open_debug_ui()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				close_debug_ui_and_restore()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				close_debug_ui_and_restore()
			end

			dap.listeners.after.event_stopped.dap_cursorline = function()
				set_debug_cursorline(true)
			end
			dap.listeners.after.event_continued.dap_cursorline = function()
				set_debug_cursorline(false)
			end
		end,
	},
}
