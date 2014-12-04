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
NeoBundle 'terryma/vim-multiple-cursors' " sublime-inspired multiple cursors
NeoBundle 'tpope/vim-endwise'            " automatically end code blocks

" tabs
NeoBundle 'Yggdroot/indentLine'          " indentation guides

" integration with ag
NeoBundle 'rking/ag.vim'

" fuzzy search
NeoBundle 'kien/ctrlp.vim'               " fuzzy file search
NeoBundle 'JazzCore/ctrlp-cmatcher'      " faster and better matcher for CtrlP, requires installation
NeoBundle 'fisadev/vim-ctrlp-cmdpalette' " fuzzy command search

" files tree management
NeoBundle 'scrooloose/nerdtree'          " project tree navigation
NeoBundle 'jistr/vim-nerdtree-tabs'      " keep NERDTree open in tabs
NeoBundle 'taiansu/nerdtree-ag'          " search folder from NERDTree

" panes
NeoBundle 't9md/vim-choosewin'           " interactive panes switching

" filetypes support
NeoBundle 'kchmck/vim-coffee-script'     " CoffeeScript support
NeoBundle 'vim-ruby/vim-ruby'            " use latest vim-ruby
NeoBundle 'tpope/vim-haml'               " support for haml
NeoBundle 'slim-template/vim-slim'       " support for slim
NeoBundle 'othree/html5.vim'             " support for html5

" workspace
NeoBundle 'airblade/vim-rooter'          " automatic working directory update
NeoBundle 'vim-scripts/mru.vim'

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
" set foldcolumn=1         " increase vsplits margin
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
let g:indentLine_char = '│'

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

" Use very magic
" nnoremap / /\v
" cnoremap %s/ %s/\v

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
let g:ctrlp_working_path_mode = 'rw'
nmap <Tab> :CtrlPBuffer<Cr>
" nmap cp :CtrlPCmdPalette<Cr>

" strip trailing whitespaces
let g:DeleteTrailingWhitespace = 1
let g:DeleteTrailingWhitespace_Action = 'delete'

" multiple cursors
let g:multi_cursor_exit_from_insert_mode = 0

" NERDTree
" let g:NERDTreeWinPos   = 'right'
let g:NERDTreeWinSize  = 30
let g:NERDTreeMinimalUI = 1
let g:NERDTreeChDirMode = 2
let NERDTreeIgnore     = ['^tags$', '\.DS_Store$']
let NERDTreeShowHidden = 0
let g:nerdtree_tabs_smart_startup_focus = 2
autocmd vimenter * if !argc() | NERDTree | endif
let g:nerdtree_tabs_open_on_console_startup = 2
let g:nerdtree_tabs_open_on_gui_startup = 2

" NERDTree
nmap <silent> <Leader>on :NERDTreeTabsToggle<Cr><C-w>=
nmap <silent> <Leader>of :NERDTreeFind<Cr><C-w>=

" ChooseWin
let g:choosewin_overlay_enable = 1
let g:choosewin_statusline_replace = 0
let g:choosewin_blink_on_land = 0
nmap <Space> <Plug>(choosewin)

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

" Indentation
vmap < <gv
vmap > >gv

" Cursor customization
set guicursor+=a:blinkon0  " disable blinking

set guifont=Monaco

if has("gui_running")
  set clipboard=unnamed

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
