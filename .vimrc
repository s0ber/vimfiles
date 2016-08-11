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
NeoBundle 'kien/ctrlp.vim'               " fuzzy file search
NeoBundle 'JazzCore/ctrlp-cmatcher'      " faster and better matcher for CtrlP, requires installation
NeoBundle 'fisadev/vim-ctrlp-cmdpalette' " fuzzy command search
NeoBundle 'd11wtq/ctrlp_bdelete.vim'     " allow to remove buffers via CtrlP prompt

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
NeoBundle 'ternjs/tern_for_vim'          " javascript refactoring and code analysis

" textmate-like snippets
NeoBundle 'SirVer/ultisnips'
NeoBundle 's0ber/vim-es6'
NeoBundle 's0ber/vim-ultisnips-react'

" syntax errors highlight
NeoBundle 'scrooloose/syntastic'
NeoBundle 'ngmy/vim-rubocop' " rubocop warnings

" tests runners
NeoBundle 'janko-m/vim-test'
NeoBundle 'p0deje/vim-cucumber', {'rev': '_merge'}

" Interactive command execution
NeoBundle 'Shougo/vimproc', {'build': {'mac': 'make -f make_mac.mak'}}

" async scripts dispatching
NeoBundle 'p0deje/vim-dispatch-vimshell', {'depends': ['tpope/vim-dispatch', 'Shougo/vimshell.vim']}

" tmux runner
NeoBundle 'christoomey/vim-tmux-runner'

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
nmap <Leader>as :Ags<Space>

" save airline bar when reopening vim
set laststatus=2

" highlight custom files
autocmd BufRead,BufNewFile *file set filetype=ruby

" GCC compiler
au BufEnter *.c compiler gcc
au BufWritePost *.c make

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

" syntax errors highlight
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_javascript_checkers = ['eslint'] " highlight js syntax errors
let g:syntastic_javascript_eslint_exec = 'eslint_d'
let g:syntastic_coffee_checkers = ['coffeelint']
let g:syntastic_coffee_coffeelint_exec = 'coffeelint'
let g:syntastic_ruby_checkers = ['rubocop'] " highlight js syntax errors
let g:syntastic_echo_current_error=0
let g:syntastic_ignore_files = ['.sass$']

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

" autocomplete css
autocmd FileType css set omnifunc=csscomplete#CompleteCSS

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

set makeprg=gcc\ -Wall\ -o\ %<.out\ %

" Shortcut to rapidly toggle `set list`
nmap <leader>l :set list!<CR>

" Use the same symbols as TextMate for tabstops and EOLs
set listchars=tab:▸\ ,eol:¬
