local mason = require('mason')

local lsp = require('lspconfig')
local mason_lsp = require('mason-lspconfig')
local cmp = require('cmp')
local cmp_lsp = require('cmp_nvim_lsp')

-- setup mason
mason.setup()
mason_lsp.setup {
	ensure_install = {
		"rust_analyzer",
		"clangd",
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
