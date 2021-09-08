local config = require('wiki.config')

local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local sorters = require('telescope.sorters')
local previewers = require('telescope.previewers')
local make_entry = require('telescope.make_entry')
local entry_display = require('telescope.pickers.entry_display')
local conf = require('telescope.config').values

local wiki = require('wiki')
local log = require('wiki.log')

local M = {}

M.files = function(telescope_opts, opts)
    opts = opts or config.options
    telescope_opts = telescope_opts or {}
    require('telescope.builtin').find_files({
        find_command = { 'fd', '--type', 'f', '--extension', 'md' },
        prompt_title = 'Wiki-Files',
        cwd = tostring(opts.wiki_dir),
    })
end

M.titles = function(telescope_opts, opts)
    telescope_opts = telescope_opts or {}
    opts = opts or config.options
    telescope_opts.cwd = tostring(opts.wiki_dir)

    pickers.new(telescope_opts, {
        prompt_title = 'Titles',
        finder = finders.new_table{
            results = wiki.get_titles(opts),
            entry_maker = make_entry.gen_from_vimgrep(telescope_opts),
        },
        previewer = conf.grep_previewer(telescope_opts),
        sorter = conf.generic_sorter(telescope_opts),
    }):find()
end

M.keywords = function(telescope_opts, opts)
    telescope_opts = telescope_opts or {}
    opts = opts or config.options
    telescope_opts.cwd = tostring(opts.wiki_dir)

    pickers.new(telescope_opts, {
        prompt_title = 'Keywords',
        finder = finders.new_table{
            results = wiki.get_keywords(opts),
            entry_maker = make_entry.gen_from_vimgrep(telescope_opts),
        },
        previewer = conf.grep_previewer(telescope_opts),
        sorter = conf.generic_sorter(telescope_opts),
    }):find()
end

M.outgoing = function(telescope_opts, opts)
    telescope_opts = telescope_opts or {}
    opts = opts or config.options
    telescope_opts.cwd = tostring(opts.wiki_dir)

    pickers.new(telescope_opts, {
        prompt_title = 'Keywords',
        finder = finders.new_table{
            results = wiki.get_outgoing(opts),
            entry_maker = make_entry.gen_from_file(telescope_opts),
        },
        previewer = conf.file_previewer(telescope_opts),
        sorter = conf.file_sorter(telescope_opts),
    }):find()
end

M.live_grep = function(telescope_opts, opts)
    telescope_opts = telescope_opts or {}
    opts = opts or config.options
    telescope_opts.cwd = tostring(opts.wiki_dir)

    require('telescope.builtin').live_grep(telescope_opts)

end

return M
