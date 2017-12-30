filetype plugin indent on
syntax enable

" Basic setup
set background=dark " When using a dark background for editing
set number " Show line numbers
set relativenumber " Show relative numbers
set expandtab " Convert tabs to spaces
set shiftwidth=2 " Set tab width
set softtabstop=2 " Set tab to produce 2 spaces
set breakindent " Indent on word wrap
set linebreak " Only wrap at character in breakat option

" Set background color for line numbers, and set font color for line numbers
highlight LineNr ctermbg=DarkGrey 
highlight LineNr ctermfg=Grey 

" Fix the broken register behaviour of Vim
noremap x "_d
noremap X "_D
nnoremap xx "_dd

" Sensible settings
nnoremap <silent> <C-L> :nohlsearch<Bar>call sneak#cancel()<Bar>diffupdate<CR><C-L>
set scrolloff=1
inoremap <C-U> <C-G>u<C-U>
nnoremap <C-Q> :q<CR>

" Tell vim-plug which packages to load
call plug#begin()
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'justinmk/vim-sneak'
Plug 'Shougo/neocomplete.vim'
Plug 'SirVer/ultisnips'
Plug 'lervag/vimtex'
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

" Configure neocomplete.
let g:neocomplete#enable_at_startup=1 " Enables neocomplete
" Configure neocomplete to work with vimtex
if !exists('g:neocomplete#sources#omni#input_patterns')
  let g:neocomplete#sources#omni#input_patterns={}
endif
let g:neocomplete#sources#omni#input_patterns.tex=g:vimtex#re#neocomplete

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
