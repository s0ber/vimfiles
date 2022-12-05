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
NeoBundle 'tpope/vim-sensible'           " basic settings
NeoBundle 'vim-airline/vim-airline', 'master'            " light version of powerline
NeoBundle 'tpope/vim-repeat'             " repeat custom actions with .

" text formatting
NeoBundle 'jiangmiao/auto-pairs'         " autoclose quotes, brackets, etc
NeoBundle 'tpope/vim-surround'           " quote selected text
NeoBundle 'tomtom/tcomment_vim'          " comment and uncomment
NeoBundle 'DeleteTrailingWhitespace'     " remove trailing whitespaces
NeoBundle 'terryma/vim-multiple-cursors' " sublime-inspired multiple cursors
NeoBundle 'tpope/vim-endwise'            " automatically end code blocks
NeoBundle 'tpope/vim-unimpaired'         " mappings for paired actions

" integration with ag
NeoBundle 'rking/ag.vim'
NeoBundle 'gabesoft/vim-ags'

" fuzzy search
NeoBundle 'ctrlpvim/ctrlp.vim'               " fuzzy file search
" NeoBundle 'JazzCore/ctrlp-cmatcher'      " faster and better matcher for CtrlP, requires installation
NeoBundle 'FelikZ/ctrlp-py-matcher'
" NeoBundle 'fisadev/vim-ctrlp-cmdpalette' " fuzzy command search

" files tree management
NeoBundle 'scrooloose/nerdtree'          " project tree navigation
NeoBundle 'taiansu/nerdtree-ag'          " search via NERDTree

" filetypes support
NeoBundle 'kchmck/vim-coffee-script'     " support for coffeescript
NeoBundle 'vim-ruby/vim-ruby'            " support for ruby (always use latest vim-ruby)
NeoBundle 'tpope/vim-haml'               " support for haml
NeoBundle 'slim-template/vim-slim'       " support for slim
NeoBundle 'othree/html5.vim'             " support for html5
NeoBundle 'mtscout6/vim-cjsx'            " support for cjsx
NeoBundle 'derekwyatt/vim-scala'         " support for scala
" NeoBundle 'pangloss/vim-javascript'      " support for javascript
NeoBundle 'mxw/vim-jsx'                  " support for jsx
NeoBundle 'groenewege/vim-less'          " support for less
NeoBundle 'digitaltoad/vim-pug'          " support for pug (former Jade)
NeoBundle 'leafgarland/typescript-vim'   " support for typescript (syntax and indentation)
NeoBundle 'peitalin/vim-jsx-typescript'  " support for tsx (syntax and indentation)
" NeoBundle 'Quramy/tsuquyomi'             " typescript IDE

" colorscheme
NeoBundle 'vv9k/vim-github-dark'
NeoBundle 'dracula/vim.git'

" typescript IDE 2
NeoBundle 'neoclide/coc.nvim', 'master', {
\ 'build' : {
\     'windows' : 'yarn install --frozen-lockfile',
\     'cygwin' : 'yarn install --frozen-lockfile',
\     'mac' : 'yarn install --frozen-lockfile',
\     'linux' : 'yarn install --frozen-lockfile',
\     'unix' : 'yarn install --frozen-lockfile'
\    }
\ }

" textmate-like snippets
" NeoBundle 'SirVer/ultisnips'
NeoBundle 's0ber/vim-es6'
" NeoBundle 's0ber/vim-ultisnips-react'

" syntax errors highlight
" NeoBundle 'ngmy/vim-rubocop' " rubocop warnings

" tests runners
" NeoBundle 'vim-test/vim-test'
NeoBundle 'p0deje/vim-cucumber', {'rev': '_merge'}

" Interactive command execution
" NeoBundle 'Shougo/vimproc', {
" \ 'build' : {
" \     'windows' : 'tools\\update-dll-mingw',
" \     'cygwin' : 'make -f make_cygwin.mak',
" \     'mac' : 'make -f make_mac.mak',
" \     'linux' : 'make',
" \     'unix' : 'gmake',
" \    },
" \ }

