# Preface

This plugin will load corresponding patch script located in the given directory when current colorscheme changed.

## Get started

Install this plugin with your plugin manager (without lazy loading):

```VimL
Plug 'skywind3000/vim-color-patch'
```

Setup the patch search path:

```VimL
let g:cpatch_path = '~/.vim/cpatch'
```

And script with the same name will be loaded in this locations after `:color xxx` command.


## Examples

#### Change line number color for the desert colorscheme

create a new file named `desert.vim` in the `~/.vim/cpatch` folder:

```viml
highlight! LineNr term=bold cterm=NONE ctermfg=DarkGrey ctermbg=NONE 
	\ gui=NONE guifg=#585858 guibg=NONE
```

and this script will be loaded after executing:

```VimL
:color desert
```

#### Remove all italic for Windows

edit `~/.vim/cpatch/__init__.vim` :

```VimL
if has('win32') || has('win64')
    call cpatch#disable_italic()
endif
```

The `__init__.vim` is a public script and it will be sourced for every colorscheme.

`vim-color-patch` provides some help functions like `disable_italic()` for style tuning.

#### Remove background colors for listchars for monokai

edit `~/.vim/cpatch/monokai.vim`:

```VimL
call cpatch#remove_background('SpecialKey')
```

#### Change VertSplit style for gruvbox

edit `~/.vim/cpatch/gruvbox.vim`:

```VimL
hi! VertSplit term=reverse ctermfg=239 ctermbg=233 guifg=#64645e guibg=#211F1C
```


## Help functions

This plugin provides some help functions for highlight manipulation:

#### Remove style in all highlight groups:

```VimL
function cpatch#remove_style(what)
```

argument `what` can be one of: 

    ['underline', 'undercurl', 'reverse', 'inverse', 'italic', 'bold', 'standout']
  
#### Disable italics:

```VimL
function cpatch#disable_italic()
```

same as `call cpatch#remove_style("italic")` .

#### Disable bolds:
 
```VimL
function cpatch#disable_bold()
```

same as `call cpatch#remove_style("bold")` .

#### Remove background for a highlight group:

```VimL
function cpatch#remove_background(group)
```

eg. remove background in the SignColumn:

```VimL
call cpatch#remove_background('SignColumn')
```

## Credit

TODO
