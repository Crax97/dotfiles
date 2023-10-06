local mason = require("mason")
local mason_registry = require("mason-registry")

local lsp = require("lspconfig")
local mason_lsp = require("mason-lspconfig")
local cmp = require("cmp")
local cmp_lsp = require("cmp_nvim_lsp")

local rust_utils = require("utils")

local workspace_root, project_type = rust_utils.find_workspace_root()
if workspace_root ~= nil then
	vim.g.workspace_root = workspace_root
	vim.g.project_type = project_type
end

-- setup tint
require("tint").setup({
	tint = -60,
	saturation = 0.8,
	highlight_ignore_patterns = { "Comment" },
})

-- setup mason
mason.setup()
mason_lsp.setup({
	ensure_install = {
		"rust_analyzer",
		"clangd",
		"codelldb",
	},
})

mason_lsp.setup_handlers({
	function(sn)
		lsp[sn].setup({})
	end,
})

-- setup cmp + setup lsp
local mapping = cmp.mapping.preset.insert({
	["<C-m>"] = cmp.mapping.scroll_docs(-4),
	["<C-n>"] = cmp.mapping.scroll_docs(4),
	["<C-e>"] = cmp.mapping.abort(),
	["<C-j>"] = cmp.mapping.select_next_item(),
	["<C-k>"] = cmp.mapping.select_prev_item(),
	["<C-CR>"] = function()
		if cmp.visible() then
			cmp.mapping.confirm({
				behavior = cmp.ConfirmBehavior.Replace,
				select = true,
			})
		else
			cmp.complete()
		end
	end,
})
cmp.setup({
	snippet = {
		expand = function(args)
			vim.fn["vsnip#anonymous"](args.body)
		end,
	},
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "vsnip" },
		{ name = "nvim_lsp_signature_help" },
	}, {
		{ name = "buffer" },
	}),
	mapping = mapping,
	on_attach = function(client, bufnr)
		require("lsp_signature").on_attach(signature_setup, bufnr)
	end,
})

cmp.setup.cmdline(":", {
	mapping = mapping,
	sources = cmp.config.sources({
		{ name = "path" },
		{ name = "rg" },
	}, {
		{ name = "cmdline" },
	}),
})

-- setup formatter
require("formatter").setup({
	logging = true,
	log_level = vim.log.levels.INFO,
	filetype = {
		rust = require("formatter.filetypes.rust").rustfmt,
		c = require("formatter.filetypes.c").clangformat,
		cpp = require("formatter.filetypes.cpp").clangformat,
		cmake = require("formatter.filetypes.cmake").cmakeformat,
		toml = require("formatter.filetypes.toml").taplo,
		zig = require("formatter.filetypes.zig").zigfmt,
		lua = require("formatter.filetypes.lua").stylua,
		markdown = require("formatter.filetypes.markdown").prettier,
		json = require("formatter.filetypes.json").pretier,

		["*"] = {
			require("formatter.filetypes.any").remove_trailing_whitespace,
		},
	},
})

-- setup lsp keybinds
-- as per doc suggestions, only setup them when a lsp client is active
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		vim.keymap.set({ "n", "v" }, "<M-CR>", vim.lsp.buf.code_action, { buffer = args.buf })
	end,
})

-- setup dap
local dap = require("dap")

local codelldb = mason_registry.get_package("codelldb")
local codelldb_install_path = codelldb:get_install_path()
local extension_path = codelldb_install_path .. "/extensions/"
local codelldb_executable = extension_path .. "adapter/codelldb"
local liblldb_path = extension_path .. "lldb/lib/liblldb.so"

dap.adapters.lldb = {
	type = "executable",
	command = "/usr/bin/lldb-vscode",
	name = "lldb",
}
dap.adapters.rust = dap.adapters.lldb
dap.adapters.c = dap.adapters.lldb
dap.adapters.cpp = dap.adapters.lldb

