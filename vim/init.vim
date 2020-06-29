" Jon Phenow's .vmrc

call plug#begin()
Plug 'ncm2/ncm2'
Plug 'roxma/nvim-yarp'
" NOTE: you need to install completion sources to get completions. Check
" our wiki page for a list of sources: https://github.com/ncm2/ncm2/wiki
"Plug 'ncm2/ncm2-bufword'
"Plug 'ncm2/ncm2-path'
"Plug 'ncm2/ncm2-go'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'tpope/vim-fugitive'
Plug 'preservim/nerdtree'
Plug 'scrooloose/nerdcommenter'
Plug 'itchyny/lightline.vim'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'airblade/vim-gitgutter'

" Plug 'rakr/vim-one'
Plug 'ayu-theme/ayu-vim'
call plug#end()

set termguicolors     " enable true colors support
" BEGINPLUG:vim-one
" let g:airline_theme='one'
" colorscheme one
" set background=dark " for the dark version
" set background=light " for the light version
" ENDPLUG:vim-one
" BEGINPLUG:ayu-vim
" let ayucolor="light"  " for light version of theme
" let ayucolor="mirage" " for mirage version of theme
let ayucolor="dark"   " for dark version of theme
colorscheme ayu
" ENDPLUG:ayu-vim

nmap <silent> ]h :<C-U>execute v:count1 . "GitGutterNextHunk"<CR>
nmap <silent> [h :<C-U>execute v:count1 . "GitGutterPrevHunk"<CR>

" Enable vim powers
set nocompatible
setlocal formatoptions=ctnqro
setlocal comments+=n:*,n:#
if $TMUX != ''
  set clipboard=unnamed
endif

" ----------------------------------------------------------------------------
"  Remapping
" ----------------------------------------------------------------------------

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

" change the mapleader from \ to ,
let mapleader=","

" exit to normal mode with 'jj'
inoremap jj <ESC>
inoremap kk <ESC>

" reflow paragraph with Q in normal and visual mode
nnoremap Q gqap
vnoremap Q gq

" Quickly edit/reload the vimrc file
nmap <silent> <leader>ev :e $MYVIMRC<CR>
nmap <silent> <leader>sv :so $MYVIMRC<CR>

" sane movement with wrap turned on
if (&textwidth < 50)
    nnoremap j gj
    nnoremap k gk
    vnoremap j gj
    vnoremap k gk
    nnoremap <Down> gj
    nnoremap <Up> gk
    vnoremap <Down> gj
    vnoremap <Up> gk
    inoremap <Down> <C-o>gj
    inoremap <Up> <C-o>gk
endif

" Rename current file
function! RenameFile()
  let old_name = expand('%')
  let new_name = input('New file name: ', expand('%'))
  if new_name != '' && new_name != old_name
    exec ':saveas ' . new_name
    exec ':silent !rm ' . old_name
    redraw!
  endif
endfunction
:command! RenameFile :call RenameFile()
map <leader>q :RenameFile<cr>

" Promot Variable to Rspec let
function! PromoteToLet()
  :normal! dd
  :normal! P
  :.s/\(\w\+\) = \(.*\)$/let(:\1) { \2 }/
  :normal ==
endfunction
:command! PromoteToLet :call PromoteToLet()
:map <leader>p :PromoteToLet<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" RUNNING TESTS DESTROY ALL SOFTWARE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! RunTestFile(...)
  if a:0
    let command_suffix = a:1
  else
    let command_suffix = ""
  endif

  " Run the tests for the previously-marked file.
  let in_test_file = match(expand("%"), '\(.feature\|_spec.rb\|_shared_example.rb\)$') != -1
  if in_test_file
    call SetTestFile()
  elseif !exists("t:grb_test_file")
    return
  end
  call RunTests(t:grb_test_file . command_suffix)
endfunction

function! RunNearestTest()
  let spec_line_number = line('.')
  call RunTestFile(":" . spec_line_number . " -b")
endfunction

function! SetTestFile()
  " Set the spec file that tests will be run for.
  let t:grb_test_file=@%
endfunction

function! RunTests(filename)
  " Write the file and run tests for the given filename
  :w
  :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
  :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
  :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
  :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
  :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
  :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
  if match(a:filename, '\.feature$') != -1
    exec ":!script/features " . a:filename
  else
    if filereadable("script/test")
      exec ":!script/test " . a:filename
    elseif filereadable("Gemfile")
      exec ":!bundle exec rspec --color " . a:filename
    else
      exec ":!rspec --color " . a:filename
    end
  end
endfunction
map <leader>r :call RunTestFile()<cr>
map <leader>R :call RunNearestTest()<cr>
map <leader>a :call RunTests('')<cr>
map <leader>A :w\|:!script/features<cr>
map <leader>w :w\|:!script/features --profile wip<cr>

set list
set listchars=tab:».,trail:.,extends:>,precedes:<,nbsp:.

autocmd Bufread,BufNewFile *.py* set ft=python
"autocmd Bufread,BufNewFile *.html set ft=php
autocmd Bufread,BufNewFile *.ctp* set ft=php
autocmd Bufread,BufNewFile *.php* set ft=php
autocmd Bufread,BufNewFile *.xml* set ft=xml
autocmd Bufread,BufNewFile *.sql* set ft=mysql
autocmd Bufread,BufNewFile *.java* set ft=java
autocmd Bufread,BufNewFile *.rb set ft=ruby
autocmd Bufread,BufNewFile *.jbuilder* set ft=ruby
autocmd Bufread,BufNewFile *.xml.builder* set ft=ruby
autocmd Bufread,BufNewFile *.slim set ft=slim
autocmd Bufread,BufNewFile *.go set ft=go
autocmd FileType php set omnifunc=phpcomplete#CompletePHP
autocmd filetype python set expandtab
autocmd filetype html,xml set listchars-=tab:>·
autocmd filetype go set nolist

"au FileType markdown set textwidth=115 formatoptions=t1
"au FileType markdown autocmd InsertEnter * set formatoptions+=a
"au FileType markdown autocmd InsertLeave * set formatoptions-=a
"au FileType markdown noremap Q gqip

" Fix poor spec-file highlight finder
autocmd BufRead,BufNewFile *_\(spec\|shared_example\).rb syn keyword rubyRspec described_class shared_examples expect to double with describe context it specify it_should_behave_like before after setup subject its shared_examples_for shared_context let
highlight def link rubyRspec Function

" ----------------------------------------------------------------------------
"  Text Formatting
" ----------------------------------------------------------------------------
"Indents
set autoindent
set copyindent
set smartindent
set shiftround

" All things tab
let tabBlacklist = ['go']
set softtabstop=2
set shiftwidth=2
set tabstop=4
set expandtab
set nosmarttab

autocmd filetype go set tabstop=2
autocmd filetype go set noexpandtab
autocmd filetype go set smarttab

set formatoptions+=n       " support for numbered/bullet lists
"set textwidth=80           " wrap at 80 chars by default
set textwidth=0
set virtualedit=block      " allow virtual edit in visual block ..

" Clear hlsearch highlights
noremap <F6> :let @/=""<CR>:echo "Highlights Cleared"<CR>
:nnoremap <CR> :nohlsearch<cr>

" Epix to return the cursor to position of last open session
au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
      \| exe "normal g'\"" | endif


let html_my_rendering = 1
highlight htmlBold cterm=bold
highlight htmlBoldUnderline cterm=bold,underline
highlight htmlBoldUnderlineItalic cterm=bold,underline ctermfg=DarkGray ctermbg=NONE
highlight htmlUnderline cterm=underline
highlight htmlUnderlineItalic cterm=underline ctermfg=DarkGray ctermbg=NONE
highlight htmlItalic ctermfg=DarkGray ctermbg=NONE

" Shortcuts to vertical- or horizontal-split on filename
:command Hf :sp <cfile>    " can also be done with CTRL-w f
:command Vf :vsp <cfile>

" Allow for split window expand / collapse using CTRL-j / CTRL-k.  Useful for
" editing many files in one window, switching back and forth.
map <A-J> <c-w>j<c-w>_
map <A-K> <c-w>k<c-w>_
imap <c-l> <space>=><space>
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

let g:switchmode = "buffers"

" Same as MapForBuffers but calling ":only" blows up on start-up
noremap <c-j> :only<cr>:bnext<cr>
inoremap <c-j> <esc>:only<cr>:bnext<cr>
noremap <c-k> :only<cr>:bprev<cr>
inoremap <c-k> <esc>:only<cr>:bprev<cr>

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

function DeleteHiddenBuffers()
    let tpbl=[]
    call map(range(1, tabpagenr('$')), 'extend(tpbl, tabpagebuflist(v:val))')
    for buf in filter(range(1, bufnr('$')), 'bufexists(v:val) && index(tpbl, v:val)==-1')
        silent execute 'bwipeout' buf
    endfor
endfunction

" Handy buffer shortcuts
noremap <c-p> :call DeleteHiddenBuffers()<cr>
inoremap <c-p> <esc>:call DeleteHiddenBuffers()<cr>
noremap <c-c> :bd<cr>
inoremap <c-c> <esc>:bd<cr>
noremap <s-k> :ls<cr>

" ----------------------------------------------------------------------------
"  UI
" ----------------------------------------------------------------------------

" Tell vim to remember certain things when we exit
"  '10  :  marks will be remembered for up to 10 previously edited files
"  "100 :  will save up to 100 lines for each register
"  :20  :  up to 20 lines of command-line history will be remembered
"  %    :  saves and restores the buffer list
"  n... :  where to save the viminfo files
set viminfo='10,\"100,:20,%,n~/.viminfo

set cursorline " highlight current line

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

" Line numbers. Turn on at startup, F7 toggle
:set number
:map <F7> :set invnumber<CR>
set noshowcmd              " don't display incomplete commands
set nolazyredraw           " turn off lazy redraw
set wildmenu               " turn on wild menu
set wildmode=list:longest,full
set ch=2                   " command line height
set backspace=2            " allow backspacing over everything in insert mode
"set backspace=indent,eol,start
set whichwrap+=<,>,h,l,[,] " backspace and cursor keys wrap to
set shortmess=filtIoOA     " shorten messages
set report=0               " tell us about changes
set nostartofline          " don't jump to the start of line when scrolling

" Match my brackets
set showmatch

" History
set history=1000
set undolevels=1000
set wildignore=*.swp,*.bak,*.pyc,*.class
set title
set visualbell
set noerrorbells

set nobackup
set noswapfile

" ----------------------------------------------------------------------------
" Visual Cues
" ----------------------------------------------------------------------------

set showmatch              " brackets/braces that is
set mat=5                  " duration to show matching brace (1/10 sec)

" Search
set noincsearch              " do incremental searching
set laststatus=2           " always show the status line
set ignorecase             " ignore case when searching
set hlsearch             " don't highlight searches
set visualbell             " shut the fuck up
"set noincsearch
"set hlsearch
" highlight Search ctermbg=LightGray


" ---------------------------------------------------------------------------
"  Strip all trailing whitespace in file
" ---------------------------------------------------------------------------

function StripWhitespace()
    exec ':%s/ \+$//gc'
endfunction
map <s-s> :call StripWhitespace()<CR>

let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/](vendor[\/]rails)',
  \ }

