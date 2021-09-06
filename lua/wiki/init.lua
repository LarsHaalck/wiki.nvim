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
    vim.cmd("edit " .. tostring((wiki_dir / "index.md")))
end

local function get_wiki_files(wiki_dir)
    local files = {}
    Job:new({
        command = "fd",
        args = { "--type", "f", "--extension", "md" },
        cwd = tostring(wiki_dir),
        on_stdout = function(_, data)
            table.insert(files, data)
        end,
    }):sync()
    return files
end

local function get_yaml_title(file, wiki_dir)
    -- match everything in yaml block and replace with capture group
    -- rg --multiline --multiline-dotall "\-\-\-.*title:([^\n]*).*(\-\-\-|\.\.\.)" -o -r '$1' file
    local title = ""
    Job:new({
        command = "rg",
        args = {
            '--multiline',
            '--multiline-dotall',
            "\\-\\-\\-.*title: ([^\\n]*).*(\\-\\-\\-|\\.\\.\\.)",
            '-o',
            '-r',
            '$1',
            file
        },
        cwd = tostring(wiki_dir),
        on_stdout = function(_, data)
            title = data
        end,
    }):sync()
    return title:gsub("%s+", "")
end

local function get_first_section(file, wiki_dir)
    -- rg -m 1 "^(#)+" -r "" file
    local title = ""
    Job:new({
        command = "rg",
        args = { '-m', '1', '^(#)+', '-r', '', file },
        cwd = tostring(wiki_dir),
        on_stdout = function(_, data)
            title = data
        end,
    }):sync()
    return title:gsub("%s+", "")
end

M.get_titles = function(opts)
    opts = opts or config.options
    local wiki_dir = Path:new(Path:new(opts.wiki_dir):expand());

    -- get all md files
    local files = get_wiki_files(wiki_dir)
    local titles = {}
    for _, file in pairs(files) do
        local title = get_yaml_title(file, wiki_dir)
        if title:len() == 0 then
            title = get_first_section(file, wiki_dir)
        end
        if title:len() > 0 then
            table.insert(titles, {file = file, title = title})
        end
    end
    log.info(titles)
end

return M
