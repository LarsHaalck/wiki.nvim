local wiki = require('wiki')
local config = require('wiki.config')
local log = require('wiki.log')

local pickers = require('telescope.pickers')
local actions = require('telescope.actions')
local finders = require('telescope.finders')
local sorters = require('telescope.sorters')
local make_entry = require('telescope.make_entry')
local conf = require('telescope.config').values
local Path = require('plenary.path')
local action_state = require "telescope.actions.state"

local M = {}

local insert_relative_link
do
    local type_mapping = {
        grep = "(.*):%d:%d:.*",
        file = "(.*)"
    }

    local modes = {
        link = {},
        insert = {}
    }

    insert_relative_link = function(type, mode, prompt_bufnr)
        if not type_mapping[type] then return end
        if not modes[mode] then return end

        local file = action_state.get_selected_entry().value:match(type_mapping[type])
        actions.close(prompt_bufnr)
        link = wiki.get_relative_link(nil, file)

        if mode == "link" then
            wiki.create_link(link)
        else
            vim.api.nvim_put({ link }, "", true, true)
        end
    end
end

local insert_relative_link_factory = function(type, mode)
    return function(nr) insert_relative_link(type, mode, nr) end
end

M.files = function(telescope_opts, opts)
    opts = opts or config.options
    telescope_opts = telescope_opts or {}
    require('telescope.builtin').find_files({
        find_command = { 'fd', '--type', 'f', '--extension', 'md' },
        prompt_title = 'Wiki-Files',
        cwd = tostring(opts.wiki_dir),
        attach_mappings = function(_, map)
            map('i', '<C-L>', insert_relative_link_factory("file", "link"))
            map('i', '<C-K>', insert_relative_link_factory("file", "insert"))
            return true
        end,
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
        attach_mappings = function(_, map)
            map('i', '<C-L>', insert_relative_link_factory("grep", "link"))
            map('i', '<C-K>', insert_relative_link_factory("grep", "insert"))
            return true
        end,
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
        attach_mappings = function(_, map)
            map('i', '<C-L>', insert_relative_link_factory("grep", "link"))
            map('i', '<C-K>', insert_relative_link_factory("grep", "insert"))
            return true
        end,
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
    telescope_opts.cwd = opts.wiki_dir
    telescope_opts.file_ignore_patterns = { "export" }

    -- add export_dir to ignore patterns if export_dir is underneath wiki_dir
    local rel_export = Path:new(opts.export_dir):make_relative(opts.wiki_dir)
    if rel_export ~= opts.export_dir then
        telescope_opts.file_ignore_patterns = { rel_export }
    end

    require('telescope.builtin').live_grep(telescope_opts)

end

M.browser = function(telescope_opts, opts)
    telescope_opts = telescope_opts or {}
    opts = opts or config.options
    telescope_opts.cwd = opts.wiki_dir
    require('telescope.builtin').file_browser(telescope_opts)
end

return M
