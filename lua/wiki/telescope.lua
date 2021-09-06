local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local sorters = require("telescope.sorters")
local previewers = require("telescope.previewers")
local make_entry = require("telescope.make_entry")
local entry_display = require('telescope.pickers.entry_display')

local log = require('wiki.log')

local M = {}

M.files = function(telescope_opts, opts)
    telescope_opts = telescope_opts or {}
    require("telescope.builtin").find_files({
        find_command = { "fd", "--type", "f", "--extension", "md" },
        prompt_title = "Wiki-Files",
        cwd = "$HOME/.notes/",
    })
end

M.open_index = function()
    vim.cmd("edit ~/.notes/index.md")
end

M.titles = function(telescope_opts, opts)
    telescope_opts = telescope_opts or {}

    pickers.new(telescope_opts, {
        prompt_title = 'Titles',
        finder = finders.new_table {
            results = {
                { file = "work/journal.md", title = "journal", },
                { file = "work/bla.md", title = "blub", },
                { file = "derp/jkjskdf.md", title = "hi", },
            },
            entry_maker = function(entry)
                local displayer = entry_display.create {
                    separator = " ",
                    items = {
                        { width = 20 },
                        { remaining = true },
                    },
                }
                local function make_display(ent)
                    return displayer {
                        ent.value.file,
                        ent.value.title,
                    }
                end

                return {
                    value = entry,
                    display = make_display,
                    ordinal = string.format('%s', entry.title)

                }
            end
        },
        sorter = sorters.get_generic_fuzzy_sorter(),
    }):find()
end

return M
