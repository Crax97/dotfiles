local M = {}

-- Runs a single command, stripping any newlines.
-- returns stdout if command had success, otherwise nil
local function exec_syscall(command, opts)
	local result = vim.fn.system(command, opts)
	if vim.v.shell_error == 0 then
		return result:gsub("\n", "")
	else
		return nil
	end

end

local function find_cargo_workspace_root()
	local locate_result = exec_syscall('cargo locate-project --workspace --message-format plain', {})
	if locate_result ~= nil then
		return locate_result:gsub("Cargo.toml", "")
	else
		return nil
	end
end

-- Tries to find a workspace
-- returns the workspace's root + project type
-- ex. /home/guy/rust_project/, "cargo"
function M.find_workspace_root() 
	local cargo_root = find_cargo_workspace_root()
	if cargo_root ~= nil then
		return 	cargo_root, "rust"
	end
	return nil, nil
end

-- Given a path it tries to find and load a launch.json
-- @param workspace_root string with the location of the project 
function M.try_setup_launch_json(workspace_root)
	local launch_json_vscode = exec_syscall('find ' .. workspace_root .. ' -iname launch.json')
	if launch_json_vscode == nil then
		return false
	end

	if vim.fn.filereadable(launch_json_vscode) then
		local dap_vscode = require('dap.ext.vscode')
		dap_vscode.json_decode = require'json5'.parse
		dap_vscode.load_launchjs(launch_json_vscode, { 
			codelldb = {'rust', 'c', 'cpp'}, 
			lldb = {'rust', 'c', 'cpp'}
		})
		for k, p in ipairs(require'dap'.configurations) do
			print(k)
		end
		return true
	end

	return false
end


return M