" async scripts dispatching
" NeoBundle 'p0deje/vim-dispatch-vimshell', {'depends': ['tpope/vim-dispatch', 'Shougo/vimshell.vim']}

" tmux runner
" NeoBundle 'christoomey/vim-tmux-runner'
"

" icons
NeoBundle 'ryanoasis/vim-devicons'

" make quicklist modifiable
" NeoBundle 'stefandtw/quickfix-reflector.vim'

" workspace
call neobundle#end()

" required:
syntax enable
filetype plugin indent on

" If there are uninstalled bundles found on startup, this will conveniently
" prompt you to install them.
NeoBundleCheck

if !has('nvim')
  runtime! plugin/sensible.vim
endif

set langmenu=en_US
let $LANG = 'en_US'
set linespace=1          " increase space between lines
set number               " show line numbers
" set cursorline           " highlight current line
set lazyredraw           " faster scrolling
set noswapfile           " no *.swp artifacts
set scrolloff=5          " Keep at least 5 lines visible when scrolling
set nowrap               " Disabled wrapping
set ruler                " show the cursor position all the time
set laststatus=2         " Always display the status line
set showcmd              " display incomplete commands
set autowrite            " Automatically :write before running commands
set exrc                 " enable per-directory .vimrc files
set secure               " disable unsafe commands in local .vimrc files
set history=50           " history size
set undofile             " tell it to use an undo file
set undodir=~/.vim/undo  " set a directory to store the undo history
set wildmenu             " better completion for cmd mode
set nowritebackup        " save file only once
set synmaxcol=300
set background=dark

" Indentation
set smartindent
set tabstop=2
set shiftwidth=2
set expandtab
set backspace=2

set modifiable

" Open new split panes to right and bottom, which feels more natural
set splitbelow
set splitright

" colorscheme settings
colorscheme monokai

" search tweaks
set hlsearch
set incsearch

" Preview effects of command incrementally (e.g. :substitute). Neovim only.
if has('nvim')
	set inccommand=nosplit
endif