map <silent> <Leader>t :CtrlP<cr>
map <silent> <Leader>t :CtrlP .<cr>
map <silent> <Leader>m :CtrlPMixed<cr>
map <silent> <Leader>z :ClearCtrlPCache<cr>\|:CtrlP<cr>
map <silent> <Leader>r :CtrlPMRU<cr>
map <silent> <Leader>b :CtrlPBuffer<cr>

map <silent> <Leader>gm :CtrlP app/models<cr>
map <silent> <Leader>gc :CtrlP app/controllers<cr>
map <silent> <Leader>gv :CtrlP app/views<cr>
map <silent> <Leader>ge :CtrlP app/helpers<cr>
map <silent> <Leader>gl :CtrlP lib<cr>
map <silent> <Leader>gp :CtrlP public<cr>
map <silent> <Leader>gt :CtrlP test<cr>
map <silent> <Leader>gs :CtrlP spec<cr>
map <silent> <Leader>gd :CtrlP db<cr>
map <silent> <Leader>gC :CtrlP config<cr>
map <silent> <Leader>gV :CtrlP vendor<cr>
map <silent> <Leader>gF :CtrlP factories<cr>
map <silent> <Leader>gh :CtrlP ~/<cr>
"nnoremap <silent> <leader>T :ClearCtrlPCache<cr>\|:CtrlP<cr>

