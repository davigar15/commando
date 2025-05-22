---@module 'commando'
local harpoon = require("harpoon")
local utils = require("commando.utils")
local state = require("commando.state")

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
    cmd = cmd:gsub("{test_file}", utils.get_test_file() or "")
    cmd = cmd:gsub("{test_nearest}", utils.get_nearest_test() or "")
    return cmd
end

-- Register custom Harpoon configuration for "commando"
harpoon:setup({
    commando = {
        ---@param list_item HarpoonListItem
        ---@param list unknown
        ---@param options unknown
        select = function(list_item, list, options)
            local cmd = replace_placeholders(list_item.value)
            state.set_last_command(cmd)
            run_in_tmux(cmd)
        end,
    },
})

---@type HarpoonList
Commando.commando_list = harpoon:list("commando")

--- Show Harpoon UI for Commando list
function Commando.show()
    harpoon.ui:toggle_quick_menu(Commando.commando_list, {
        title = "Commando",
        title_pos = "center",
        border = "double",
    })
end

-- Alias run to select on the list
Commando.run = function(index) Commando.commando_list:select(index) end
Commando.run_latest = function()
    local latest_command = state.get_last_command()
    if latest_command then
        run_in_tmux(latest_command)
    end
end

return Commando