local function setup_dap_configurations()
	if workspace_root ~= nil then
		rust_utils.try_setup_launch_json(workspace_root)
	end
	if project_type == "rust" then
		if dap.configurations[project_type] == nil then
			dap.configurations[project_type] = {}
		end

		local rust = {}
		vim.fn.trim(vim.fn.system("which cargo"))
		local debugger = "lldb"
		local found_binaries = rust_utils.find_cargo_binaries(workspace_root)
		rust.binaries = found_binaries

		if found_binaries == nil then
			return
		end

		for _, bin in ipairs(found_binaries) do
			local debug_bin_path = workspace_root .. "/target/debug/" .. bin
			local release_bin_path = workspace_root .. "/target/debug/" .. bin
			local config = {
				type = debugger,
				request = "launch",
				name = "debug " .. bin,
				program = debug_bin_path,
				cwd = workspace_root,
				args = {},
				preLaunchTask = "cargo-debug-" .. bin,
			}
			table.insert(dap.configurations[project_type], config)
			config = {
				type = debugger,
				request = "launch",
				name = "release " .. bin,
				program = release_bin_path,
				cwd = workspace_root,
				args = {},
				preLaunchTask = "cargo-release-" .. bin,
			}
			table.insert(dap.configurations[project_type], config)
		end
		vim.g.rust = rust
	end
end

function Run(opts)
	if dap.status() ~= "" then
		dap.continue()
		return
	end
	if vim.g.project_type ~= nil then
		local project_type = vim.g.project_type
		local config_substr = opts.fargs[1]
		if config_substr ~= nil then
			config_substr = config_substr:lower()
			local configurations = dap.configurations[project_type]

			local found_configuration = nil
			for _, configuration in ipairs(configurations) do
				if configuration.name:lower():find(config_substr) then
					found_configuration = configuration
				end
			end

			if found_configuration then
				dap.run(found_configuration, {})
			else
				print("No configuration containing " .. config_substr)
			end
		else
			local old_config = vim.bo.filetype
			vim.bo.filetype = project_type
			dap.continue()
			vim.bo.filetype = old_config
		end
	end
end

vim.api.nvim_create_user_command("Bp", "lua require 'dap'.toggle_breakpoint()", {})
vim.api.nvim_create_user_command("Run", Run, { nargs = "?" })

setup_dap_configurations()
-- setup overseer - task runner
local overseer = require("overseer")
overseer.setup({
	templates = { "cargo.debug", "cargo.release", "cargo.targets" },
})

-- setup treesitter
local treesitter = require("nvim-treesitter.configs")
treesitter.setup({
	ensure_installed = "all", -- Yes... Install them all
})

-- setup Telescope
local actions = require("telescope.actions")
local telescope = require("telescope")
telescope.setup({
	extensions = {
		fzf = {
			fuzzy = true,
			override_generic_sorter = true,
			override_file_sorter = true,
			case_mode = "smart_case",
		},
	},
	defaults = {
		mappings = {
			i = {
				["<C-j>"] = actions.move_selection_next,
				["<C-k>"] = actions.move_selection_previous,
			},
		},
	},
})
telescope.load_extension("fzf")

require("lualine").setup({
	options = {
		section_separators = { left = "", right = "" },
		component_separators = { left = "", right = "" },
		theme = "horizon",
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch", "diff", "diagnostics" },
		lualine_c = { "buffers" },
		lualine_x = { "encoding", "fileformat", "filetype" },
		lualine_y = { "progress" },
		lualine_z = { "location" },
	},
	tabline = {
		lualine_c = { "buffers" },
	},
})

vim.ui.select = require("popui.ui-overrider")
vim.ui.input = require("popui.input-overrider")
--
---- setup lightbulb plugin
--require('nvim-lightbulb').setup({
--	sign = {
--		enabled = true
--	},
--	virtual_text = { enabled = false },
--	float = { enabled = false },
--	status_text = { enabled = false },
--	number = {enabled = false },
--	line = { enabled = true },
--
--	autocmd = {
--		enabled = true,
--		updatetime = 200,
--		events = { "CursorHold", "CursorHoldI" },
--		pattern = { "*" },
--
--	}
--})
