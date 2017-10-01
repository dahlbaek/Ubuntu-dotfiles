filetype plugin indent on
syntax enable

" Basic setup
set background=dark " When using a dark background for editing
set number " Show line numbers
set relativenumber " Show relative numbers
set expandtab " Convert tabs to spaces
set shiftwidth=4 " Set tab width
set softtabstop=4 " Set tab to produce 2 spaces
set breakindent " Indent on word wrap
set linebreak " Only wrap at character in breakat option
set splitright " When splitting with vs, put new window on right side
set textwidth=79 " Set textwidth for use with gq

" Do not hard wrap
set formatoptions-=t formatoptions-=c

" Do not insert comment leaders automatically
set formatoptions-=r formatoptions-=o 

" Set background color for line numbers, and set font color for line numbers
highlight LineNr ctermbg=DarkGrey 
highlight LineNr ctermfg=Grey 

" Fix the broken register behaviour of Vim
noremap x "_d
noremap X "_D
nnoremap xx "_dd
noremap c "_c
noremap C "_C
nnoremap cc "_ddi

" Sensible settings
nnoremap <silent> <C-L> :nohlsearch<Bar>call sneak#cancel()<Bar>diffupdate<CR><C-L>
set scrolloff=1
inoremap <C-U> <C-G>u<C-U>
noremap <Space> :
tnoremap <Esc> <C-\><C-N>
tnoremap <C-W>p <C-\><C-N>G<C-W>p 
" :au BufEnter * if &buftype == 'terminal' | :startinsert | endif

" Tell vim-plug which packages to load
call plug#begin()
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'justinmk/vim-sneak'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'davidhalter/jedi'
Plug 'zchee/deoplete-jedi'
Plug 'SirVer/ultisnips'
Plug 'lervag/vimtex'
Plug 'jalvesaq/Nvim-R'
Plug 'hkupty/iron.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'Vimjas/vim-python-pep8-indent'
call plug#end()

" Configure vim-plug
let g:plug_window = ':sp horizontal' "Split horizontally

" Configure vim-surround
let g:surround_no_mappings = 1
nmap dz <Plug>Dsurround
nmap cz <Plug>Csurround
xmap z <Plug>VSurround

" Configure vim-sneak
let g:sneak#target_labels=';wegvbnm-QWEYUIAGHJKLZCVBNM' 
let g:sneak#label=1

" Use enhanced t/T and f/F
map t <Plug>Sneak_t
map T <Plug>Sneak_T
map f <Plug>Sneak_f
map F <Plug>Sneak_F
" Use s/S to sneak in operator pending mode
omap s <Plug>Sneak_s
omap S <Plug>Sneak_S

" Configure deoplete.
let g:deoplete#enable_at_startup=1 " Enables deoplete
" Configure deoplete to work with vimtex
if !exists('g:deoplete#omni#input_patterns')
    let g:deoplete#omni#input_patterns={}
endif
let g:deoplete#omni#input_patterns.tex = g:vimtex#re#deoplete

" Configure UltiSnips
let g:UltiSnipsEditSplit='horizontal' " Split horizontally
let g:UltiSnipsSnippetDirectories=['~/.config/nvim/UltiSnips'] " Sets directory with snippets

" Configure vimtex
let g:vimtex_view_method='zathura'
let g:vimtex_compiler_progname='~/.local/bin/nvr'
nmap dze <plug>(vimtex-env-delete)
nmap dzc <plug>(vimtex-cmd-delete)
nmap dz$ <plug>(vimtex-env-delete-math)
nmap dzd <plug>(vimtex-delim-delete)
nmap cze <plug>(vimtex-env-change)
nmap czc <plug>(vimtex-cmd-change)
nmap cz$ <plug>(vimtex-env-change-math)
nmap czd <plug>(vimtex-delim-change-math)
nmap tzc <plug>(vimtex-cmd-toggle-star)
nmap tze <plug>(vimtex-env-toggle-star)
nmap tzd <plug>(vimtex-delim-toggle-modifier)

" Configure iron.nvim
let g:iron_repl_open_cmd="vsplit"

" Configure Python
let g:python_host_prog='/usr/bin/python'
let g:python3_host_prog='/usr/bin/python3'
let g:iron_map_defaults=0
augroup ironmapping
    autocmd!
    autocmd Filetype python nmap <buffer> <localleader>r :IronRepl<CR><C-\><C-N>:vertical resize 88<CR>G<C-W>p
    autocmd Filetype python nmap <buffer> <localleader>s <Plug>(iron-send-motion)
    autocmd Filetype python vmap <buffer> <localleader>s <Plug>(iron-send-motion)
    autocmd Filetype python nmap <buffer> <localleader>p <Plug>(iron-repeat-cmd)
augroup END
