---@module 'commando'

local placeholders = require("commando.placeholders")
local state = require("commando.state")
local terminal = require("commando.terminal")
local tmux = require("commando.tmux")
local user_commands = require("commando.user_commands")
local list = require("commando.list")

---@class Commando
---@field list HarpoonList
local Commando = {}

Commando.Target = {
    Auto = "auto",
    Vimux = "vimux",
    Terminal = "terminal-split",
    TerminalSplit = "terminal-split",
    TerminalFloating = "terminal-floating",
}

local config = {
    target = Commando.Target.Auto, -- default target
    enable_lists = true, -- default: true if Harpoon is available
    list = list.create_default(Commando), -- optional: override the list with a custom harpoon:list
    list_toggle_options = {
        title = "Commando",
        title_pos = "center",
        border = "double",
    },
}

function Commando.setup(opts)
    config = vim.tbl_deep_extend("force", config, opts or {})
end

function Commando.toggle_quick_menu()
    if not config.list then
        vim.notify("Commando: Harpoon not found", vim.log.levels.WARN)
        return nil
    end

    local harpoon = require("harpoon")
    harpoon.ui:toggle_quick_menu(config.list, config.list_toggle_options)
end

function Commando.exit() terminal.exit() end

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

Commando.list = config.list
user_commands.create(Commando)

return Commando
