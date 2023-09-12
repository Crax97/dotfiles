return {
	name = "cargo-debug-workspace",
	builder = function(params)
		return {
			cmd = { 'cargo' },
			args = {'build', '--workspace'},
			name = 'cargo-debug'
		}
	end,
	desc = "Builds all the binaries in the workspace",
	condition = {
		callback = function()
			return vim.g.project_type ~= nil and vim.g.project_type == "rust"
		end
	}
}
