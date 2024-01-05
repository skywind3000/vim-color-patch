" vim: set ts=4 sw=4 tw=78 noet :"
"======================================================================
"
" cpatch.vim - load colorscheme patch automatically
"
" Created by skywind on 2024/01/05
" Last Modified: 2024/01/05 14:48:57
"
" Homepage: https://github.com/skywind3000/vim-color-patch
"
" USAGE:
" 
" This script will load colorscheme patch when current color changed
" 
"   let g:cpatch_path = '~/.vim/cpatch'
"
" After setting "g:cpatch_path", if you change the current color:
"   
"   :color {NAME}
"
" This script will try to load the following scripts in order:
"
"   1) "~/.vim/cpatch/__init__.vim"
"   2) "~/.vim/cpatch/{NAME}.vim"
"
" The first script "__init__.vim" in the "g:cpatch_path" folder will 
" be loaded for every colorscheme
"
"======================================================================


"----------------------------------------------------------------------
" configuration
"----------------------------------------------------------------------

" color patch path: script will be searched here
let g:cpatch_path = get(g:, 'cpatch_path', '~/.vim/cpatch')

" color patch subdirectory in every runtime path
let g:cpatch_name = get(g:, 'cpatch_name', '')

" runtime bang
let g:cpatch_bang = get(g:, 'cpatch_bang', 0)


"----------------------------------------------------------------------
" load script
"----------------------------------------------------------------------
function! s:load_patch(name, force)
	let names = ['__init__.vim', a:name .. '.vim']
	let paths = []
	let s:previous_color = get(s:, 'previous_color', '')
	if a:force == 0
		if a:name == s:previous_color
			return 1
		endif
	endif
	let s:previous_color = a:name
	if type(g:cpatch_path) == type('')
		let paths = split(g:cpatch_path, ',')
	elseif type(g:cpatch_path) == type([])
		let paths = g:cpatch_path
	endif
	for name in names
		let rtpname = g:cpatch_name .. '/' .. name
		if g:cpatch_name != ''
			let bang = (g:cpatch_bang == 0)? '' : '!'
			try
				exec printf('runtime%s %s', bang, fnameescape(rtpname))
			catch
				let msg = v:throwpoint
				let p1 = stridx(msg, '_load_patch[')
				if p1 > 0
					let p2 = stridx(msg, ']..', p1)
					if p2 > 0
						let msg = strpart(msg, p2 + 3)
					endif
				endif
				redraw
				echohl ErrorMsg
				echom 'Error detected in ' . msg
				echom v:exception
				echohl None
			endtry
		endif
		for p in paths
			if p == ''
				continue
			endif
			let p = expand(p)
			if isdirectory(p)
				if p !~ '\v[\/\\]$'
					let p = p .. '/'
				endif
				let p = tr(p, '\', '/')
				let t = p .. name
				if filereadable(t)
					try
						exec 'source ' .. fnameescape(t)
					catch
						let msg = v:throwpoint
						let p1 = stridx(msg, '_load_patch[')
						if p1 > 0
							let p2 = stridx(msg, ']..', p1)
							if p2 > 0
								let msg = strpart(msg, p2 + 3)
							endif
						endif
						redraw
						echohl ErrorMsg
						echom 'Error detected in ' . msg
						echom v:exception
						echohl None
					endtry
				endif
			endif
		endfor
	endfor
	return 0
endfunc


"----------------------------------------------------------------------
" load script
"----------------------------------------------------------------------
let g:colors_name = get(g:, 'colors_name', '')
call s:load_patch(g:colors_name, 0)


"----------------------------------------------------------------------
" autocmd
"----------------------------------------------------------------------
augroup CPatchEventGroup
	au!
	au VimEnter * call s:load_patch(g:colors_name, 0)
	au ColorScheme * call s:load_patch(expand('<amatch>'), 1)
augroup END



