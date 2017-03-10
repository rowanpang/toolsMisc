" File:        tabline.vim
" Maintainer:  Matthew Kitt <http://mkitt.net/>
" Description: Configure tabs within Terminal Vim.
" Last Change: 2012-10-21
" License:     This program is free software. It comes without any warranty,
"              to the extent permitted by applicable law. You can redistribute
"              it and/or modify it under the terms of the Do What The Fuck You
"              Want To Public License, Version 2, as published by Sam Hocevar.
"              See http://sam.zoy.org/wtfpl/COPYING for more details.
" Based On:    http://www.offensivethinking.org/data/dotfiles/vimrc

" Bail quickly if the plugin was loaded, disabled or compatible is set
if (exists("g:loaded_tabline_vim") && g:loaded_tabline_vim) || &cp
  finish
endif
let g:loaded_tabline_vim = 1

function! Tabline()
  let s = ''
  for i in range(tabpagenr('$'))
    let tab = i + 1
	let winnrs = tabpagewinnr(tab,'$')
    let winnr = tabpagewinnr(tab)
    let buflist = tabpagebuflist(tab)
    let bufnr = buflist[winnr - 1]
    let bufname = bufname(bufnr)
    let bufmodified = getbufvar(bufnr, "&mod")

	let bufnamedis = ''
	if bufname != ''
		let index = 0
		let delimiter = "/"
		let partlen = 1
		let indextmp = stridx(bufname,delimiter,index)
		while indextmp != -1
			let bufnamedis .= strpart(bufname,index,partlen)
			let bufnamedis .= delimiter
			let index = indextmp + strlen(delimiter)
			let indextmp = stridx(bufname,delimiter,index)
		endwhile

		let bufnamedis .= fnamemodify(bufname,':p:t')
	else
		let bufnamedis = 'No Name'
	endif

    let s .= '%' . tab . 'T'
    let s .= (tab == tabpagenr() ? '%#TabLineSel#' : '%#TabLine#')
    let s .= ' ' . tab . (winnrs > 1 ? ',' . winnrs :'') . ':'
    "let s .= (bufname != '' ? '['. fnamemodify(bufname, ':p:.') . '] ' : '[No Name] ')
	let s.= bufnamedis

    if bufmodified
      let s .= '[+] '
    endif
  endfor

  let s .= '%#TabLineFill#'
  return s
endfunction
set tabline=%!Tabline()

