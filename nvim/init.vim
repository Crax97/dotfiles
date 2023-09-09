lua require('plugins')
lua require('setup')

syntax enable
filetype plugin indent on

set number relativenumber
set signcolumn=yes

let g:mkdp_browser = '/usr/bin/firefox'
let g:mkdp_port = '8292'

augroup FormatAutogroup
	autocmd!
	autocmd BufWritePost * FormatWrite
augroup End

colorscheme habamax

" Quickly edit config files from everywhere
map ,e :e ~/.config/nvim/init.vim<CR>
map ,p :e ~/.config/nvim/lua/plugins.lua<CR>
map ,s :e ~/.config/nvim/lua/setup.lua<CR>
