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
NeoBundle 'bling/vim-airline'            " light version of powerline

" text formatting
NeoBundle 'jiangmiao/auto-pairs'         " autoclose quotes, brackets, etc
NeoBundle 'tpope/vim-surround'           " quote selected text
NeoBundle 'tomtom/tcomment_vim'          " comment and uncomment
NeoBundle 'DeleteTrailingWhitespace'     " remove trailing whitespaces
NeoBundle 'tpope/vim-endwise'            " automatically end code blocks

" integration with ag
NeoBundle 'rking/ag.vim'

" fuzzy search
NeoBundle 'kien/ctrlp.vim'               " fuzzy file search
NeoBundle 'JazzCore/ctrlp-cmatcher'      " faster and better matcher for CtrlP, requires installation
NeoBundle 'fisadev/vim-ctrlp-cmdpalette' " fuzzy command search
NeoBundle 'd11wtq/ctrlp_bdelete.vim'     " allow to remove buffers via CtrlP prompt

" files tree management
NeoBundle 'scrooloose/nerdtree'          " project tree navigation

" filetypes support
NeoBundle 'kchmck/vim-coffee-script'     " support for coffeescript
NeoBundle 'vim-ruby/vim-ruby'            " support for ruby (always use latest vim-ruby)
NeoBundle 'tpope/vim-haml'               " support for haml
NeoBundle 'slim-template/vim-slim'       " support for slim
NeoBundle 'othree/html5.vim'             " support for html5

" workspace
call neobundle#end()

" required:
syntax enable
filetype plugin indent on

" If there are uninstalled bundles found on startup, this will conveniently
" prompt you to install them.
NeoBundleCheck

runtime! plugin/sensible.vim

let g:airline_right_sep = '◀'  " airline separators

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
colorscheme Monokai

" search tweaks
set hlsearch
set incsearch
set ignorecase
set smartcase " doesn't ignore case only when uppercase letters are specified

" Let's not be retarded
let mapleader = ','

" Ag tweaks
let g:agprg='ag --smart-case --column'
nmap <Leader>ag :Ag!<Space>

" save airline bar when reopening vim
set laststatus=2

" highlight custom files
autocmd BufRead,BufNewFile *file set filetype=ruby

" Autoclose pipe in Ruby
autocmd FileType ruby
  \ let b:AutoPairs = g:AutoPairs |
  \ let b:AutoPairs['|'] = '|'

" CtrlP
let g:ctrlp_switch_buffer = 'Et'
let g:ctrlp_match_func  = {'match' : 'matcher#cmatch'}
let g:ctrlp_user_command = 'ag %s --files-with-matches --nocolor -g ""'
let g:ctrlp_working_path_mode = 'a'
nmap <Tab> :CtrlPBuffer<Cr>
let g:ctrlp_prompt_mappings = {
  \ 'PrtInsert("c")': ['<c-p>'],
  \ 'AcceptSelection("e")': ['<c-o>', '<cr>']
  \ }
call ctrlp_bdelete#init()

" strip trailing whitespaces
let g:DeleteTrailingWhitespace = 1
let g:DeleteTrailingWhitespace_Action = 'delete'

" NERDTree
" let g:NERDTreeWinPos   = 'right'
let g:NERDTreeWinSize  = 30
let g:NERDTreeMinimalUI = 1
let g:NERDTreeChDirMode = 2
let NERDTreeIgnore     = ['^tags$', '\.DS_Store$']
let NERDTreeShowHidden = 0

" NERDTree
nmap <silent> <Leader>on :NERDTreeToggle<Cr><C-w>=
nmap <silent> <Leader>of :NERDTreeFind<Cr><C-w>=

" autocomplete css
autocmd FileType css set omnifunc=csscomplete#CompleteCSS

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

nnoremap <CR> :noh<CR>

" copy current file path to register
nmap cp :let @+ = expand("%")<CR>
nmap cP :let @+ = expand("%:p")<CR>

" add empty line by pressing enter without entering insert mode
nnoremap <C-J> m`o<Esc>``
nnoremap <C-K> m`O<Esc>``

" keep cursor on current position, when using *
nnoremap * y*

" don't use ecs to quit insert mode
imap <c-c> <esc>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" MULTIPURPOSE TAB KEY
" Indent if we're at the beginning of a line. Else, do completion.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    else
        return "\<c-p>"
    endif
endfunction
inoremap <expr> <tab> InsertTabWrapper()
inoremap <s-tab> <c-n>