" function! InsertTabWrapper()
"   let col = col('.') - 1
"   if !col || getline('.')[col - 1] !~ '\k'
"     return "\<tab>"
"   else
"     return "\<c-n>"
"   endif
" endfunction
" " Tab wrapper
" imap <silent> <tab> <c-r>=InsertTabWrapper()<CR>
" imap <silent> <s-tab> <c-p>

map <C-F> :Ack<space><C-r><C-w>

map <c-w>d :%s/\s*$//g \| :nohlsearch<cr>

" Bda -  Delete all open buffers.
command! -nargs=0 -bang Bda
      \ :call BufDeleteAll('<bang>')
function! BufDeleteAll(bang)
  let last_buffer = bufnr('$')
  let n = 1
  while n <= last_buffer
    if a:bang == '' && getbufvar(n, '&modified')
      echohl ErrorMsg
      echomsg 'No write since last change for buffer'
            \ n '(add ! to override)'
      echohl None
      return 0
    endif
    let n = n+1
  endwhile

  let delete_count = 0
  let n = 1
  while n <= last_buffer
    if buflisted(n)
      silent exe 'bdel' . a:bang . ' ' . n
      if ! buflisted(n)
        let delete_count = delete_count+1
      endif
    endif
    let n = n+1
  endwhile

  if delete_count == 1
    echomsg delete_count "buffer deleted"
  elseif delete_count > 1
    echomsg delete_count "buffers deleted"
  endif
