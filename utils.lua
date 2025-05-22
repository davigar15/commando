---@module 'commando.utils'
local CommandoUtils = {}

--- Get the current file path
---@return string
function CommandoUtils.get_test_file() return vim.fn.expand("%") end

--- Get the nearest test function or class-based test above the current line
--- Format: "filename::ClassName::test_name" or "filename::test_name"
---@return string
function CommandoUtils.get_nearest_test()
    local file = vim.fn.expand("%")
    local current_line = vim.fn.line(".")
    local nearest_test ---@type string|nil
    local nearest_class ---@type string|nil

    -- Search upwards for the nearest test function
    for i = current_line, 1, -1 do
        local line = vim.fn.getline(i)
        local test_name = line:match("^%s*def%s+(test[%w_]+)%s*%(")
        if test_name then
            nearest_test = test_name
            break
        end
    end

    if not nearest_test then
        return file
    end

    -- Now search upwards for the class definition
    for i = current_line, 1, -1 do
        local line = vim.fn.getline(i)
        local class_name = line:match("^%s*class%s+([%w_]+)")
        if class_name then
            nearest_class = class_name
            break
        end
    end

    if nearest_class then
        return file .. "::" .. nearest_class .. "::" .. nearest_test
    else
        return file .. "::" .. nearest_test
    end
end

return CommandoUtils
