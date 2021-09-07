# wiki.nvim

A very minimal wiki-Plugin for Neovim using relying on [vim-markdown](https://github.com/plasticboy/vim-markdown) and [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim).

Features
=============================

* Binding to open `index.md`
* Telescope pickers for: all `md` files, titles & keywords (using yaml-block), outgoing links
* simple pandoc export for single or all files to html

Setup
=============================

## Installation

Using [vim-plug](https://github.com/junegunn/vim-plug):

```viml
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
