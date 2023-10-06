lua require('plugins')
lua require('setup')

syntax enable
filetype plugin indent on

set number relativenumber
set signcolumn=yes

set tabstop=4
set shiftwidth=4
set expandtab

let g:mkdp_browser = '/usr/bin/firefox'
let g:mkdp_port = '8292'

augroup FormatAutogroup
		autocmd!
		autocmd BufWritePost * FormatWrite
augroup END

colorscheme oxocarbon

" Set leader
let mapleader = ","

" Quickly edit config files from everywhere
map <Leader>e :e ~/.config/nvim/init.vim<CR>
map <Leader>p :e ~/.config/nvim/lua/plugins.lua<CR>
map <Leader>s :e ~/.config/nvim/lua/setup.lua<CR>

" Your average Lua mappings for nvim-dap
map <F5> lua Run()<CR>
map <F9> lua require 'dap'.toggle_breakpoint()<CR>
map <Leader>B lua require 'dap'.set_breakpoint()<CR>
map <F10> lua require 'dap'.step_over()<CR>
map <F11> lua require 'dap'.step_into()<CR>
map <Leader><F11> lua require 'dap'.step_out()<CR>


" Setup Telescope bindings
map <Leader>tl :Telescope live_grep<CR>
map <Leader>tf :Telescope find_files<CR>
map <Leader>ts :Telescope lsp_workspace_symbols<CR>
map <Leader>td :Telescope diagnostics<CR>

" Setup lsp bindings
map gd :lua vim.lsp.buf.definition()<CR>
map <Leader>r :lua vim.lsp.buf.rename()<CR>

" Hide vim/nvim statusbar: it's replaced by airline
set noshowmode
set noruler
set laststatus=3 " nvim supports global statusline

" Use Normal color for window separator bg
function! GetHighlight(g, t)
    let output = execute('hi ' . a:g)
    return matchstr(output, a:t.'=\zs\S*')
endfunction

" Hide the vertical separator, use only fillchars
hi VertSplit term=NONE cterm=NONE gui=NONE guifg=NONE guibg=NONE ctermbg=NONE ctermfg=NONE
