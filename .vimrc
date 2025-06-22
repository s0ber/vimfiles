if has('vim_starting')
  set nocompatible " be iMproved

  " required:
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

" required:
call neobundle#begin(expand('~/.vim/bundle'))

" Let NeoBundle manage NeoBundle
" required:
NeoBundleFetch 'Shougo/neobundle.vim'

" My Bundles here:
NeoBundle 'vim-airline/vim-airline', 'master'            " light version of powerline
NeoBundle 'tpope/vim-repeat'             " repeat custom actions with .

" text formatting
NeoBundle 'jiangmiao/auto-pairs'         " autoclose quotes, brackets, etc
NeoBundle 'tpope/vim-surround'           " quote selected text
NeoBundle 'tomtom/tcomment_vim'          " comment and uncomment
NeoBundle 'DeleteTrailingWhitespace'     " remove trailing whitespaces
NeoBundle 'mg979/vim-visual-multi', { 'branch': 'master' } " sublime-inspired multiple cursors
" NeoBundle 'tpope/vim-endwise'            " automatically end code blocks
" NeoBundle 'tpope/vim-unimpaired'         " mappings for paired actions

" integration with ag
NeoBundle 'rking/ag.vim'
NeoBundle 'gabesoft/vim-ags'

" smooth scrolling
NeoBundle 'karb94/neoscroll.nvim'

" fuzzy search
NeoBundle 'ctrlpvim/ctrlp.vim'               " fuzzy file search
NeoBundle 'FelikZ/ctrlp-py-matcher'

NeoBundle 'nvim-telescope/telescope-fzf-native.nvim', { 'build': 'make' }
NeoBundle 'nvim-lua/plenary.nvim'
NeoBundle 'nvim-telescope/telescope.nvim', { 'branch': '0.1.x' }

" file tree
NeoBundle 'nvim-tree/nvim-tree.lua'

" filetypes support
NeoBundle 'kchmck/vim-coffee-script'     " support for coffeescript
NeoBundle 'vim-ruby/vim-ruby'            " support for ruby (always use latest vim-ruby)
NeoBundle 'tpope/vim-haml'               " support for haml
NeoBundle 'slim-template/vim-slim'       " support for slim
NeoBundle 'othree/html5.vim'             " support for html5
NeoBundle 'derekwyatt/vim-scala'         " support for scala
NeoBundle 'groenewege/vim-less'          " support for less
NeoBundle 'digitaltoad/vim-pug'          " support for pug (former Jade)
" NeoBundle 'tikhomirov/vim-glsl'
NeoBundle 'Eric-Song-Nop/vim-glslx'
NeoBundle 'nvim-treesitter/nvim-treesitter'
NeoBundle 'RRethy/nvim-treesitter-endwise' " automatically end code blocks

" colorscheme
NeoBundle 'vv9k/vim-github-dark'
NeoBundle 'dracula/vim.git'
NeoBundle 'gmr458/vscode_modern_theme.nvim'
NeoBundle 'folke/tokyonight.nvim'
NeoBundle 'catppuccin/nvim'
NeoBundle 'rose-pine/neovim'
NeoBundle 'nyoom-engineering/oxocarbon.nvim'
NeoBundle 'rebelot/kanagawa.nvim'
NeoBundle 'EdenEast/nightfox.nvim'
NeoBundle 'loctvl842/monokai-pro.nvim'

" typescript IDE 2
NeoBundle 'neoclide/coc.nvim', { 'branch': 'release', 'build': 'npm ci' }

" syntax errors highlight
" NeoBundle 'ngmy/vim-rubocop' " rubocop warnings

" tests runners
NeoBundle 'vim-test/vim-test'

" icons
" NeoBundle 'ryanoasis/vim-devicons'

" workspace
call neobundle#end()

" required:
syntax enable
filetype plugin indent on

" If there are uninstalled bundles found on startup, this will conveniently
" prompt you to install them.
NeoBundleCheck

set langmenu=en_US
let $LANG = 'en_US'
set linespace=1          " increase space between lines
set number               " show line numbers
" set cursorline           " highlight current line
set noswapfile           " no *.swp artifacts
set scrolloff=5          " Keep at least 5 lines visible when scrolling
set nowrap               " Disabled wrapping
set autowrite            " Automatically :write before running commands
set history=50           " history size
set undofile             " tell it to use an undo file
set undodir=~/.vim/undo  " set a directory to store the undo history
set nowritebackup        " save file only once
set synmaxcol=300
set background=dark

