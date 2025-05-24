---@module 'commando'

local placeholders = require("commando.placeholders")
local state = require("commando.state")
local terminal = require("commando.terminal")
local tmux = require("commando.tmux")

---@class Commando
local Commando = {}

Commando.Target = {
    Auto = "auto",
    Vimux = "vimux",
    Terminal = "terminal-split",
    TerminalSplit = "terminal-split",
    TerminalFloating = "terminal-floating",
    -- Add more if needed
}
local config = {
    target = Commando.Target.Auto, -- default target
    enable_lists = true, -- default: true if Harpoon is available
    list = nil, -- optional: override the list with a custom harpoon:list
    list_toggle_options = {
        title = "Commando",
        title_pos = "center",
        border = "double",
    },
}

local harpoon_available, err = pcall(require, "harpoon")
if harpoon_available then
    local harpoon = require("harpoon") -- Register custom Harpoon configuration for "commando"
    harpoon:setup({
        commando = {
            ---@param list_item HarpoonListItem
            ---@param list unknown
            ---@param options unknown
            select = function(list_item, list, options)
                Commando.run(list_item.value)
            end,
        },
    })
    config.list = harpoon:list("commando")
end

local run_in_target = function(cmd)
    if config.target == Commando.Target.Vimux then
        tmux.run(cmd)
    elseif config.target == Commando.Target.Terminal then
        terminal.run(cmd, "split")
    elseif config.target == Commando.Target.Floating then
        terminal.run(cmd, "floating")
    elseif config.target == Commando.Target.Auto then
        local tmux_available = tmux.check()
        if tmux_available then
            tmux.run(cmd)
        else
            terminal.run(cmd, "split")
        end
    end

    function Commando.setup(opts)
        config = vim.tbl_deep_extend("force", config, opts or {})
    end
end

Commando.run = function(cmd)
    local command = placeholders.replace(cmd)
    state.set_last_command(command)
    run_in_target(command)
end

Commando.run_latest = function()
    local command = state.get_last_command()
    if command then
        run_in_target(command)
    else
        vim.notify("No latest command found", vim.log.levels.WARNING)
    end
end

Commando.toggle_quick_menu = function()
    if not config.list then
        vim.notify("Commando: Harpoon not found", vim.log.levels.WARN)
        return nil
    end

    local harpoon = require("harpoon")
    harpoon.ui:toggle_quick_menu(config.list, config.list_toggle_options)
end

Commando.exit = function() terminal.exit() end
Commando.list = config.list

vim.api.nvim_create_user_command(
    "CommandoRun",
    function(opts) Commando.run(opts.args) end,
    {
        nargs = "*",
        desc = "Run a predefined Commando command",
    }
)

vim.api.nvim_create_user_command(
    "CommandoRunLatest",
    function() Commando.run_latest() end,
    {
        nargs = "*",
        desc = "Run latest executedcommand",
    }
)
vim.api.nvim_create_user_command(
    "CommandoToggleQuickMenu",
    function() Commando.toggle_quick_menu() end,
    {
        nargs = "*",
        desc = "Toggle quick menu to show the list",
    }
)
vim.api.nvim_create_user_command(
    "CommandoExit",
    function() Commando.exit() end,
    {
        nargs = "*",
        desc = "Exit terminal",
    }
)
return Commando
