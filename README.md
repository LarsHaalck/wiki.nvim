# WIP: wiki.nvim

A very minimal wiki plugin for Neovim relying on [vim-markdown](https://github.com/plasticboy/vim-markdown), [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) and [plenary.nvim](https://github.com/nvim-lua/plenary.nvim).

Features
=============================

* Binding to open `index.md`
* Telescope pickers for `md` files in a globally set wiki dir:
    * file search
    * titles (using `yaml`-block)
    * keywords (using `yaml`-block)
    * outgoing `md` links
    * string grep 
* simple pandoc export for single or all files to html
* open `html` file for `md` that is currently open

Setup
=============================

## Requirements

* [vim-markdown](https://github.com/plasticboy/vim-markdown)
* [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) 
* [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
* [ripgrep](https://github.com/BurntSushi/ripgrep)
* [pandoc](https://pandoc.org/) (for optional html export)

## Installation

Using [vim-plug](https://github.com/junegunn/vim-plug):

```viml
" Install plenary
Plug 'nvim-lua/plenary.nvim'

" Install markdown plugin
Plug 'plasticboy/vim-markdown'

" Install this plugin
Plug 'LarsHaalck/wiki.nvim'
```

## Configuration

**Default Config**:

```lua
require('wiki').setup {
    wiki_dir = '~/.notes',
    export_dir = '~/.notes/export',
    pandoc_args = {
        '--mathjax',
        '--standalone',
    }
}
```

### Replacing md with html in links

Just copy the pandoc lua-filter file `md-to-html.lua` somewhere and add a line to pandoc args:

```lua
require('wiki').setup {
    -- ...
    pandoc_args = {
        -- ...
        '--lua-filter=<PATH_TO_DIR>/md-to-html.lua',
        -- ...
    }
}
```

### Replacing relative image links with absolute

Just copy the pandoc lua-filter file `img-src-translate.lua` somewhere and add a line to pandoc args:

```lua
require('wiki').setup {
    -- ...
    pandoc_args = {
        -- ...
        '--lua-filter=<PATH_TO_DIR>/img-src-translate.lua',
        -- ...
    }
}
```


## Keymappings

**Example:**

```viml
nnoremap <silent> <leader>ww <cmd>lua require('wiki').open_index()<CR>
nnoremap <silent> <leader>wf <cmd>lua require('telescope').extensions.wiki.files()<CR>
nnoremap <silent> <leader>wt <cmd>lua require('telescope').extensions.wiki.titles()<CR>
nnoremap <silent> <leader>wk <cmd>lua require('telescope').extensions.wiki.keywords()<CR>
nnoremap <silent> <leader>wo <cmd>lua require('telescope').extensions.wiki.outgoing()<CR>
command! WikiExportAll lua require('wiki').export_all()<CR>
command! WikiExport lua require('wiki').export()<CR>

```
