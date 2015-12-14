syntax on                   " 自动语法高亮
set number                  " 显示行号
set cursorline              " 突出显示当前行
set shiftwidth=4            " 设定 << 和 >> 命令移动时的宽度为 4
set softtabstop=4           " 使得按退格键时可以一次删掉 4 个空格
set tabstop=4               " 设定 tab 长度为 4
set nobackup                " 覆盖文件时不备份
set autoindent				" or cindent

set ignorecase smartcase    " 搜索时忽略大小写，但在有一个或以上大写字母时仍保持对大小写敏感
set nowrapscan              " 禁止在搜索到文件两端时重新搜索
set incsearch               " 输入搜索内容时就显示搜索结果
set hlsearch                " 搜索时高亮显示被找到的文本
set smartindent             " 开启新行时使用智能自动缩进
set hidden                  " 允许在有未保存的修改时切换缓冲区，此时的修改由 vim 负责保存

set cmdheight=1             " 设定命令行的行数为 1

set foldenable              " 开始折叠
set foldmethod=syntax       " 设置语法折叠
set foldcolumn=0            " 设置折叠区域的宽度
setlocal foldlevel=1        " 设置折叠层数为
							"
set encoding=utf-8
set fencs=utf-8,gbk

set laststatus=2
"set statusline=\ %<%F[%n%M%R%H]%=\ %y\ %(%{&fileformat}\ %{&encoding}\ %c:%l/%L%)
set statusline=\ %<%F[b:%n%M%R%H]%=\ \ %(%c:%l/%L%)

"map
"map <silent> [map] [cmd]: will not show cmd in window,exp:
"map <silent> <leader>1 :diffget 1<CR> :diffupdate<CR>
let mapleader = ","

"vimdiff
if &diff
	map <leader>1 :diffget 1<CR> :diffupdate<CR>
	map <leader>2 :diffget 2<CR> :diffupdate<CR>
	map <leader>3 :diffget 3<CR> :diffupdate<CR>
	map <leader>4 :diffget 4<CR> :diffupdate<CR>
endif

"taglist
nnoremap <F8> :TlistToggle<CR>
let Tlist_Auto_Highlight_Tag = 1
let Tlist_Auto_Open = 0
let Tlist_Exit_OnlyWindow = 1
let Tlist_GainFocus_On_ToggleOpen = 1
let Tlist_File_Fold_Auto_Close = 1

"nerdtree
set rtp+=~/.vim/nerdtree
nnoremap <F9> :NERDTreeToggle<CR>
let NERDTreeWinPos = "right"
