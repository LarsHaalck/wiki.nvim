local telescope = require('telescope')
local wiki_telescope = require('wiki.telescope')

return telescope.register_extension { exports = {
        files = wiki_telescope.files,
        titles = wiki_telescope.titles,
        keywords = wiki_telescope.keywords,
    }
}