endfunction

map <leader>a :Bda<cr>

map <leader>s :w\|:!%<cr>

" Want to turn fooBar into foo_bar? Press crs (coerce to snake_case). MixedCase
" (crm), camelCase (crc), snake_case (crs), and UPPER_CASE (cru) are all just 3
" keystrokes away. These commands support repeat.vim.
" Courtesy of vim-abolish

" Default Ruby-Conque Maps
"nmap <silent> <Leader>rcrr :call RunRubyCurrentFileConque()<CR>
nmap <silent> <Leader>rc :call RunRspecCurrentFileConque()<CR>
nmap <silent> <Leader>rcll :call RunRspecCurrentLineConque()<CR>
"nmap <silent> <Leader>rccc :call RunCucumberCurrentFileConque()<CR>
"nmap <silent> <Leader>rccl :call RunCucumberCurrentLineConque()<CR>
"nmap <silent> <Leader>rcRR :call RunRakeConque()<CR>
"nmap <silent> <Leader>rcrl :call RunLastConqueCommand()<CR>

map <leader>e :call RelatedSpecVOpen()<CR>
"nnoremap <silent> ,<C-s> :call RelatedSpecOpen()<CR>

" Cmd-Shift-R for RSpec
nmap <silent> <D-R> :call RunRspecCurrentFileConque()<CR>
" Cmd-Shift-L for RSpec Current Line
nmap <silent> <D-L> :call RunRspecCurrentLineConque()<CR>
" ,Cmd-R for Last conque command
nmap <silent> ,<D-R> :call RunLastConqueCommand()<CR>

"map <leader>p :s/\:\<\(\w\+\)\>\s\+=>\s\+/\1: /g <cr>
"map <leader>l :%s/\:\<\(\w\+\)\>\s\+=>\s\+/\1: /g <cr>
"map <leader>pl :s/\<\(\w\+\)\>\:\s\+/\:\1 => /g <cr>
"map <leader>lp :%s/\<\(\w\+\)\>\:\s\+/\:\1 => /g <cr>

