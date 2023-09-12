local mason = require('mason')
local mason_registry = require('mason-registry')

local lsp = require('lspconfig')
local mason_lsp = require('mason-lspconfig')
local cmp = require('cmp')
local cmp_lsp = require('cmp_nvim_lsp')

local rust_utils = require ('utils')

local workspace_root, project_type = rust_utils.find_workspace_root()
if workspace_root ~= nil then
	vim.g.workspace_root = workspace_root
	vim.g.project_type = project_type
end

-- setup mason
mason.setup()
mason_lsp.setup {
	ensure_install = {
		"rust_analyzer",
		"clangd",
		"codelldb",
	}
}

-- setup cmp + setup lsp
cmp.setup({
	snippet = {
		expand = function(args)
			vim.fn["vsnip#anonymous"](args.body)
		end,
	},
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		{ name = 'vsnip' },
		{ name = 'nvim_lsp_signature_help' },
	}, {
		{ name = 'buffer' },
	}),
	mapping = cmp.mapping.preset.insert({
		['<C-b>'] = cmp.mapping.scroll_docs(-4),
      		['<C-f>'] = cmp.mapping.scroll_docs(4),
      		['<C-Space>'] = cmp.mapping.complete(),
      		['<C-e>'] = cmp.mapping.abort(),
      		['<CR>'] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Insert,
			select = true 
		}), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    
    }),
    on_attach = function(client, bufnr)
	    require ('lsp_signature').on_attach(signature_setup, bufnr)
    end
})

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

local capabilities = cmp_lsp.default_capabilities()

lsp.rust_analyzer.setup({
	capabilities = capabilities
})

-- setup formatter
require("formatter").setup {
	["*"] = {
		require("formatter.filetypes.any").remove_trailing_whitespace
	}
}

-- setup lsp keybinds
-- as per doc suggestions, only setup them when a lsp client is active
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    vim.keymap.set({'n', 'v'}, '<M-CR>', vim.lsp.buf.code_action, { buffer = args.buf })
  end,
})

-- setup dap
local dap = require('dap')

local codelldb = mason_registry.get_package("codelldb")
local codelldb_install_path = codelldb:get_install_path()
local extension_path = codelldb_install_path .. "/extensions/"
local codelldb_executable = extension_path .. "adapter/codelldb"
local liblldb_path = extension_path .. "lldb/lib/liblldb.so"

dap.adapters.lldb = {
  type = 'executable',
  command = "/usr/bin/lldb-vscode",
  name = 'lldb',
}
dap.adapters.rust = dap.adapters.lldb
dap.adapters.c = dap.adapters.lldb
dap.adapters.cpp = dap.adapters.lldb

function setup_dap_configurations() 
	if workspace_root ~= nil then
		local did_setup_launch = rust_utils.try_setup_launch_json(workspace_root)
	end
	if project_type == "rust" then
		local rust = {}
		local cargo_dir = vim.fn.trim(vim.fn.system('which cargo'))
		local debugger = 'lldb'
		found_binaries = rust_utils.find_cargo_binaries(workspace_root)
		rust.binaries = {}

		for _, bin in ipairs(found_binaries) do
			table.insert(rust.binaries, bin)
			local debug_bin_path = workspace_root .. '/target/debug/' .. bin
			local release_bin_path = workspace_root .. '/target/debug/' .. bin
			local config = {
				type = debugger,
				request = 'launch',
				name = 'debug ' .. bin,
				program = debug_bin_path,
				cwd = workspace_root,
				args = {
				},
				preLaunchTask = "cargo-debug-"..bin
			}
			table.insert(dap.configurations[project_type], config)
			config = {
				type = debugger,
				request = 'launch',
				name = 'release ' .. bin,
				program = release_bin_path,
				cwd = workspace_root,
				args = {
				},
				preLaunchTask = "cargo-release-"..bin
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
				print('No configuration containing ' .. config_substr)
			end
		else 
			local old_config = vim.bo.filetype
			vim.bo.filetype = project_type
			dap.continue()
			vim.bo.filetype = old_config
		end
	end

end

vim.api.nvim_create_user_command('Bp', 'lua require \'dap\'.toggle_breakpoint()', {})
vim.api.nvim_create_user_command('Run', Run, { nargs='?' })

setup_dap_configurations()
-- setup overseer - task runner
local overseer = require('overseer')
overseer.setup({
	templates = { "cargo.debug", "cargo.release", "cargo.targets" }
})


-- setup popui
--vim.ui.select = require"popui.ui-overrider"
--vim.ui.input = require"popui.input-overrider"
--vim.api.nvim_set_keymap("n", ",d", ':lua require"popui.diagnostics-navigator"()<CR>', { noremap = true, silent = true }) 
--vim.api.nvim_set_keymap("n", ",m", ':lua require"popui.marks-manager"()<CR>', { noremap = true, silent = true })
--vim.api.nvim_set_keymap("n", ",r", ':lua require"popui.references-navigator"()<CR>', { noremap = true, silent = true })
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
