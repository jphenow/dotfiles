" Jon Phenow's .vimrc

" Tell vim to remember certain things when we exit
"  '10  :  marks will be remembered for up to 10 previously edited files
"  "100 :  will save up to 100 lines for each register
"  :20  :  up to 20 lines of command-line history will be remembered
"  %    :  saves and restores the buffer list
"  n... :  where to save the viminfo files
set viminfo='10,\"100,:20,%,n~/.viminfo

set showcmd

set cursorline " highlight current line
hi cursorline guibg=#333333 " highlight bg color of current line
hi CursorColumn guibg=#333333 " highlight cursor

if has('cmdline_info')
	set ruler " show the ruler
	set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%) " a ruler on steroids
	set showcmd " show partial commands in status line and
	" selected characters/lines in visual mode
endif
if has('statusline')
set laststatus=2
	" Broken down into easily includeable segments
	set statusline=%<%f\ " Filename
	set statusline+=%w%h%m%r " Options
	set statusline+=%{fugitive#statusline()} " Git Hotness
	set statusline+=\ [%{&ff}/%Y] " filetype
	set statusline+=\ [%{getcwd()}] " current dir
	"set statusline+=\ [A=\%03.3b/H=\%02.2B] " ASCII / Hexadecimal value of char
	set statusline+=%=%-14.(%l,%c%V%)\ %p%% " Right aligned file nav info
endif

" Fix large paste
set pastetoggle=<F2>

" use ';' rather than ':' for w or wq
nnoremap ; :

" Fix paragraph
vmap Q gq
nmap Q gqap

" Forget arrow keys, bitch
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>

" Finally can sudo after a file is openned
cmap w!! w !sudo tee % >/dev/null

" Be able to scroll wrapped lines of text
nnoremap j gj
nnoremap k gk

call pathogen#helptags()
call pathogen#runtime_append_all_bundles()

" change the mapleader from \ to ,
let mapleader=","

" Quickly edit/reload the vimrc file
nmap <silent> <leader>ev :e $MYVIMRC<CR>
nmap <silent> <leader>sv :so $MYVIMRC<CR>

" Epix to return the cursor to position of last open session
if has("autocmd")
 au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
 \| exe "normal g'\"" | endif
endif

" Enable vim powers
set nocompatible
setlocal formatoptions=ctnqro
setlocal comments+=n:*,n:#
set clipboard=unnamed

" Highlight the syntax!
syntax on
":colorscheme ir_black
"see http://ethanschoonover.com/solarized/vim-colors-solarized for
"further info on options
let g:solarized_termcolors=256
let g:solarized_termtrans=1 
let g:solarized_bold=1 
let g:solarized_underline=1 
let g:solarized_italic=1
if has('gui_running')
	set background=light
else
	set background=dark
endif
colorscheme solarized
let html_my_rendering = 1
highlight htmlBold cterm=bold
highlight htmlBoldUnderline cterm=bold,underline
highlight htmlBoldUnderlineItalic cterm=bold,underline ctermfg=DarkGray ctermbg=NONE
highlight htmlUnderline cterm=underline
highlight htmlUnderlineItalic cterm=underline ctermfg=DarkGray ctermbg=NONE
highlight htmlItalic ctermfg=DarkGray ctermbg=NONE

"Indents
set autoindent
set copyindent
set shiftround
set smarttab

" All things tab
set tabstop=4
set shiftwidth=4
set noexpandtab

" Line numbers. Turn on at startup, F7 toggle
:set number
:map <F7> :set invnumber<CR> 

" Search
set ignorecase
set smartcase
set noincsearch
set hlsearch
" highlight Search ctermbg=LightGray

" Clear hlsearch highlights
noremap <F6> :let @/=""<CR>:echo "Highlights Cleared"<CR>

" Match my brackets
set showmatch

" Awesome tab-completion
" set wildmode=list:longest

" Fix my HID
set backspace=indent,eol,start
set mouse=a
set textwidth=0

" Tweak filetypes
filetype plugin indent on
set list
set listchars=tab:>.,trail:.,extends:#,nbsp:.
if has('autocomd')
	:autocmd Bufread,BufNewFile *.py* set ft=python
	:autocmd Bufread,BufNewFile *.html* set ft=php
	:autocmd Bufread,BufNewFile *.ctp* set ft=php
	:autocmd Bufread,BufNewFile *.php* set ft=php
	:autocmd Bufread,BufNewFile *.xml* set ft=xml
	:autocmd Bufread,BufNewFile *.sql* set ft=mysql
	:autocmd Bufread,BufNewFile *.java* set ft=java
	autocmd FileType php set omnifunc=phpcomplete#CompletePHP
	autocmd filetype python set expandtab
	autocmd filetype html,xml set listchars-=tab:>.
endif

" Spell checking
:map <F10> :setlocal spell! spell?<CR>
:set spellfile=~/.vim.spellfile.utf-8.add
:highlight clear SpellBad
:highlight SpellBad term=standout ctermfg=1 term=underline cterm=underline
:highlight clear SpellCap
:highlight SpellCap term=underline cterm=underline
:highlight clear SpellRare
:highlight SpellRare term=underline cterm=underline
:highlight clear SpellLocal
:highlight SpellLocal term=underline cterm=underline

" Save fold status.  TODO: Figure out how to prevent warning messages on * and :help
" au BufWinLeave * mkview
" au BufWinEnter * silent loadview

" Shortcuts to vertical- or horizontal-split on filename
:command Hf :sp <cfile>    " can also be done with CTRL-w f 
:command Vf :vsp <cfile>

" Shortcut to open the SVN base file for the current file
:command Sd :vert diffsplit %:h/.svn/text-base/%:t.svn-base

" Allow tab-completion when not at the beginning of a line
"function InsertTabWrapper()
"      let col = col('.') - 1
"      if !col || getline('.')[col - 1] !~ '\k'
"          return "\<tab>"
"      else
"          return "\<c-n>"
"      endif
"endfunction 
" inoremap <tab> <c-r>=InsertTabWrapper()<cr>

" Configure tab-completion
" set completeopt=menu,preview,longest

" Allow for split window expand / collapse using CTRL-j / CTRL-k.  Useful for
" editing many files in one window, switching back and forth.
map <c-j> <c-w>j<c-w>_
map <c-k> <c-w>k<c-w>_
set winminheight=0

" Amendment to the window-switching tip above.  This allows them
" to be hidden out of sight for more real estate.
set hidden

" Begin switch mode code: handle either buffer or window c-j/c-k switches
function MapForBuffers()
	noremap <c-j> :only<cr>:bnext<cr>
	inoremap <c-j> <esc>:only<cr>:bnext<cr>
	noremap <c-k> :only<cr>:bprev<cr>
	inoremap <c-k> <esc>:only<cr>:bprev<cr>
	:only
endfunction

function MapForWindows()
	:unhide
	noremap <c-j> <c-w>j<c-w>_
	inoremap <c-j> <esc><c-w>j<c-w>_
	noremap <c-k> <c-w>k<c-w>_
	inoremap <c-k> <esc><c-w>k<c-w>_
endfunction

function MapSwitchMode()
	if g:switchmode == "windows"
		call MapForWindows()
	else
		call MapForBuffers()
	endif
endfunction

let g:switchmode = "windows"
call MapSwitchMode()

function ToggleSwitchMode()
	if g:switchmode == "windows"
		let g:switchmode = "buffers"
	else
		let g:switchmode = "windows"
	endif
	call MapSwitchMode()
	
endfunction

noremap <F4> :call ToggleSwitchMode()<cr>:echo "Switching mode now: " . g:switchmode<cr>
" End switch mode code

" Handy buffer shortcuts
noremap <c-c> :bd<cr>
inoremap <c-c> <esc>:bd<cr>
noremap <s-k> :ls<cr>

" Plugins?  Plugins!
source ~/.vim/plugin/Align.vim
source ~/.vim/plugin/AlignMaps.vim
source ~/.vim/plugin/VisualSearch.vim
source ~/.vim/plugin/CamelCaseMotion.vim
source ~/.vim/plugin/NERD_commenter.vim
source ~/.vim/plugin/lodgeit.vim
source ~/.vim/plugin/scmdiff.vim

" Toggle shortcut for NERDTree
:map <F5> :NERDTreeToggle<CR>

" Configure :Align
call AlignCtrl( 'p1P1l+','=>', '=' )
map <c-a> vip:Align<cr>

" CTags
set cpo+=d
set tags=./tags/all

" History
set history=1000
set undolevels=1000
set wildignore=*.swp,*.bak,*.pyc,*.class
set title
set visualbell
set noerrorbells

set nobackup
set noswapfile
