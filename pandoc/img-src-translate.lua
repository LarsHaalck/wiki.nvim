local system = require 'pandoc.system'

function Image(elem)
    local src = elem.src

    -- if src is absolute, keep it as is
    if src:sub(1, 1) == "/" then
        return elem
    end

    -- if src is relative concat it with input directory
    local input_dir = PANDOC_STATE.input_files[1]:match(".*/")

    -- if input_dir is not absolute, prepend cwd
    if input_dir:sub(1, 1) ~= "/" then
        input_dir = system.get_working_directory() .. "/" .. input_dir
    end

    elem.src = input_dir .. src
    return elem
end
