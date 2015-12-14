syntax on                   " �Զ��﷨����
set number                  " ��ʾ�к�
set cursorline              " ͻ����ʾ��ǰ��
set shiftwidth=4            " �趨 << �� >> �����ƶ�ʱ�Ŀ��Ϊ 4
set softtabstop=4           " ʹ�ð��˸��ʱ����һ��ɾ�� 4 ���ո�
set tabstop=4               " �趨 tab ����Ϊ 4
set nobackup                " �����ļ�ʱ������
set autoindent				" or cindent

set ignorecase smartcase    " ����ʱ���Դ�Сд��������һ�������ϴ�д��ĸʱ�Ա��ֶԴ�Сд����
set nowrapscan              " ��ֹ���������ļ�����ʱ��������
set incsearch               " ������������ʱ����ʾ�������
set hlsearch                " ����ʱ������ʾ���ҵ����ı�
set smartindent             " ��������ʱʹ�������Զ�����
set hidden                  " ��������δ������޸�ʱ�л�����������ʱ���޸��� vim ���𱣴�

set cmdheight=1             " �趨�����е�����Ϊ 1

set foldenable              " ��ʼ�۵�
set foldmethod=syntax       " �����﷨�۵�
set foldcolumn=0            " �����۵�����Ŀ��
setlocal foldlevel=1        " �����۵�����Ϊ
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
