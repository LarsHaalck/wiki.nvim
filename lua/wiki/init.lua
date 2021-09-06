local config = require('wiki.config')
local Path = require('plenary.path')
local Job = require('plenary.job')
local log = require('wiki.log')
local finders = require('telescope.finders')

local M = {}

M.setup = function(opts) config.setup(opts) end

M.open_index = function(opts)
    opts = opts or config.options
    local wiki_dir = Path:new(Path:new(opts.wiki_dir):expand());
    wiki_dir:mkdir({ parents = true });
    vim.cmd('edit ' .. tostring((wiki_dir / 'index.md')))
end

local function get_wiki_files(wiki_dir)
    local files = {}
    Job:new({
        command = 'fd',
        args = { '--type', 'f', '--extension', 'md' },
        cwd = tostring(wiki_dir),
        on_stdout = function(_, data)
            table.insert(files, data)
        end,
    }):sync()
    return files
end

local function trim(str)
    return str:match( "^%s*(.-)%s*$" )
end

local function get_yaml_field(field, file, wiki_dir)
    -- match firs occurence of field in yaml block and replace with
    -- capture group
    local res = ''
    Job:new({
        command = 'rg',
        args = {
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--max-count',
            '1',
            field .. ': (.*)',
            '--only-matching',
            '--replace',
            '$1',
            file
        },
        cwd = tostring(wiki_dir),
        on_stdout = function(_, data)
            res = data
        end,
    }):sync()
    return trim(res)
end

local function get_yaml_title(file, wiki_dir)
    return get_yaml_field('title', file, wiki_dir)
end

local function get_yaml_keywords(file, wiki_dir)
    return get_yaml_field('keywords', file, wiki_dir)
end

local function get_first_section(file, wiki_dir)
    local title = ''
    Job:new({
        command = 'rg',
        args = {
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--max-count',
            '1',
            '^(#)+',
            '--only-matching',
            '--replace',
            '',
            file
        },
        cwd = tostring(wiki_dir),
        on_stdout = function(_, data)
            title = data
        end,
    }):sync()
    return title:gsub('%s+', '')
end

M.get_titles = function(opts)
    opts = opts or config.options
    local wiki_dir = Path:new(Path:new(opts.wiki_dir):expand());

    local files = get_wiki_files(wiki_dir)
    local titles = {}
    for _, file in pairs(files) do
        -- check for yaml title
        local title = get_yaml_title(file, wiki_dir)
        -- fallback to first section heading
        if title:len() == 0 then
            title = get_first_section(file, wiki_dir)
        end
        if title:len() > 0 then
            table.insert(titles, title)
        end
    end
    return titles
end

M.get_keywords = function(opts)
    opts = opts or config.options
    local wiki_dir = Path:new(Path:new(opts.wiki_dir):expand());

    local files = get_wiki_files(wiki_dir)
    local keywords = {}
    for _, file in pairs(files) do
        local local_keywords = get_yaml_keywords(file, wiki_dir)
        if local_keywords:len() > 0 then
            table.insert(keywords, local_keywords)
        end
    end
    return keywords
end

return M
