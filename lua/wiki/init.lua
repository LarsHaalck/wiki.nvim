local config = require('wiki.config')
local Path = require('plenary.path')
local Job = require('plenary.job')
local log = require('wiki.log')
local finders = require('telescope.finders')
local flatten = vim.tbl_flatten

local M = {}

M.setup = function(opts) config.setup(opts) end

M.open_index = function(opts)
    local opts = opts or config.options
    local wiki_dir = Path:new(Path:new(opts.wiki_dir):expand())
    wiki_dir:mkdir { parents = true, exists_ok = true }
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
    local opts = opts or config.options
    local wiki_dir = Path:new(Path:new(opts.wiki_dir):expand())

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
    local opts = opts or config.options
    local wiki_dir = Path:new(Path:new(opts.wiki_dir):expand())

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

M.get_outgoing = function(opts)
    local opts = opts or config.options
    local outs = {}
    Job:new({
        command = 'rg',
        args = {
            '--color=never',
            '--no-heading',
            '--no-filename',
            '--no-line-number',
            '--no-column',
            '\\[.*\\]\\((.*.md)\\)',
            '--only-matching',
            '--replace',
            '$1',
            vim.fn.expand("%")
        },
        cwd = opts.wiki_dir,
        on_stdout = function(_, data)
            table.insert(outs, data)
        end,
    }):sync()
    return outs
end

local function export_pandoc(in_file, pandoc_args, export_dir, wiki_dir)
    -- get file without extension
    local out_file = export_dir / (in_file:match('(.+)%..+$') .. '.html')
    out_file:parent():mkdir { parents = true, exists_ok = true }

    local err = {}
    Job:new({
        command = 'pandoc',
        args = flatten {
            in_file,
            pandoc_args,
            '-o',
            tostring(out_file)
        },
        on_stderr = function(_, data)
            err = {
                filename = tostring(wiki_dir / in_file),
                lnum = 1, text = data
            }
        end,
        cwd = tostring(wiki_dir)
    }):sync()

    return err
end

M.export_all = function(opts)
    local opts = opts or config.options
    local wiki_dir = Path:new(Path:new(opts.wiki_dir):expand())
    local export_dir = Path:new(Path:new(opts.export_dir):expand())
    export_dir:mkdir { parents = true, exists_ok = true }
    local files = get_wiki_files(wiki_dir)

    local qflist = {}
    for _, file in pairs(files) do
        local err = export_pandoc(file, opts.pandoc_args, export_dir, wiki_dir)
        if next(err) then
            table.insert(qflist, err)
        end
    end

    vim.cmd [[echo "Done..."]]
    if next(qflist) then
        vim.fn.setqflist(qflist, 'r')
        vim.cmd [[copen]]
    end
end

M.export = function(opts)
    local opts = opts or config.options
    local wiki_dir = Path:new(Path:new(opts.wiki_dir):expand())
    local export_dir = Path:new(Path:new(opts.export_dir):expand())
    export_dir:mkdir { parents = true, exists_ok = true }
    local file = vim.fn.expand("%")
    file = file:gsub(tostring(wiki_dir / ""), "")

    local err = export_pandoc(file, opts.pandoc_args, export_dir, wiki_dir)
    vim.cmd [[echo "Done..."]]
    if next(err) then
        vim.fn.setloclist(0, { err }, 'r')
        vim.cmd [[lopen]]
    end
end

return M
