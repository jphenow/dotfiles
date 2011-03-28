" Jon Phenow's .vimrc

" Enable vim powers
set nocompatible

" Highlight the syntax!
syntax on
let html_my_rendering = 1
highlight htmlBold cterm=bold
highlight htmlBoldUnderline cterm=bold,underline
highlight htmlBoldUnderlineItalic cterm=bold,underline ctermfg=DarkGray ctermbg=NONE
highlight htmlUnderline cterm=underline
highlight htmlUnderlineItalic cterm=underline ctermfg=DarkGray ctermbg=NONE
highlight htmlItalic ctermfg=DarkGray ctermbg=NONE

" All things tab
set tabstop=4
set shiftwidth=4
set noexpandtab
set autoindent

" Status line:
set laststatus=2
" Matt's enhanced status line:
" set statusline=%F%m%r%h%w\ %30.([ff=%{&ff}/ft=%Y]\ [a=\%03.3b/h=\%02.2B]%)\ %40.((%4l,%4v)\ \ \ \ %3p%%\ \ %LL%)

" Line numbers.  TODO: figure out how to do this conditionally for different filetypes
" set number -- 

" Search
set ignorecase
set smartcase
set noincsearch
set hlsearch
highlight Search ctermbg=LightGray

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
:autocmd Bufread,BufNewFile *.html* set ft=php
:autocmd Bufread,BufNewFile *.php* set ft=php
:autocmd Bufread,BufNewFile *.xml* set ft=xml
:autocmd Bufread,BufNewFile *.sql* set ft=mysql

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
au BufWinLeave * mkview
au BufWinEnter * silent loadview

" Shortcuts to vertical- or horizontal-split on filename
:command Hf :sp <cfile>    " can also be done with CTRL-w f 
:command Vf :vsp <cfile>

" Shortcut to open the SVN base file for the current file
:command Sd :vert diffsplit %:h/.svn/text-base/%:t.svn-base

" Allow tab-completion when not at the beginning of a line
function InsertTabWrapper()
      let col = col('.') - 1
      if !col || getline('.')[col - 1] !~ '\k'
          return "\<tab>"
      else
          return "\<c-n>"
      endif
endfunction 
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

" Clockwork-specific PHP magic
" source ~/.vim/clockwork.vim

" Plugins?  Plugins!
source ~/.vim/plugin/Align.vim
source ~/.vim/plugin/AlignMaps.vim
source ~/.vim/plugin/VisualSearch.vim
source ~/.vim/plugin/CamelCaseMotion.vim
source ~/.vim/plugin/NERD_tree.vim
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

" Allow for easy insertion of standard log statements.
" inoremap <c-l> $GLOBALS['logger']->log( "JRP: ", CW_LOG_DEV );<esc>5bw a
" noremap <c-l> o$GLOBALS['logger']->log( "JRP: ", CW_LOG_DEV );<esc>5bw a

" Grab the previous variable and yank it, drop log_export line below it.
" inoremap <c-x> <esc>l?\$<cr>y2w:let @/=""<CR>o$GLOBALS['logger']->log_export( <esc>pa, CW_LOG_DEV, 'MNP: <esc>pa' );<esc>
" noremap <c-x> l?\$<cr>y2w:let @/=""<CR>o$GLOBALS['logger']->log_export( <esc>pa, CW_LOG_DEV, 'MNP: <esc>pa' );<esc>

" Clockwork sourcery.  Not sure what this is supposed to do...
" inoremap <c-@> l?\$<cr>wyw:let @/=""<CR>o$n_<esc>pi  =  count( $<esc>pi );<CR>for ( $i = 0; $i < $n_<esc>pi; ++$i ) {<CR><esc>
" noremap <c-@> l?\$<cr>wyw:let @/=""<CR>o$n_<esc>pi  =  count( $<esc>pi );<CR>for ( $i = 0; $i < $n_<esc>pi; ++$i ) {<CR><esc>

" Magically create new functions
" inoremap <c-f> /**<cr> * Mike Phenow (MNP) forgot to change this<cr>*<cr>* @author Mike Phenow <phenow@clockwork.net><cr>*<cr>* @param   mixed  $changeme<cr>* @return  void<cr><bs>**/<cr><cr>public function  ( ) {<cr><cr>}<esc>kkwwhi

" MCG iabbrs

" iabbr log log_debug( );<esc>Bhi

" iabbr echo <?php echo( ); ?><esc>BBhi

" iabbr bread <esc>O<esc>O<?php ob_start( ); ?><cr><?php $breadcrumbs = ob_get_clean( ); ?><esc>kA

" iabbr rsbt <esc>O<cr><?php ob_start( ); ?><cr><?php $right_side_bar_top = ob_get_clean( ); ?><esc>kA

" iabbr rsbb <esc>O<cr><?php ob_start( ); ?><cr><?php $right_side_bar_bottom = ob_get_clean( ); ?><esc>kA

" Some good ideas from Matt for iabbrs
" iabbr newlog $GLOBALS['logger']->log( "MG:", CW_LOG_DEV );<esc>T:i
" iabbr ife if ( ) {hhhi
" iabbr switche switch ( ) {hhhi
" iabbr whilee while ( ) {hhhi
" iabbr authore author Matt Gray <matt@clockwork.net>
" iabbr lpushor $GLOBALS['logger']->pushor_level( CW_LOG_DB );
" iabbr lpoplevel $GLOBALS['logger']->pop_level( );
" iabbr /* /* */<esc>3ha

" =============================================================================
" from Matt's .vimrc, but not yet understood:

" set cin
" set cinkeys=0{,0},0),:,!^F,o,O,e
" set cino==s
" set tags=~/vimtags/tags
" " $ must be a keyword
" :set iskeyword=@,48-57,_,192-255

" syntax enable
" " Word wrap off
" noremap <F11> :set textwidth=0<CR>:echo "Wrapping Off"<CR>
" " Word wrap on
" noremap <F10> :set textwidth=72<CR>:echo "Wrapping On"<CR>
" " Toggle Autoindent
" noremap <F9> :set autoindent!<CR>:set autoindent?<CR>
" " Toggle C-style indentation
" noremap <F8> :set paste!<CR>:set paste?<CR>
" " Toggle line numbering
" noremap <F7> :set nu!<CR>:set nu?<CR>

" autocmd BufReadPost *
" \ if line("'\"") > 0 && line ("'\"") <= line("$") |
" \   exe "normal g'\"" |
" \ endif

" iabbr ife if ( ) {hhhi
" iabbr switche switch ( ) {hhhi
" iabbr whilee while ( ) {hhhi
" iabbr authore author Matt Gray <matt@clockwork.net>
" iabbr lpushorDB $GLOBALS['logger']->pushor_level( CW_LOG_DB );
" iabbr lpoplevel $GLOBALS['logger']->pop_level( );

" func Eatchar(pat)
	" let c = nr2char(getchar(0))
	" return ( c =~ a:pat ) ? '' : c
" endfunc

" inoremap g $GLOBALS['']<esc>hi
" noremap  g i$GLOBALS['']<esc>hi
