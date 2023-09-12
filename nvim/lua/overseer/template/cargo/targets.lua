local function make_cargo_template(target, binary)
	local args = {'build', '--bin', binary}
	if target == "release" then
		table.insert(args, "--release")
	end
	return {
		name = 'cargo-'..target..'-'..binary,
		builder = function(params) 
			return {
				cmd = {'cargo'},
				args = args,
				name = 'build binary ' ..binary .. ' with profile ' ..target,
				cwd = vim.g.workspace_root,
			}
		end
	}
end

return {
	generator = function(search, cb)
		local templates = {}
		for _, bin in ipairs(vim.g.rust.binaries) do
			table.insert(templates, make_cargo_template('debug', bin))
			table.insert(templates, make_cargo_template('release', bin))
		end
		cb(templates)
	end,
	condition = {
		callback = function()
			return vim.g.rust ~= nil
		end
	}
}
