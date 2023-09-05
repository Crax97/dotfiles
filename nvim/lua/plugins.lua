return require('packer').startup(function(use)
	use 'wbthomason/packer.nvim'

	-- Should this dude die my nvim journey will be basically over
	use 'hrsh7th/cmp-path' -- autocomplete source for filesystem
	use 'hrsh7th/cmp-buffer' -- autocomplete source for buffer words
	use 'hrsh7th/cmp-cmdline' -- autocomplete cmdline commands
	use 'hrsh7th/nvim-cmp' -- autocomplete

	use 'hrsh7th/cmp-nvim-lsp'
	use 'hrsh7th/cmp-nvim-lsp-signature-help' -- display function signatures
	use 'hrsh7th/cmp-vsnip'
	use 'hrsh7th/vim-vsnip' -- snippets engine
	
	use 'rstacruz/vim-closer' -- Auto closing braces
	use 'neovim/nvim-lspconfig' -- nvim lspconfig
	
	use 'kosayoda/nvim-lightbulb' -- show code action lightbulb when code action available

	use 'hood/popui.nvim' -- UI tools, like code action, better input etc...

	use  {
		'nvim-telescope/telescope.nvim', -- fuzzy file finder
		requires = {{ 'nvim-lua/plenary.nvim' }}
	}
	use({ "iamcco/markdown-preview.nvim", run = "cd app && npm install", setup = function() vim.g.mkdp_filetypes = { "markdown" } end, ft = { "markdown" }, })
end)
