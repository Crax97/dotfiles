lua require('plugins')
lua require('setup')

set number relativenumber
set signcolumn=yes

let g:mkdp_browser = '/usr/bin/firefox'
let g:mkdp_port = '8292'

augroup FormatAutogroup
	autocmd!
	autocmd BufWritePost * FormatWrite
augroup End

colorscheme habamax
