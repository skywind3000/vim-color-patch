" vim: set ts=4 sw=4 tw=78 noet :"
"======================================================================
"
" cpatch.vim - load colorscheme patch automatically
"
" Created by skywind on 2024/01/05
" Last Modified: 2024/01/07 20:33
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
"   2) "~/.vim/cpatch/__init__.lua"
"   3) "~/.vim/cpatch/{NAME}.vim"
"   4) "~/.vim/cpatch/{NAME}.lua"
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

" color patch edit path: for CPatchEdit
let g:cpatch_edit = get(g:, 'cpatch_edit', '~/.vim/cpatch')

" split mode
let g:cpatch_split = get(g:, 'cpatch_split', 'auto')

" don't load .lua files
let g:cpatch_disable_lua = get(g:, 'cpatch_disable_lua', 0)


"----------------------------------------------------------------------
" display error
"----------------------------------------------------------------------
function! s:traceback() abort
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
endfunc


"----------------------------------------------------------------------
" load script
"----------------------------------------------------------------------
function! s:load_patch(name, force)
	let names = ['__init__', a:name]
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
		let rtpname = g:cpatch_name .. '/' .. name .. '.vim'
		if g:cpatch_name != ''
			let bang = (g:cpatch_bang == 0)? '' : '!'
			try
				exec printf('runtime%s %s', bang, fnameescape(rtpname))
			catch
				call s:traceback()
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
				for extname in ['.vim', '.lua']
					let t = p .. name .. extname
					if extname == '.vim'
						let cmd = 'source ' .. fnameescape(t)
					else
						let cmd = 'luafile ' .. fnameescape(t)
						if g:cpatch_disable_lua
							continue
						endif
					endif
					if filereadable(t)
						try
							exec cmd
						catch
							call s:traceback()
						endtry
					endif
				endfor
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



"----------------------------------------------------------------------
" edit patch
"----------------------------------------------------------------------
function! s:CPatchEdit(mods, name) abort
	let name = a:name
	if name == ''
		let name = get(g:, 'colors_name', '')
	endif
	if name == ''
		let name = '__init__'
	endif
	let home = fnamemodify(g:cpatch_edit, ':p')
	if !isdirectory(home)
		try
			call mkdir(home, 'p')
		catch
			echohl ErrorMsg
			echo v:exception
			echohl None
			return 3
		endtry
	endif
	let home = (home =~ '\v[\/\\]$')? home : (home .. '/')
	let home = tr(home, '\', '/')
	let path = printf("%s%s", home, name)
	if name !~ '\v\.vim$' && name !~ '\v\.lua$'
		let path = path .. '.vim'
	endif
	let name = fnameescape(path)
	let mods = g:cpatch_split
	let newfile = (filereadable(path) == 0)? 1 : 0
	if a:mods != ''
		if a:mods != 'auto'
			exec a:mods . ' split ' . name
		elseif winwidth(0) >= 160
			exec 'vert split ' . name
		else
			exec 'split ' . name
		endif
	elseif mods == ''
		exec 'split ' . name
	elseif mods == 'auto'
		if winwidth(0) >= 160
			exec 'vert split ' . name
		else
			exec 'split ' . name
		endif
	elseif mods == 'tab'
		exec 'tabe ' . name
	else
		exec mods . ' split ' . name
	endif
	if newfile
		let content = []
		let n = fnamemodify(name, ':t:r')
		let u = 'https://github.com/skywind3000/vim-color-patch'
		if name =~ '\.vim$'
			let content += [printf('" edit patch for %s', n)]
			let content += ['" ' .. u]
		elseif name =~ '\.lua$'
			let content += [printf('-- edit patch for %s', n)]
			let content += ['-- ' .. u]
		endif
		if len(content) > 0 && line('$') == 1
			call append(0, content)
			exec 'set nomodified'
		endif
	endif
	return 0
endfunc


"----------------------------------------------------------------------
" completion
"----------------------------------------------------------------------
function! s:complete(ArgLead, CmdLine, CursorPos)
	let candidate = []
	let result = []
	let items = {}
	let home = fnamemodify(g:cpatch_edit, ':p')
	if home !~ '\v[\/\\]$'
		let home = home .. '/'
	endif
	let part = glob(home .. '*', 1)
	for n in split(part, "\n")
		if n =~ '\.vim$'
			let t = fnamemodify(n, ':t:r')
			let items[t] = 1
		elseif n =~ '\.lua$'
			let t = fnamemodify(n, ':t')
			let items[t] = 1
		endif
	endfor
	let cname = get(g:, 'colors_name', '')
	if cname != ''
		let items[cname] = 1
	endif
	let items['__init__'] = 1
	let names = keys(items)
	call sort(names)
	let hidden = (a:ArgLead =~ '^_')? 1 : 0
	if a:ArgLead == ''
		for name in names
			if name !~ '^__'
				let candidate += [name]
			endif
		endfor
	else
		for name in names
			if stridx(name, a:ArgLead) == 0
				let candidate += [name]
			endif
		endfor
	endif
	return candidate
endfunc


"----------------------------------------------------------------------
" command definition
"----------------------------------------------------------------------
command! -nargs=? -range=0 -complete=customlist,s:complete
			\ CPatchEdit call s:CPatchEdit('<mods>', <q-args>)



