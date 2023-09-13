local M = {}

-- Runs a single command, stripping any newlines.
-- returns stdout if command had success, otherwise nil
local function exec_syscall(command, opts)
	local result = vim.fn.trim(vim.fn.system(command, opts))
	if vim.v.shell_error == 0 then
		return result
	else
		return nil
	end

end

function M.find_one_file(p, r) 
	for _, p in ipairs(vim.fs.find(p, {
		limit = 1,
		type = "file",
		path = r
	})) do
		return p
	end
	return nil
end

local function find_cargo_workspace_root()
	local locate_result = exec_syscall('cargo locate-project --quiet --workspace --message-format plain', {})
	if locate_result ~= nil then
		return locate_result:gsub("Cargo.toml", "")
	else
		return nil
	end
end

-- Tries to find a workspace
-- returns the workspace's root + project type
-- ex. /home/guy/rust_project/, "rust"
function M.find_workspace_root() 
	local cargo_root = find_cargo_workspace_root()
	if cargo_root ~= nil then
		return 	cargo_root, "rust"
	end
	return nil, nil
end

-- Given a path it tries to find and load a launch.json
-- @param workspace_root string with the location of the project 
-- @returns true if launch json was setup correctly
function M.try_setup_launch_json(workspace_root)
	local launch_json_vscode = M.find_one_file("launch.json", workspace_root)
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
		return true
	end

	return false
end

local function table_find(t, target)
	for i, p in ipairs(t) do
		if p == target then
			return i
		end
	end
	return nil
end

M.table_find = table_find

function M.find_cargo_binaries(workspace_root)
	local manifest_path = workspace_root .. "Cargo.toml"
	local cargo_manifest_result = exec_syscall('cargo metadata --quiet --no-deps --format-version 1 --manifest-path "' .. manifest_path .. '"')
	if cargo_manifest_result == nil then
		return nil
	end

	local parse = require'json5'.parse

	local cargo_data = parse(cargo_manifest_result)
	local found_binaries = {}
	local packages = cargo_data.packages

	for _, package in ipairs(packages) do
		for _, target in ipairs(package.targets) do
			if table_find(target.kind, "bin") then
				table.insert(found_binaries, target.name)
			end
		end
	end
	return found_binaries
end
 
return M
