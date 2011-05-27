" Jon Phenow's .vimrc

" Tell vim to remember certain things when we exit
"  '10  :  marks will be remembered for up to 10 previously edited files
"  "100 :  will save up to 100 lines for each register
"  :20  :  up to 20 lines of command-line history will be remembered
"  %    :  saves and restores the buffer list
"  n... :  where to save the viminfo files
set viminfo='10,\"100,:20,%,n~/.viminfo

" Epix to return the cursor to position of last open session
if has("autocmd")
 au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
 \| exe "normal g'\"" | endif
endif

" Enable vim powers
set nocompatible
setlocal formatoptions=ctnqro
setlocal comments+=n:*,n:#

" Highlight the syntax!
syntax on
:colorscheme ir_black
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
filetype plugin on
:autocmd Bufread,BufNewFile *.py* set ft=python
:autocmd Bufread,BufNewFile *.html* set ft=php
:autocmd Bufread,BufNewFile *.ctp* set ft=php
:autocmd Bufread,BufNewFile *.php* set ft=php
:autocmd Bufread,BufNewFile *.xml* set ft=xml
:autocmd Bufread,BufNewFile *.sql* set ft=mysql
:autocmd Bufread,BufNewFile *.java* set ft=java

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
source ~/.vim/plugin/fugitive.vim

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
" inoremap <c-x> <esc>l?\$<cr>y2w:let @/=""<CR>o$GLOBALS['logger']->log_export( <esc>pa, CW_LOG_DEV, 'JRP: <esc>pa' );<esc>
" noremap <c-x> l?\$<cr>y2w:let @/=""<CR>o$GLOBALS['logger']->log_export( <esc>pa, CW_LOG_DEV, 'JRP: <esc>pa' );<esc>

" Clockwork sourcery.  Not sure what this is supposed to do...
" inoremap <c-@> l?\$<cr>wyw:let @/=""<CR>o$n_<esc>pi  =  count( $<esc>pi );<CR>for ( $i = 0; $i < $n_<esc>pi; ++$i ) {<CR><esc>
" noremap <c-@> l?\$<cr>wyw:let @/=""<CR>o$n_<esc>pi  =  count( $<esc>pi );<CR>for ( $i = 0; $i < $n_<esc>pi; ++$i ) {<CR><esc>

" Magically create new functions
inoremap <c-f> /**<cr> * Jon Phenow (JRP) forgot to change this<cr>*<cr>* @author Jon Phenow <jphenow@jphenow.com><cr>*<cr>* @param   mixed  $changeme<cr>* @return  void<cr><bs>**/<cr><cr>public function  ( ) {<cr><cr>}<esc>kkwwhi

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
" iabbr authore author Jon Phenow <j.phenow@gmail.com>
" iabbr lpushor $GLOBALS['logger']->pushor_level( CW_LOG_DB );
" iabbr lpoplevel $GLOBALS['logger']->pop_level( );