" Indentation
set smartindent
set tabstop=2
set shiftwidth=2
set expandtab

" Open new split panes to right and bottom, which feels more natural
set splitbelow
set splitright

" colorscheme settings
colorscheme rose-pine-moon
" set notermguicolors

" search tweaks
set hlsearch

" Preview effects of command incrementally (e.g. :substitute). Neovim only.
if has('nvim')
	set inccommand=nosplit
endif

set ignorecase
set smartcase " doesn't ignore case only when uppercase letters are specified
set wildignore+=*/coverage/*        " Linux/MacOSX

" coc settings
set nowritebackup
" set cmdheight=2
set updatetime=300
set shortmess+=c
if has("nvim-0.5.0") || has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
endif
let g:coc_force_debug = 1

" Let's not be retarded
let mapleader = ','

" Ag tweaks
let g:ag_prg='ag --hidden --smart-case --column --ignore={".git","node_modules","*gql.types.tsx"}'
" nmap <Leader>ag :Ag!<Space>
" nmap <Leader>as :Ags<Space>
let g:ag_apply_qmappings=0 " don't apply default mappings
nmap <expr> o &buftype == 'quickfix' ? '<CR>' : 'o'

" highlight custom files
autocmd BufRead,BufNewFile *file set filetype=ruby
autocmd BufNewFile,BufRead *.ejs set filetype=html
autocmd! BufNewFile,BufRead *.glsl set ft=glslx

" GCC compiler
au BufEnter *.c compiler gcc
au BufWritePost *.c make

" Autoclose pipe in Ruby
autocmd FileType ruby let b:AutoPairs = AutoPairsDefine({'|' : '|'})
let g:AutoPairsMultilineClose = 0

" CtrlP
" PyMatcher for CtrlP
let g:ctrlp_match_func = { 'match': 'pymatcher#PyMatch' }

let g:ctrlp_switch_buffer = 'Et'
let g:ctrlp_user_command = 'ag %s --files-with-matches --nocolor -g ""'
nmap <Tab> :CtrlPMRU<Cr>
let ctrlp_mruf_relative = 1
let g:ctrlp_prompt_mappings = {
  \ 'PrtInsert("c")': ['<c-p>'],
  \ 'AcceptSelection("e")': ['<c-o>', '<cr>']
  \ }
let g:ctrlp_match_window = 'bottom,order:btt,min:1,max:12,results:30'

" strip trailing whitespaces
let g:DeleteTrailingWhitespace = 1
let g:DeleteTrailingWhitespace_Action = 'delete'

" multiple cursors
" let g:multi_cursor_use_default_mapping=0
" let g:multi_cursor_exit_from_insert_mode = 0
" let g:multi_cursor_exit_from_visual_mode=0
"
" let g:multi_cursor_next_key='<C-n>'
" let g:multi_cursor_prev_key='<C-p>'
" let g:multi_cursor_skip_key='<C-x>'
" let g:multi_cursor_quit_key='<C-c>'

" typescript 2
autocmd FileType javascript,javascript.jsx,typescript,typescript.tsx nmap <silent> <Leader>d <Plug>(coc-definition)
autocmd FileType javascript,javascript.jsx,typescript,typescript.tsx nmap <silent> <Leader>t <Plug>(coc-type-definition)
autocmd FileType javascript,javascript.jsx,typescript,typescript.tsx nmap <silent> <Leader>r <Plug>(coc-references-used)
autocmd FileType javascript,javascript.jsx,typescript,typescript.tsx nmap <buffer> <Leader>m :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('m', 'in')
  endif
endfunction

nmap <silent> <Leader>of :NvimTreeFindFile<Cr><C-w>=

if neobundle#tap('vim-test')
  let g:test#strategy = 'neovim_sticky'
  let test#neovim_sticky#reopen_window = 1
  let test#ruby#rspec#executable = 'bin/docker_rspec'
  let test#neovim#term_position = 'vert'

  nmap <silent> <Leader>s :TestNearest<Cr>
  nmap <silent> <Leader>S :TestFile<Cr>
  nmap <silent> <Leader>l :TestLast<Cr>

  call neobundle#untap()
endif

" enable syntax highlighting for tsx
autocmd BufNewFile,BufRead *.tsx set filetype=typescript.tsx

" autocomplete css
autocmd FileType css set omnifunc=csscomplete#CompleteCSS

autocmd VimEnter * NvimTreeOpen

" allow JSX in normal JS files
let g:jsx_ext_required = 0

" Disable arrow keys for the great good
inoremap  <Up>     <NOP>
inoremap  <Down>   <NOP>
inoremap  <Left>   <NOP>
inoremap  <Right>  <NOP>
noremap   <Up>     <NOP>
noremap   <Down>   <NOP>
noremap   <Left>   <NOP>
noremap   <Right>  <NOP>

if &term =~ '256color'
  " disable Background Color Erase (BCE) so that color schemes
  " render properly when inside 256-color tmux and GNU screen.
  " see also http://snk.tuxfamily.org/log/vim-256color-bce.html
  set t_ut=
endif

" Stop using arrows in command mode
cmap <C-h> <Left>
cmap <C-l> <Right>
cmap <C-k> <Up>
cmap <C-j> <Down>

" Window navigation
nmap <C-h> <C-w>h
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <C-l> <C-w>l

" Window navigation
nmap <C-]> <Plug>(coc-diagnostic-next)
nmap <C-[> <Plug>(coc-diagnostic-prev)

set clipboard=unnamed

" copy current file path to register
nmap cp :let @+ = expand("%")<CR>
nmap cP :let @+ = expand("%:p")<CR>

" keep cursor on current position, when using *
nnoremap * y*

" don't use esc to quit insert mode
imap <c-c> <esc>
nnoremap <Esc> <Nop>
nnoremap <C-c> :nohlsearch<CR>

" ariline icons
let g:airline_powerline_fonts = 1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" MULTIPURPOSE TAB KEY
" Indent if we're at the beginning of a line. Else, do completion.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use tab for trigger completion with characters ahead and navigate
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

set makeprg=gcc\ -Wall\ -o\ %<.out\ %

" Shortcut to rapidly toggle `set list`
nmap <leader>l :set list!<CR>
" Jump to previous location
nmap <leader>c <C-O>

" Use the same symbols as TextMate for tabstops and EOLs
set listchars=tab:▸\ ,eol:¬

augroup CustomHighlights
  autocmd!
  " use light shade for default text
  autocmd VimEnter * hi Normal ctermbg=NONE guibg=NONE guifg=#e6eaea
  autocmd VimEnter * hi NormalNC ctermbg=NONE guibg=NONE guifg=#e6eaea
  autocmd VimEnter * hi NvimTreeNormal ctermbg=NONE guibg=NONE guifg=#e6eaea
  autocmd VimEnter * hi TelescopeNormal guibg=NONE
  autocmd VimEnter * hi TelescopeBorder guibg=NONE

  " autocmd VimEnter * hi NonText ctermbg=NONE guibg=NONE
  " autocmd VimEnter * hi WinSeparator ctermbg=241 ctermfg=241

  " hide > sign in ctrlp menu
  autocmd VimEnter * hi CtrlPLinePre ctermfg=0 guifg=#000000
  autocmd VimEnter * hi clear QuickFixLine
  " remove bg from diagnostic virtual messages
  autocmd VimEnter * hi! DiagnosticVirtualTextError guibg=NONE
  autocmd VimEnter * hi! DiagnosticVirtualTextInfo guibg=NONE

  " set cursorline
  " autocmd VimEnter * hi CursorLine term=NONE cterm=NONE guibg=NONE
  " autocmd VimEnter * hi QuickFixLine ctermbg=NONE
augroup END

" fix typescript syntax in nvim@0.5.0
hi link typescriptReserved Keyword
hi link typescriptParens Operator
hi link typescriptNull Type

" float popup scroll
nnoremap <nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"

" exit terminal mode by pressing Esc
tnoremap <Esc> <C-\><C-n>

" Output the highlight group under the cursor
"
" This function will output the entire stack of hightlight groups being applied. The stack is
" outputted in the correct order from top to bottom. Vim will walk through the stack from top to
" bottom and apply the first defined highlight group found.
function! SynStack()
  for i1 in synstack(line("."), col("."))
    let i2 = synIDtrans(i1)
    let n1 = synIDattr(i1, "name")
    let n2 = synIDattr(i2, "name")
    echo n1 "->" n2
  endfor
endfunction

" You can also create a convenience mapping
map <F2> <cmd>call SynStack()<cr>