set ignorecase
set smartcase " doesn't ignore case only when uppercase letters are specified
set wildignore+=*/coverage/*        " Linux/MacOSX

" coc settings
set hidden
set nobackup
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
let g:agprg='ag --hidden --smart-case --column --ignore={".git","node_modules","*gql.types.tsx"}'
nmap <Leader>ag :Ag!<Space>
nmap <Leader>as :Ags<Space>
let g:ag_apply_qmappings=0 " don't apply default mappings
" never end up in NERDTree when selecting file from quickfix list
nnoremap <expr> <CR> &buftype == 'quickfix' ? "<C-W>k<C-W>l<C-W>j<C-W>j<C-W>j\<CR>" : '<CR>'
nmap <expr> o &buftype == 'quickfix' ? '<CR>' : 'o'

" highlight custom files
autocmd BufRead,BufNewFile *file set filetype=ruby
au BufNewFile,BufRead *.ejs set filetype=html

" GCC compiler
au BufEnter *.c compiler gcc
au BufWritePost *.c make

" Autoclose pipe in Ruby
autocmd FileType ruby
  \ let b:AutoPairs = g:AutoPairs |
  \ let b:AutoPairs['|'] = '|'

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

" strip trailing whitespaces
let g:DeleteTrailingWhitespace = 1
let g:DeleteTrailingWhitespace_Action = 'delete'

" multiple cursors
let g:multi_cursor_use_default_mapping=0
let g:multi_cursor_exit_from_insert_mode = 0
let g:multi_cursor_exit_from_visual_mode=0

let g:multi_cursor_next_key='<C-n>'
let g:multi_cursor_prev_key='<C-p>'
let g:multi_cursor_skip_key='<C-x>'
let g:multi_cursor_quit_key='<C-c>'

" expand snippet
let g:UltiSnipsExpandTrigger='<C-e>'
let g:UltiSnipsJumpForwardTrigger='<C-j>'
let g:UltiSnipsJumpBackwardTrigger='<C-k>'

" typescript 2
autocmd FileType typescript,typescript.tsx nmap <silent> <Leader>d <Plug>(coc-definition)
autocmd FileType typescript,typescript.tsx nmap <silent> <Leader>t <Plug>(coc-type-definition)
autocmd FileType typescript,typescript.tsx nmap <silent> <Leader>r <Plug>(coc-references-used)
autocmd FileType typescript,typescript.tsx nmap <buffer> <Leader>m :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" NERDTree
" let g:NERDTreeWinPos   = 'right'
let g:NERDTreeWinSize  = 30
let g:NERDTreeMinimalUI = 1
let g:NERDTreeChDirMode = 2
let NERDTreeIgnore     = ['^tags$', '\.DS_Store$']
let NERDTreeShowHidden = 0

" NERDTree
nmap <silent> <Leader>on :NERDTreeFind<Cr><C-w>=
nmap <silent> <Leader>of :NERDTreeFind<Cr><C-w>=

if neobundle#tap('vim-dispatch')
  let g:dispatch_compilers = {'bundle exec': ''}
  call neobundle#untap()
endif

if neobundle#tap('vim-tmux-runner')
  let g:VtrPercentage = 35
  let g:VtrOrientation = 'h'
endif

if neobundle#tap('vim-test')
  let g:test#strategy = 'vtr'

  nmap <silent> <Leader>r :TestNearest<Cr>
  nmap <silent> <Leader>R :TestFile<Cr>
  nmap <silent> <Leader>l :TestLast<Cr>

  call neobundle#untap()
endif

if neobundle#tap('vimshell.vim')
  let g:vimshell_escape_colors = [
    \ '#6c6c6c', '#dc322f', '#859900', '#b58900',
    \ '#268bd2', '#d33682', '#2aa198', '#c0c0c0',
    \ '#383838', '#cb4b16', '#586e75', '#cb4b16',
    \ '#839496', '#d33682', '#2aa198', '#ffffff',
    \ ]

  autocmd FileType vimshell setlocal wrap

  call neobundle#untap()
endif


" enable syntax highlighting for tsx
autocmd BufNewFile,BufRead *.tsx set filetype=typescript.tsx

" autocomplete css
autocmd FileType css set omnifunc=csscomplete#CompleteCSS

" open nerdtree immediately
autocmd VimEnter * NERDTreeToggle

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

if has("gui_running")
  " Cursor customization
  set guicursor+=a:blinkon0  " disable blinking
  set guifont=Monaco

  " remove MacVim scrollbars
  set guioptions-=R
  set guioptions-=r
  set guioptions-=L

  " always show tab bar
  set showtabline=2

  " Make MacVim nicer
  set transparency=11
endif

" copy current file path to register
nmap cp :let @+ = expand("%")<CR>
nmap cP :let @+ = expand("%:p")<CR>

" keep cursor on current position, when using *
nnoremap * y*

" don't use esc to quit insert mode
imap <c-c> <esc>
nnoremap <C-c> :noh<CR>

" ariline icons
let g:airline_powerline_fonts = 1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" MULTIPURPOSE TAB KEY
" Indent if we're at the beginning of a line. Else, do completion.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! InsertTabWrapper()
    let col = col('.') - 1
    if pumvisible()
      return "\<c-n>"
    elseif !col || getline('.')[col - 1] !~ '\k'
      return "\<tab>"
    else
      return coc#refresh()
    endif
endfunction
autocmd FileType * inoremap <expr> <tab> InsertTabWrapper()
inoremap <s-tab> <c-p>

set makeprg=gcc\ -Wall\ -o\ %<.out\ %

" Shortcut to rapidly toggle `set list`
nmap <leader>l :set list!<CR>
" Jump to previous location
nmap <leader>c <C-O>

" Use the same symbols as TextMate for tabstops and EOLs
set listchars=tab:▸\ ,eol:¬

" set cursorline
hi CursorLine term=NONE cterm=NONE guibg=NONE
hi QuickFixLine ctermbg=NONE

hi CocFloating ctermbg=237
highlight Normal ctermbg=0
highlight NonText ctermbg=0

" fix typescript syntax in nvim@0.5.0
hi link typescriptReserved Keyword
hi link typescriptParens Operator
hi link typescriptNull Type

" float popup scroll
nnoremap <nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
