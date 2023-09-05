local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
	"williamboman/mason.nvim", -- editor tooling manager
	"williamboman/mason-lspconfig.nvim", -- mason lsp configurator
 	"neovim/nvim-lspconfig", -- nvim lspconfig

	"mfussenegger/nvim-dap", -- neovim debug adapter protocol
	"rcarriga/nvim-dap-ui", -- neovim dap ui
} 

local opts = {}
require("lazy").setup(plugins, opts)

-- OLD PACKER PLUGINS
-- return require('packer').startup(function(use)
-- 	use 'wbthomason/packer.nvim'
-- 
-- 	-- Should this dude die my nvim journey will be basically over
-- 	use 'hrsh7th/cmp-path' -- autocomplete source for filesystem
-- 	use 'hrsh7th/cmp-buffer' -- autocomplete source for buffer words
-- 	use 'hrsh7th/cmp-cmdline' -- autocomplete cmdline commands
-- 	use 'hrsh7th/nvim-cmp' -- autocomplete
-- 
-- 	use 'hrsh7th/cmp-nvim-lsp'
-- 	use 'hrsh7th/cmp-nvim-lsp-signature-help' -- display function signatures
-- 	use 'hrsh7th/cmp-vsnip'
-- 	use 'hrsh7th/vim-vsnip' -- snippets engine
-- 	
-- 	use 'rstacruz/vim-closer' -- Auto closing braces
-- 	use 'neovim/nvim-lspconfig' -- nvim lspconfig
-- 	
-- 	use 'kosayoda/nvim-lightbulb' -- show code action lightbulb when code action available
-- 
-- 	use 'hood/popui.nvim' -- UI tools, like code action, better input etc...
-- 
-- 	use  {
-- 		'nvim-telescope/telescope.nvim', -- fuzzy file finder
-- 		requires = {{ 'nvim-lua/plenary.nvim' }}
-- 	}
-- 	use({ "iamcco/markdown-preview.nvim", run = "cd app && npm install", setup = function() vim.g.mkdp_filetypes = { "markdown" } end, ft = { "markdown" }, })
-- end)
