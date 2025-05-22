---@module 'commando'
local harpoon = require("harpoon")
local CommandoUtils = require("commando.utils")

---@class Commando
local Commando = {}

---@alias HarpoonListItem { value: string, context: { row: integer } }

--- Run a command in tmux via Vimux
---@param cmd string
local function run_in_tmux(cmd)
    vim.cmd("VimuxOpenRunner")
    vim.cmd("VimuxRunCommand('clear; echo -e \"" .. cmd .. '"; ' .. cmd .. "')")
end

--- Replace custom placeholders in a command string
---@param cmd string
---@return string
local function replace_placeholders(cmd)
    cmd = cmd:gsub("{test_file}", CommandoUtils.get_test_file())
    cmd = cmd:gsub("{test_nearest}", CommandoUtils.get_nearest_test())
    return cmd
end

-- Register custom Harpoon configuration for "commando"
harpoon:setup({
    commando = {
        ---@param list_item HarpoonListItem
        ---@param list unknown
        ---@param options unknown
        select = function(list_item, list, options)
            Commando.run(list_item.context.row)
        end,
    },
})

--- @type HarpoonList
Commando.commando_list = harpoon:list("commando")

--- Show Harpoon UI for Commando list
function Commando.show()
    harpoon.ui:toggle_quick_menu(Commando.commando_list, {
        title = "Commando",
        title_pos = "center",
        border = "double",
    })
end

--- Run command from Harpoon list by index
---@param index integer
function Commando.run(index)
    local item = Commando.commando_list:get(index)
    if item and item.value then
        local cmd = replace_placeholders(item.value)
        run_in_tmux(cmd)
    else
        vim.notify("No command found at index " .. index, vim.log.levels.WARN)
    end
end

return Commando