nnoremap <Leader>H :call<SID>LongLineHLToggle()<cr>
hi OverLength ctermbg=none cterm=none
match OverLength /\%>80v/
fun! s:LongLineHLToggle()
 if !exists('w:longlinehl')
  let w:longlinehl = matchadd('ErrorMsg', '.\%>80v', 0)
  echo "Long lines highlighted"
 else
  call matchdelete(w:longlinehl)
  unl w:longlinehl
  echo "Long lines unhighlighted"
 endif
endfunction

nnoremap <Leader>h :call<SID>EightyLine()<cr>
fun! s:EightyLine()
 if !exists('w:eightyline')
  let w:eightyline = 1
  :set colorcolumn=80  " highlight three columns after 'textwidth'
  :highlight ColorColumn ctermbg=16 guibg=#000000
 else
  unl w:eightyline
  :set colorcolumn=80  " highlight three columns after 'textwidth'
  :highlight ColorColumn NONE
 endif
endfunction

map <leader>o :w\|:!bundle exec rake spec<cr>
map <Leader>i :call RunCurrentSpecFile()<CR>
map <Leader>u :call RunNearestSpec()<CR>
map <Leader>l :call RunLastSpec()<CR>
"map <leader>i :w\|:!ft %<cr>

autocmd FileType ruby,eruby let g:rubycomplete_buffer_loading = 1
autocmd FileType ruby,eruby let g:rubycomplete_classes_in_global = 1
autocmd FileType ruby,eruby let g:rubycomplete_rails = 1

let g:lightline = {
      \   'component': {
      \     'readonly': '%{&readonly?"⭤":""}',
      \   },
      \   'component_function': {
      \     'filename': 'MyFilename',
      \   },
      \ }

function! MyFilename()
  return ('' != expand('%') ? expand('%') : '[No Name]')
endfunction

let g:tagbar_ctags_bin = "/usr/local/Cellar/ctags/5.8_1/bin/ctags"
let g:tagbar_left = 1
nnoremap <Leader>ct :TagbarToggle<cr>
nnoremap <F8> :TagbarToggle<cr>

if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif


" BEGINPLUG:ncm2 enable ncm2 for all buffers
"autocmd BufEnter * call ncm2#enable_for_buffer()
"
"" IMPORTANT: :help Ncm2PopupOpen for more information
"set completeopt=noinsert,menuone,noselect
"
"" suppress the annoying 'match x of y', 'The only match' and 'Pattern not
"" found' messages
"set shortmess+=c
"
"" CTRL-C doesn't trigger the InsertLeave autocmd . map to <ESC> instead.
"inoremap <c-c> <ESC>
"
"" When the <Enter> key is pressed while the popup menu is visible, it only
"" hides the menu. Use this mapping to close the menu and also start a new
"" line.
"inoremap <expr> <CR> (pumvisible() ? "\<c-y>\<cr>" : "\<CR>")
"
"" Use <TAB> to select the popup menu:
"inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
"inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
"
"" wrap existing omnifunc
"" Note that omnifunc does not run in background and may probably block the
"" editor. If you don't want to be blocked by omnifunc too often, you could
"" add 180ms delay before the omni wrapper:
""  'on_complete': ['ncm2#on_complete#delay', 180,
""               \ 'ncm2#on_complete#omni', 'csscomplete#CompleteCSS'],
"au User Ncm2Plugin call ncm2#register_source({
"      \ 'name' : 'css',
"      \ 'priority': 9,
"      \ 'subscope_enable': 1,
"      \ 'scope': ['css','scss'],
"      \ 'mark': 'css',
"      \ 'word_pattern': '[\w\-]+',
"      \ 'complete_pattern': ':\s*',
"      \ 'on_complete': ['ncm2#on_complete#omni', 'csscomplete#CompleteCSS'],
"      \ })
" ENDPLUG:ncm2 enable ncm2 for all buffers

" BEGINPLUG:coc.nvim
" TextEdit might fail if hidden is not set.
set hidden

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Give more space for displaying messages.
set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
" <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current line.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of LS, ex: coc-tsserver
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings using CoCList:
" Show all diagnostics.
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>
" ENDPLUG:coc.vim

set mouse=a
