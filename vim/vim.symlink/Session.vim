let SessionLoad = 1
if &cp | set nocp | endif
let s:cpo_save=&cpo
set cpo&vim
inoremap <silent> <S-Tab> =BackwardsSnippet()
imap <silent> <Plug>IMAP_JumpBack =IMAP_Jumpfunc('b', 0)
imap <silent> <Plug>IMAP_JumpForward =IMAP_Jumpfunc('', 0)
imap <F4> <Plug>ToggleBackground
imap <F5> <Plug>ToggleBackground
inoremap <Up> gk
inoremap <Down> gj
noremap  :bd
map  :set nodiff
snoremap <silent> 	 i<Right>=TriggerSnippet()
noremap <NL> j_
noremap  k_
snoremap  b<BS>
snoremap % b<BS>%
snoremap ' b<BS>'
nnoremap <silent> ,cc :call NERDComment(0, "norm")
vnoremap <silent> ,cc :call NERDComment(1, "norm")
nnoremap <silent> ,c  :call NERDComment(0, "toggle")
vnoremap <silent> ,c  :call NERDComment(1, "toggle")
nnoremap <silent> ,cm :call NERDComment(0, "minimal")
vnoremap <silent> ,cm :call NERDComment(1, "minimal")
nnoremap <silent> ,cs :call NERDComment(0, "sexy")
vnoremap <silent> ,cs :call NERDComment(1, "sexy")
nnoremap <silent> ,ci :call NERDComment(0, "invert")
vnoremap <silent> ,ci :call NERDComment(1, "invert")
nmap <silent> ,cy :call NERDComment(0, "yank")
vmap <silent> ,cy :call NERDComment(1, "yank")
nnoremap <silent> ,cl :call NERDComment(0, "alignLeft")
vnoremap <silent> ,cl :call NERDComment(1, "alignLeft")
nnoremap <silent> ,cr :call NERDComment(0, "alignRight")
vnoremap <silent> ,cr :call NERDComment(1, "alignRight")
nnoremap <silent> ,cb :call NERDComment(0, "alignBoth")
vnoremap <silent> ,cb :call NERDComment(1, "alignBoth")
nnoremap <silent> ,cn :call NERDComment(0, "nested")
vnoremap <silent> ,cn :call NERDComment(1, "nested")
nnoremap <silent> ,cu :call NERDComment(0, "uncomment")
vnoremap <silent> ,cu :call NERDComment(1, "uncomment")
nnoremap <silent> ,c$ :call NERDComment(0, "toEOL")
nmap <silent> ,cA :call NERDComment(0, "append")
nmap <silent> ,cI :call NERDComment(0, "prepend")
noremap ,d :call ruby_debugger#load_debugger() | call g:RubyDebugger.remove_breakpoints()
noremap ,c :call ruby_debugger#load_debugger() | call g:RubyDebugger.continue()
noremap ,n :call ruby_debugger#load_debugger() | call g:RubyDebugger.next()
noremap ,f :call ruby_debugger#load_debugger() | call g:RubyDebugger.finish()
noremap ,m :call ruby_debugger#load_debugger() | call g:RubyDebugger.open_breakpoints()
noremap ,v :call ruby_debugger#load_debugger() | call g:RubyDebugger.open_variables()
noremap ,t :call ruby_debugger#load_debugger() | call g:RubyDebugger.open_frames()
noremap ,s :call ruby_debugger#load_debugger() | call g:RubyDebugger.step()
nmap <silent> ,sv :so $MYVIMRC
nmap <silent> ,ev :e $MYVIMRC
noremap ,e :call ruby_debugger#load_debugger() | call g:RubyDebugger.exit()
noremap ,b :call ruby_debugger#load_debugger() | call g:RubyDebugger.toggle_breakpoint()
vmap <silent> ,w <Plug>CamelCaseMotion_w
omap <silent> ,w <Plug>CamelCaseMotion_w
nmap <silent> ,w <Plug>CamelCaseMotion_w
nnoremap ; :
inoremap ï o
noremap K :ls
nnoremap Q gqap
vnoremap Q gq
xmap S <Plug>VSurround
nmap SQ :mksession! ~/.vim/Session.vim:wqa
snoremap U b<BS>U
vmap [% [%m'gv``
nmap <silent> \t@ :AlignCtrl mIp1P1=l @:'a,.Align
nmap <silent> \aocom :AlignPush:AlignCtrl g /[*/]\acom:AlignPop
snoremap \ b<BS>\
vmap <silent> \Htd :<BS><BS><BS>ma'>\Htd
vmap <silent> \tt :<BS><BS><BS>ma'>\tt
vmap <silent> \tp@ :<BS><BS><BS>ma'>\tp@
vmap <silent> \tsq :<BS><BS><BS>ma'>\tsq
vmap <silent> \tsp :<BS><BS><BS>ma'>\tsp
vmap <silent> \tml :<BS><BS><BS>ma'>\tml
vmap <silent> \tab :<BS><BS><BS>ma'>\tab
vmap <silent> \t@ :<BS><BS><BS>ma'>\t@
vmap <silent> \t? :<BS><BS><BS>ma'>\t?
vmap <silent> \t= :<BS><BS><BS>ma'>\t=
vmap <silent> \t< :<BS><BS><BS>ma'>\t<
vmap <silent> \t; :<BS><BS><BS>ma'>\t;
vmap <silent> \t: :<BS><BS><BS>ma'>\t:
vmap <silent> \ts, :<BS><BS><BS>ma'>\ts,
vmap <silent> \t, :<BS><BS><BS>ma'>\t,
vmap <silent> \t| :<BS><BS><BS>ma'>\t|
vmap <silent> \anum :B s/\(\d\)\s\+\(-\=[.,]\=\d\)/\1@\2/ge:AlignCtrl mp0P0gv:Align [.,@]:'<,'>s/\([-0-9.,]*\)\(\s\+\)\([.,]\)/\2\1\3/ge:'<,'>s/@/ /ge
vmap <silent> \afnc :<BS><BS><BS>ma'>\afnc
vmap <silent> \adef :<BS><BS><BS>ma'>\adef
vmap <silent> \adec :<BS><BS><BS>ma'>\adec
vmap <silent> \ascom :<BS><BS><BS>ma'>\ascom
vmap <silent> \aocom :<BS><BS><BS>ma'>\aocom
vmap <silent> \acom :<BS><BS><BS>ma'>\acom
vmap <silent> \abox :<BS><BS><BS>ma'>\abox
vmap <silent> \a= :<BS><BS><BS>ma'>\a=
vmap <silent> \a< :<BS><BS><BS>ma'>\a<
vmap <silent> \a, :<BS><BS><BS>ma'>\a,
vmap <silent> \a? :<BS><BS><BS>ma'>\a?
vmap <silent> \Tsp :<BS><BS><BS>ma'>\Tsp
vmap <silent> \T@ :<BS><BS><BS>ma'>\T@
vmap <silent> \T= :<BS><BS><BS>ma'>\T=
vmap <silent> \T< :<BS><BS><BS>ma'>\T<
vmap <silent> \T: :<BS><BS><BS>ma'>\T:
vmap <silent> \Ts, :<BS><BS><BS>ma'>\Ts,
vmap <silent> \T, :<BS><BS><BS>ma'>\T,
vmap <silent> \T| :<BS><BS><BS>ma'>\T|
map <silent> \tdW@ :AlignCtrl v ^\s*/[/*]:AlignCtrl mWp1P1=l @:'a,.Align
map <silent> \tW@ :AlignCtrl mWp1P1=l @:'a,.Align
omap <silent> \t@ :AlignCtrl mIp1P1=l @:'a,.Align
omap <silent> \aocom :AlignPush:AlignCtrl g /[*/]\acom:AlignPop
vmap ]% ]%m'gv``
snoremap ^ b<BS>^
snoremap ` b<BS>`
vmap a% [%v]%
nmap cs <Plug>Csurround
nmap ds <Plug>Dsurround
nmap gx <Plug>NetrwBrowseX
xmap gS <Plug>VgSurround
vmap g? :call VsearchPatternSave()?/
vmap g/ :call VsearchPatternSave()//
vmap <silent> i,e <Plug>CamelCaseMotion_ie
vmap <silent> i,b <Plug>CamelCaseMotion_ib
vmap <silent> i,w <Plug>CamelCaseMotion_iw
omap <silent> i,e <Plug>CamelCaseMotion_ie
omap <silent> i,b <Plug>CamelCaseMotion_ib
omap <silent> i,w <Plug>CamelCaseMotion_iw
vnoremap j gj
nnoremap j gj
vnoremap k gk
nnoremap k gk
xnoremap <silent> s :echoerr 'surround.vim: Visual mode s has been removed in favor of S'
nmap ySS <Plug>YSsurround
nmap ySs <Plug>YSsurround
nmap yss <Plug>Yssurround
nmap yS <Plug>YSurround
nmap ys <Plug>Ysurround
nmap <Right> <Nop>
xmap <Right> <Nop>
nmap <Left> <Nop>
xmap <Left> <Nop>
snoremap <Left> bi
snoremap <Right> a
snoremap <BS> b<BS>
snoremap <silent> <S-Tab> i<Right>=BackwardsSnippet()
nnoremap <silent> <Plug>NetrwBrowseX :call netrw#NetrwBrowseX(expand("<cWORD>"),0)
vmap <silent> <Plug>IMAP_JumpBack `<i=IMAP_Jumpfunc('b', 0)
vmap <silent> <Plug>IMAP_JumpForward i=IMAP_Jumpfunc('', 0)
vmap <silent> <Plug>IMAP_DeleteAndJumpBack "_<Del>i=IMAP_Jumpfunc('b', 0)
vmap <silent> <Plug>IMAP_DeleteAndJumpForward "_<Del>i=IMAP_Jumpfunc('', 0)
nmap <silent> <Plug>IMAP_JumpBack i=IMAP_Jumpfunc('b', 0)
nmap <silent> <Plug>IMAP_JumpForward i=IMAP_Jumpfunc('', 0)
map <F7> :set invnumber 
noremap <F4> :call ToggleSwitchMode():echo "Switching mode now: " . g:switchmode
map <F10> :setlocal spell! spell?
noremap <F6> :let @/="":echo "Highlights Cleared"
vnoremap <Up> gk
vnoremap <Down> gj
nnoremap <Up> gk
nnoremap <Down> gj
omap <Right> <Nop>
omap <Left> <Nop>
omap <Down> <Nop>
omap <Up> <Nop>
map <F5> :NERDTreeToggle
nmap <SNR>4_WE <Plug>AlignMapsWrapperEnd
nmap <SNR>4_WS <Plug>AlignMapsWrapperStart
inoremap  :bd
imap S <Plug>ISurround
imap s <Plug>Isurround
inoremap <silent> 	 =TriggerSnippet()
inoremap <NL> j_
inoremap  k_
imap  <Plug>DiscretionaryEnd
inoremap <silent> 	 =ShowAvailableSnips()
imap  <Plug>Isurround
imap  <Plug>AlwaysEnd
inoremap jj 
inoremap kk 
cmap w!! w !sudo tee % >/dev/null
let &cpo=s:cpo_save
unlet s:cpo_save
set autoindent
set background=dark
set backspace=2
set cmdheight=2
set copyindent
set cpoptions=aABceFsd
set expandtab
set fileencodings=ucs-bom,utf-8,default,latin1
set formatoptions=ctqron
set helplang=en
set hidden
set history=1000
set ignorecase
set isident=@,48-57,_,192-255,$
set laststatus=2
set listchars=tab:>.,trail:.,extends:#,nbsp:.
set modelines=0
set mouse=a
set pastetoggle=<F2>
set report=0
set ruler
set rulerformat=%30(%=:b%n%y%m%r%w\ %l,%c%V\ %P%)
set runtimepath=~/.vim,~/.vim/bundle/Gemfile,~/.vim/bundle/Gist.vim,~/.vim/bundle/IndexedSearch,~/.vim/bundle/ack.vim,~/.vim/bundle/html5.vim,~/.vim/bundle/jquery,~/.vim/bundle/nerdtree,~/.vim/bundle/rdoc,~/.vim/bundle/scss-syntax.vim,~/.vim/bundle/snipmate.vim,~/.vim/bundle/tabular,~/.vim/bundle/textile.vim,~/.vim/bundle/vim-coffee-script,~/.vim/bundle/vim-colors-solarized,~/.vim/bundle/vim-cucumber,~/.vim/bundle/vim-endwise,~/.vim/bundle/vim-fugitive,~/.vim/bundle/vim-git,~/.vim/bundle/vim-haml,~/.vim/bundle/vim-javascript,~/.vim/bundle/vim-jquery,~/.vim/bundle/vim-latex,~/.vim/bundle/vim-markdown,~/.vim/bundle/vim-matchit,~/.vim/bundle/vim-rails,~/.vim/bundle/vim-repeat,~/.vim/bundle/vim-ruby,~/.vim/bundle/vim-ruby-debugger,~/.vim/bundle/vim-rvm,~/.vim/bundle/vim-shoulda,~/.vim/bundle/vim-surround,~/.vim/bundle/vim-tmux,/usr/share/vim/vimfiles,/usr/share/vim/vim73,/usr/share/vim/vimfiles/after,~/.vim/bundle/snipmate.vim/after,~/.vim/bundle/tabular/after,~/.vim/bundle/vim-coffee-script/after,~/.vim/after
set shiftround
set shiftwidth=2
set shortmess=filtIoOA
set showmatch
set smartindent
set softtabstop=2
set spellfile=~/.vim.spellfile.utf-8.add
set nostartofline
set statusline=%<%f\ %w%h%m%r%{fugitive#statusline()}\ [%{&ff}/%Y]\ [%{getcwd()}]%=%-14.(%l,%c%V%)\ %p%%
set noswapfile
set tabstop=4
set tags=./tags/all
set title
set updatetime=200
set viminfo='10,\"100,:20,%,n~/.viminfo
set virtualedit=block
set visualbell
set whichwrap=b,s,<,>,h,l,[,]
set wildignore=.sass-cache,tmp/restart.txt,tmp/debug.txt,cache/*,config/database.yml,config/amazon_s3.yml,config/paypal_express.yml,config/has_offers.yml,config/zencoder.yml,config/delayed_job.yml,config/tst_init.yml,config/star_tribune_xml_upload.yml,config/memcached.yml,config/server.yml,config/stat_ngin.yml,config/whoisxmlapi.yml,lib/perl/tmp/*,public/javascripts/*packaged.js,public/stylesheets/*packaged.css,.project,.tmp*,vendor/plugins/rack-bug,public/attachments/**/*,test/coverage.data,public/coverage,*.orig,*.sublime-*,*.sublime-*,.rvmrc,.yardoc,.bundle,db/*.sqlite3,db/*.sqlite3-journal,*.log,tmp/**/*,tmp/*,.yardoc,.yardopts,public/system/*,public/themes/*,public/javascripts/cache,public/stylesheets/cache,index/**/*,*.tmproj,*.autobackupbyrefinery.*,/refinerycms-*.gem,.autotest,.DS_Store,nbproject,.project,.redcar,*.rbc,*.swp,*.swo,.idea,*~,capybara-*html,data,config/newrelic.yml
set wildmenu
set wildmode=list:longest,full
set window=0
set winminheight=0
let s:so_save = &so | let s:siso_save = &siso | set so=0 siso=0
let v:this_session=expand("<sfile>:p")
silent only
cd ~/workspace/ngin
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
set shortmess=aoO
badd +140 app/controllers/jlo/site_controller.rb
badd +403 app/models/form_builder/survey_table.rb
badd +1 config.ru
badd +1 app/controllers/roster_player_controller.rb
badd +24 app/controllers/roster_player_import_controller.rb
badd +1 app/controllers/survey_report_controller.rb
badd +1 app/views/roster_player_import/new.html.erb
badd +11 test/integration/roster_test.rb
badd +1 test/integration/tst_integration_test.rb
badd +334 app/models/form_builder/survey_report.rb
badd +33 app/models/form_builder/roster_player_import.rb
badd +150 app/models/form_builder/question_filter.rb
badd +1 app/models/form_builder/survey.rb
badd +159 app/controllers/account_controller.rb
badd +3 app/models/email_address.rb
badd +1 app/controllers/users/passwords_controller.rb
badd +215 app/controllers/users_controller.rb
badd +7 app/models/user.rb
badd +39 test/integration/account_test.rb
badd +1 test/integration/game_test.rb
badd +39 app/models/persona_listener.rb
badd +1 app/mailers/account_mailer.rb
badd +14 app/views/account/listener_invitation.html.erb
badd +1 app/controllers/personas_controller.rb
badd +6 app/controllers/users/registrations_controller.rb
badd +62 app/mailers/activation_mailer.rb
badd +5 lib/custom_validators.rb
badd +9 test/integration/standings_test.rb
badd +12 test/integration/presentation_test.rb
badd +1 test/unit/form_builder/survey_report_test.rb
badd +28 test/unit/form_builder/roster_player_import_test.rb
badd +5 test/unit/form_builder/form_builder_test.rb
badd +1 test/unit/form_builder/choice_element_test.rb
badd +1 test/unit/form_builder/survey_test.rb
badd +37 test/test_helper.rb
badd +1 test/test_lib.rb
badd +14 test/unit/form_builder/survey_table_test.rb
badd +1 33
badd +1 app/controllers/api2/play_actions_controller.rb
badd +1 app/controllers/api2/active_resource_api_resource_controller.rb
badd +48 app/controllers/api2/api_resource_controller.rb
badd +1 app/models/resource/stat_ngin
badd +9 ~/.vimrc
silent! argdel *
edit app/controllers/api2/api_resource_controller.rb
set splitbelow splitright
wincmd _ | wincmd |
split
wincmd _ | wincmd |
split
wincmd _ | wincmd |
split
3wincmd k
wincmd w
wincmd w
wincmd w
set nosplitbelow
set nosplitright
wincmd t
set winheight=1 winwidth=1
exe '1resize ' . ((&lines * 0 + 33) / 67)
exe '2resize ' . ((&lines * 0 + 33) / 67)
exe '3resize ' . ((&lines * 61 + 33) / 67)
exe '4resize ' . ((&lines * 0 + 33) / 67)
argglobal
edit ~/.vim/doc/command-t.txt
setlocal autoindent
setlocal nobinary
setlocal bufhidden=
setlocal nobuflisted
setlocal buftype=help
setlocal nocindent
setlocal cinkeys=0{,0},0),:,0#,!^F,o,O,e
setlocal cinoptions=
setlocal cinwords=if,else,while,do,for,switch
setlocal colorcolumn=
setlocal comments=s1:/*,mb:*,ex:*/,://,b:#,:%,:XCOMM,n:>,fb:-
setlocal commentstring=/*%s*/
setlocal complete=.,w,b,u,t,i
setlocal completefunc=
setlocal copyindent
setlocal cryptmethod=
setlocal nocursorbind
setlocal nocursorcolumn
set cursorline
setlocal cursorline
setlocal define=
setlocal dictionary=
setlocal nodiff
setlocal equalprg=
setlocal errorformat=
setlocal expandtab
if &filetype != 'help'
setlocal filetype=help
endif
setlocal foldcolumn=0
setlocal nofoldenable
setlocal foldexpr=0
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldmarker={{{,}}}
setlocal foldmethod=manual
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal foldtext=foldtext()
setlocal formatexpr=
setlocal formatoptions=ntcroql
setlocal formatlistpat=^\\s*\\d\\+[\\]:.)}\\t\ ]\\s*
setlocal grepprg=
setlocal iminsert=0
setlocal imsearch=0
setlocal include=
setlocal includeexpr=
setlocal indentexpr=
setlocal indentkeys=0{,0},:,0#,!^F,o,O,e
setlocal noinfercase
setlocal iskeyword=!-~,^*,^|,^\",192-255
setlocal keywordprg=
setlocal nolinebreak
setlocal nolisp
set list
setlocal nolist
setlocal makeprg=
setlocal matchpairs=(:),{:},[:]
setlocal modeline
setlocal nomodifiable
setlocal nrformats=octal,hex
set number
setlocal nonumber
setlocal numberwidth=4
setlocal omnifunc=
setlocal path=
setlocal nopreserveindent
setlocal nopreviewwindow
setlocal quoteescape=\\
setlocal readonly
setlocal norelativenumber
setlocal noscrollbind
setlocal shiftwidth=2
setlocal noshortname
setlocal smartindent
setlocal softtabstop=2
setlocal nospell
setlocal spellcapcheck=/Users/jonphenow/.vim.spellfile.utf-8.add
setlocal spellfile=~/.vim.spellfile.utf-8.add
setlocal spelllang=en
setlocal statusline=
setlocal suffixesadd=
setlocal noswapfile
setlocal synmaxcol=3000
if &syntax != 'help'
setlocal syntax=help
endif
setlocal tabstop=8
setlocal tags=~/git/dotfiles/.git/tags,./tags/all
setlocal textwidth=78
setlocal thesaurus=
setlocal noundofile
setlocal nowinfixheight
setlocal nowinfixwidth
setlocal wrap
setlocal wrapmargin=0
silent! normal! zE
let s:l = 137 - ((59 * winheight(0) + 0) / 0)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
137
normal! 063l
wincmd w
argglobal
let s:cpo_save=&cpo
set cpo&vim
nmap <buffer> gf <Plug>RailsTabFind
nmap <buffer> f <Plug>RailsSplitFind
nnoremap <buffer> <silent> g} :exe        "ptjump =RubyCursorIdentifier()"
nnoremap <buffer> <silent> } :exe          "ptag =RubyCursorIdentifier()"
nnoremap <buffer> <silent> g] :exe      "stselect =RubyCursorIdentifier()"
nnoremap <buffer> <silent> g :exe        "stjump =RubyCursorIdentifier()"
nnoremap <buffer> <silent>  :exe v:count1."stag =RubyCursorIdentifier()"
nnoremap <buffer> <silent> ] :exe v:count1."stag =RubyCursorIdentifier()"
nnoremap <buffer> <silent>  :exe  v:count1."tag =RubyCursorIdentifier()"
nmap <buffer> gf <Plug>RailsFind
nnoremap <buffer> <silent> g] :exe       "tselect =RubyCursorIdentifier()"
nnoremap <buffer> <silent> g :exe         "tjump =RubyCursorIdentifier()"
let &cpo=s:cpo_save
unlet s:cpo_save
setlocal autoindent
setlocal nobinary
setlocal bufhidden=
setlocal buflisted
setlocal buftype=
setlocal nocindent
setlocal cinkeys=0{,0},0),:,0#,!^F,o,O,e
setlocal cinoptions=
setlocal cinwords=if,else,while,do,for,switch
setlocal colorcolumn=
setlocal comments=:#
setlocal commentstring=#\ %s
setlocal complete=.,w,b,u,t,i
setlocal completefunc=syntaxcomplete#Complete
setlocal copyindent
setlocal cryptmethod=
setlocal nocursorbind
setlocal nocursorcolumn
set cursorline
setlocal cursorline
setlocal define=^\\s*def\\s\\+\\(self\\.\\)\\=
setlocal dictionary=
setlocal nodiff
setlocal equalprg=
setlocal errorformat=
setlocal expandtab
if &filetype != 'ruby'
setlocal filetype=ruby
endif
setlocal foldcolumn=0
setlocal foldenable
setlocal foldexpr=0
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldmarker={{{,}}}
setlocal foldmethod=manual
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal foldtext=foldtext()
setlocal formatexpr=
setlocal formatoptions=ncroql
setlocal formatlistpat=^\\s*\\d\\+[\\]:.)}\\t\ ]\\s*
setlocal grepprg=
setlocal iminsert=0
setlocal imsearch=0
setlocal include=^\\s*\\<\\(load\\>\\|require\\>\\|autoload\\s*:\\=[\"']\\=\\h\\w*[\"']\\=,\\)
setlocal includeexpr=RailsIncludeexpr()
setlocal indentexpr=GetRubyIndent(v:lnum)
setlocal indentkeys=0{,0},0),0],!^F,o,O,e,=end,=else,=elsif,=when,=ensure,=rescue,==begin,==end
setlocal noinfercase
setlocal iskeyword=@,48-57,_,192-255,$
setlocal keywordprg=ri
setlocal nolinebreak
setlocal nolisp
set list
setlocal list
setlocal makeprg=
setlocal matchpairs=(:),{:},[:]
setlocal modeline
setlocal modifiable
setlocal nrformats=octal,hex
set number
setlocal number
setlocal numberwidth=4
setlocal omnifunc=
setlocal path=~/workspace/ngin,~/workspace/ngin/app,~/workspace/ngin/app/models,~/workspace/ngin/app/controllers,~/workspace/ngin/app/helpers,~/workspace/ngin/config,~/workspace/ngin/lib,~/workspace/ngin/app/views,~/workspace/ngin/app/views/api2/api_resource,~/workspace/ngin/public,~/workspace/ngin/test,~/workspace/ngin/test/unit,~/workspace/ngin/test/functional,~/workspace/ngin/test/integration,~/workspace/ngin/app/*,~/workspace/ngin/vendor,~/workspace/ngin/vendor/plugins/*/lib,~/workspace/ngin/vendor/plugins/*/test,~/workspace/ngin/vendor/rails/*/lib,~/workspace/ngin/vendor/rails/*/test,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/site_ruby/1.8,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/site_ruby/1.8/i686-darwin11.2.0,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/site_ruby,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/vendor_ruby/1.8,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/vendor_ruby/1.8/i686-darwin11.2.0,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/vendor_ruby,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/1.8,~/.rvm/rubies/ree-1.8.7-2011.12/
setlocal nopreserveindent
setlocal nopreviewwindow
setlocal quoteescape=\\
setlocal noreadonly
setlocal norelativenumber
setlocal noscrollbind
setlocal shiftwidth=2
setlocal noshortname
setlocal nosmartindent
setlocal softtabstop=2
setlocal nospell
setlocal spellcapcheck=/Users/jonphenow/.vim.spellfile.utf-8.add
setlocal spellfile=~/.vim.spellfile.utf-8.add
setlocal spelllang=en
setlocal statusline=
setlocal suffixesadd=.rb,.rhtml,.erb,.rxml,.builder,.rjs,.mab,.liquid,.haml,.dryml,.mn,.slim
setlocal noswapfile
setlocal synmaxcol=3000
if &syntax != 'ruby'
setlocal syntax=ruby
endif
setlocal tabstop=4
setlocal tags=~/workspace/ngin/tmp/tags,~/workspace/ngin/.git/ruby.tags,~/workspace/ngin/.git/tags,./tags/all,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/site_ruby/1.8/tags,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/site_ruby/1.8/i686-darwin11.2.0/tags,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/site_ruby/tags,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/vendor_ruby/1.8/tags,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/vendor_ruby/1.8/i686-darwin11.2.0/tags,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/vendor_ruby/tags,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/1.8/tags,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/1.8/i686-darwin11.2.0/tags,./tags,~/workspace/ngin/tags
setlocal textwidth=0
setlocal thesaurus=
setlocal noundofile
setlocal nowinfixheight
setlocal nowinfixwidth
setlocal wrap
setlocal wrapmargin=0
silent! normal! zE
let s:l = 48 - ((21 * winheight(0) + 0) / 0)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
48
normal! 0
wincmd w
argglobal
edit app/controllers/api2/active_resource_api_resource_controller.rb
let s:cpo_save=&cpo
set cpo&vim
nmap <buffer> gf <Plug>RailsTabFind
nmap <buffer> f <Plug>RailsSplitFind
nnoremap <buffer> <silent> g} :exe        "ptjump =RubyCursorIdentifier()"
nnoremap <buffer> <silent> } :exe          "ptag =RubyCursorIdentifier()"
nnoremap <buffer> <silent> g] :exe      "stselect =RubyCursorIdentifier()"
nnoremap <buffer> <silent> g :exe        "stjump =RubyCursorIdentifier()"
nnoremap <buffer> <silent>  :exe v:count1."stag =RubyCursorIdentifier()"
nnoremap <buffer> <silent> ] :exe v:count1."stag =RubyCursorIdentifier()"
nnoremap <buffer> <silent>  :exe  v:count1."tag =RubyCursorIdentifier()"
nmap <buffer> gf <Plug>RailsFind
nnoremap <buffer> <silent> g] :exe       "tselect =RubyCursorIdentifier()"
nnoremap <buffer> <silent> g :exe         "tjump =RubyCursorIdentifier()"
let &cpo=s:cpo_save
unlet s:cpo_save
setlocal autoindent
setlocal nobinary
setlocal bufhidden=
setlocal buflisted
setlocal buftype=
setlocal nocindent
setlocal cinkeys=0{,0},0),:,0#,!^F,o,O,e
setlocal cinoptions=
setlocal cinwords=if,else,while,do,for,switch
setlocal colorcolumn=
setlocal comments=:#
setlocal commentstring=#\ %s
setlocal complete=.,w,b,u,t,i
setlocal completefunc=syntaxcomplete#Complete
setlocal copyindent
setlocal cryptmethod=
setlocal nocursorbind
setlocal nocursorcolumn
set cursorline
setlocal cursorline
setlocal define=^\\s*def\\s\\+\\(self\\.\\)\\=
setlocal dictionary=
setlocal nodiff
setlocal equalprg=
setlocal errorformat=
setlocal expandtab
if &filetype != 'ruby'
setlocal filetype=ruby
endif
setlocal foldcolumn=0
setlocal foldenable
setlocal foldexpr=0
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldmarker={{{,}}}
setlocal foldmethod=manual
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal foldtext=foldtext()
setlocal formatexpr=
setlocal formatoptions=ncroql
setlocal formatlistpat=^\\s*\\d\\+[\\]:.)}\\t\ ]\\s*
setlocal grepprg=
setlocal iminsert=0
setlocal imsearch=0
setlocal include=^\\s*\\<\\(load\\>\\|require\\>\\|autoload\\s*:\\=[\"']\\=\\h\\w*[\"']\\=,\\)
setlocal includeexpr=RailsIncludeexpr()
setlocal indentexpr=GetRubyIndent(v:lnum)
setlocal indentkeys=0{,0},0),0],!^F,o,O,e,=end,=else,=elsif,=when,=ensure,=rescue,==begin,==end
setlocal noinfercase
setlocal iskeyword=@,48-57,_,192-255,$
setlocal keywordprg=ri
setlocal nolinebreak
setlocal nolisp
set list
setlocal list
setlocal makeprg=
setlocal matchpairs=(:),{:},[:]
setlocal modeline
setlocal modifiable
setlocal nrformats=octal,hex
set number
setlocal number
setlocal numberwidth=4
setlocal omnifunc=
setlocal path=~/workspace/ngin,~/workspace/ngin/app,~/workspace/ngin/app/models,~/workspace/ngin/app/controllers,~/workspace/ngin/app/helpers,~/workspace/ngin/config,~/workspace/ngin/lib,~/workspace/ngin/app/views,~/workspace/ngin/app/views/api2/active_resource_api_resource,~/workspace/ngin/public,~/workspace/ngin/test,~/workspace/ngin/test/unit,~/workspace/ngin/test/functional,~/workspace/ngin/test/integration,~/workspace/ngin/app/*,~/workspace/ngin/vendor,~/workspace/ngin/vendor/plugins/*/lib,~/workspace/ngin/vendor/plugins/*/test,~/workspace/ngin/vendor/rails/*/lib,~/workspace/ngin/vendor/rails/*/test,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/site_ruby/1.8,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/site_ruby/1.8/i686-darwin11.2.0,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/site_ruby,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/vendor_ruby/1.8,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/vendor_ruby/1.8/i686-darwin11.2.0,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/vendor_ruby,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/1.8,~/.rvm/rubies/re
setlocal nopreserveindent
setlocal nopreviewwindow
setlocal quoteescape=\\
setlocal noreadonly
setlocal norelativenumber
setlocal noscrollbind
setlocal shiftwidth=2
setlocal noshortname
setlocal nosmartindent
setlocal softtabstop=2
setlocal nospell
setlocal spellcapcheck=/Users/jonphenow/.vim.spellfile.utf-8.add
setlocal spellfile=~/.vim.spellfile.utf-8.add
setlocal spelllang=en
setlocal statusline=
setlocal suffixesadd=.rb,.rhtml,.erb,.rxml,.builder,.rjs,.mab,.liquid,.haml,.dryml,.mn,.slim
setlocal noswapfile
setlocal synmaxcol=3000
if &syntax != 'ruby'
setlocal syntax=ruby
endif
setlocal tabstop=4
setlocal tags=~/workspace/ngin/tmp/tags,~/workspace/ngin/.git/ruby.tags,~/workspace/ngin/.git/tags,./tags/all,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/site_ruby/1.8/tags,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/site_ruby/1.8/i686-darwin11.2.0/tags,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/site_ruby/tags,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/vendor_ruby/1.8/tags,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/vendor_ruby/1.8/i686-darwin11.2.0/tags,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/vendor_ruby/tags,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/1.8/tags,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/1.8/i686-darwin11.2.0/tags,./tags,~/workspace/ngin/tags
setlocal textwidth=0
setlocal thesaurus=
setlocal noundofile
setlocal nowinfixheight
setlocal nowinfixwidth
setlocal wrap
setlocal wrapmargin=0
silent! normal! zE
let s:l = 21 - ((20 * winheight(0) + 30) / 61)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
21
normal! 044l
wincmd w
argglobal
edit app/controllers/api2/play_actions_controller.rb
let s:cpo_save=&cpo
set cpo&vim
nmap <buffer> gf <Plug>RailsTabFind
nmap <buffer> f <Plug>RailsSplitFind
nnoremap <buffer> <silent> g} :exe        "ptjump =RubyCursorIdentifier()"
nnoremap <buffer> <silent> } :exe          "ptag =RubyCursorIdentifier()"
nnoremap <buffer> <silent> g] :exe      "stselect =RubyCursorIdentifier()"
nnoremap <buffer> <silent> g :exe        "stjump =RubyCursorIdentifier()"
nnoremap <buffer> <silent>  :exe v:count1."stag =RubyCursorIdentifier()"
nnoremap <buffer> <silent> ] :exe v:count1."stag =RubyCursorIdentifier()"
nnoremap <buffer> <silent>  :exe  v:count1."tag =RubyCursorIdentifier()"
nmap <buffer> gf <Plug>RailsFind
nnoremap <buffer> <silent> g] :exe       "tselect =RubyCursorIdentifier()"
nnoremap <buffer> <silent> g :exe         "tjump =RubyCursorIdentifier()"
let &cpo=s:cpo_save
unlet s:cpo_save
setlocal autoindent
setlocal nobinary
setlocal bufhidden=
setlocal buflisted
setlocal buftype=
setlocal nocindent
setlocal cinkeys=0{,0},0),:,0#,!^F,o,O,e
setlocal cinoptions=
setlocal cinwords=if,else,while,do,for,switch
setlocal colorcolumn=
setlocal comments=:#
setlocal commentstring=#\ %s
setlocal complete=.,w,b,u,t,i
setlocal completefunc=syntaxcomplete#Complete
setlocal copyindent
setlocal cryptmethod=
setlocal nocursorbind
setlocal nocursorcolumn
set cursorline
setlocal cursorline
setlocal define=^\\s*def\\s\\+\\(self\\.\\)\\=
setlocal dictionary=
setlocal nodiff
setlocal equalprg=
setlocal errorformat=
setlocal expandtab
if &filetype != 'ruby'
setlocal filetype=ruby
endif
setlocal foldcolumn=0
setlocal foldenable
setlocal foldexpr=0
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldmarker={{{,}}}
setlocal foldmethod=manual
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal foldtext=foldtext()
setlocal formatexpr=
setlocal formatoptions=ncroql
setlocal formatlistpat=^\\s*\\d\\+[\\]:.)}\\t\ ]\\s*
setlocal grepprg=
setlocal iminsert=0
setlocal imsearch=0
setlocal include=^\\s*\\<\\(load\\>\\|require\\>\\|autoload\\s*:\\=[\"']\\=\\h\\w*[\"']\\=,\\)
setlocal includeexpr=RailsIncludeexpr()
setlocal indentexpr=GetRubyIndent(v:lnum)
setlocal indentkeys=0{,0},0),0],!^F,o,O,e,=end,=else,=elsif,=when,=ensure,=rescue,==begin,==end
setlocal noinfercase
setlocal iskeyword=@,48-57,_,192-255,$
setlocal keywordprg=ri
setlocal nolinebreak
setlocal nolisp
set list
setlocal list
setlocal makeprg=
setlocal matchpairs=(:),{:},[:]
setlocal modeline
setlocal modifiable
setlocal nrformats=octal,hex
set number
setlocal number
setlocal numberwidth=4
setlocal omnifunc=
setlocal path=~/workspace/ngin,~/workspace/ngin/app,~/workspace/ngin/app/models,~/workspace/ngin/app/controllers,~/workspace/ngin/app/helpers,~/workspace/ngin/config,~/workspace/ngin/lib,~/workspace/ngin/app/views,~/workspace/ngin/app/views/api2/play_actions,~/workspace/ngin/public,~/workspace/ngin/test,~/workspace/ngin/test/unit,~/workspace/ngin/test/functional,~/workspace/ngin/test/integration,~/workspace/ngin/app/*,~/workspace/ngin/vendor,~/workspace/ngin/vendor/plugins/*/lib,~/workspace/ngin/vendor/plugins/*/test,~/workspace/ngin/vendor/rails/*/lib,~/workspace/ngin/vendor/rails/*/test,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/site_ruby/1.8,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/site_ruby/1.8/i686-darwin11.2.0,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/site_ruby,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/vendor_ruby/1.8,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/vendor_ruby/1.8/i686-darwin11.2.0,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/vendor_ruby,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/1.8,~/.rvm/rubies/ree-1.8.7-2011.12/
setlocal nopreserveindent
setlocal nopreviewwindow
setlocal quoteescape=\\
setlocal noreadonly
setlocal norelativenumber
setlocal noscrollbind
setlocal shiftwidth=2
setlocal noshortname
setlocal nosmartindent
setlocal softtabstop=2
setlocal nospell
setlocal spellcapcheck=/Users/jonphenow/.vim.spellfile.utf-8.add
setlocal spellfile=~/.vim.spellfile.utf-8.add
setlocal spelllang=en
setlocal statusline=
setlocal suffixesadd=.rb,.rhtml,.erb,.rxml,.builder,.rjs,.mab,.liquid,.haml,.dryml,.mn,.slim
setlocal noswapfile
setlocal synmaxcol=3000
if &syntax != 'ruby'
setlocal syntax=ruby
endif
setlocal tabstop=4
setlocal tags=~/workspace/ngin/tmp/tags,~/workspace/ngin/.git/ruby.tags,~/workspace/ngin/.git/tags,./tags/all,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/site_ruby/1.8/tags,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/site_ruby/1.8/i686-darwin11.2.0/tags,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/site_ruby/tags,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/vendor_ruby/1.8/tags,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/vendor_ruby/1.8/i686-darwin11.2.0/tags,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/vendor_ruby/tags,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/1.8/tags,~/.rvm/rubies/ree-1.8.7-2011.12/lib/ruby/1.8/i686-darwin11.2.0/tags,./tags,~/workspace/ngin/tags
setlocal textwidth=0
setlocal thesaurus=
setlocal noundofile
setlocal nowinfixheight
setlocal nowinfixwidth
setlocal wrap
setlocal wrapmargin=0
silent! normal! zE
let s:l = 22 - ((0 * winheight(0) + 0) / 0)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
22
normal! 03l
wincmd w
3wincmd w
exe '1resize ' . ((&lines * 0 + 33) / 67)
exe '2resize ' . ((&lines * 0 + 33) / 67)
exe '3resize ' . ((&lines * 61 + 33) / 67)
exe '4resize ' . ((&lines * 0 + 33) / 67)
tabnext 1
if exists('s:wipebuf')
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20 shortmess=filtIoOA
let s:sx = expand("<sfile>:p:r")."x.vim"
if file_readable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &so = s:so_save | let &siso = s:siso_save
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
