return	{
	name = "cargo-release-workspace",
	builder = function(params)
		return {
			cmd = { 'cargo' },
			args = {'build', '--workspace', '--release'},
			name = 'cargo-release'
		}
	end,
	desc = "Builds all the binaries in the workspace in release mode",
	condition = {
		callback = function()
			return vim.g.project_type ~= nil and vim.g.project_type == "rust"
		end
	}
} 
