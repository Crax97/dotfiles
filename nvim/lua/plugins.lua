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

local json5_build = "./install.sh"

if vim.fn.has("win32") == 1 then
	json5_build = "powershell ./install.ps1"
end

local plugins = {
	"nvim-lua/plenary.nvim", -- utils for developing plugins
	"nyoom-engineering/oxocarbon.nvim",
	{ "Crax97/lua-json5", build = json5_build, branch = "windows-support" }, -- json5 support
	"williamboman/mason.nvim", -- editor tooling manager
	"williamboman/mason-lspconfig.nvim", -- mason lsp configurator
	"neovim/nvim-lspconfig", -- nvim lspconfig

	"mfussenegger/nvim-dap", -- neovim debug adapter protocol
	"rcarriga/nvim-dap-ui", -- neovim dap ui
	-- Should this dude die my nvim journey will be basically over
	"hrsh7th/nvim-cmp", -- autocomplete
	"hrsh7th/cmp-path", -- autocomplete source for filesystem
	"hrsh7th/cmp-buffer", -- autocomplete source for buffer words
	"hrsh7th/cmp-cmdline", -- autocomplete cmdline commands
	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/cmp-nvim-lsp-signature-help", -- display function signatures
	"hrsh7th/cmp-vsnip",
	"lukas-reineke/cmp-rg",

	"hrsh7th/vim-vsnip", -- snippets engine

	"rstacruz/vim-closer", -- auto closing braces
	--	'simrat39/rust-tools.nvim', -- rust stuff
	{
		"iamcco/markdown-preview.nvim",
		build = "cd app && npm install",
		init = function(lp)
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
	},

	"mfussenegger/nvim-lint", -- linter support
	"mhartington/formatter.nvim", -- auto formatter

	"stevearc/overseer.nvim", -- Task runner

	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" }, -- ast parsing library, used by plugins/to improve vim syntax stuff
	{ "nvim-telescope/telescope.nvim", tag = "0.1.3" }, -- extensible fuzzy file finder
	{
		"nvim-telescope/telescope-fzf-native.nvim",
		build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
	}, -- Native fzf implementation

	"nvim-lualine/lualine.nvim",

	"levouh/tint.nvim", -- Dim inactive windows
    "tikhomirov/vim-glsl", -- glsl stuff

	"hood/popui.nvim", -- replace nvim input/select menus
	"equalsraf/neovim-gui-shim", -- Nvim QT gui options
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
