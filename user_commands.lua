return {
    create = function(Commando)
        vim.api.nvim_create_user_command(
            "CommandoRun",
            function(opts) Commando.run(opts.args) end,
            { nargs = "*", desc = "Run a predefined Commando command" }
        )

        vim.api.nvim_create_user_command(
            "CommandoRunLatest",
            Commando.run_latest,
            { nargs = "*", desc = "Run latest executedcommand" }
        )
        vim.api.nvim_create_user_command(
            "CommandoToggleQuickMenu",
            Commando.toggle_quick_menu,
            { nargs = "*", desc = "Toggle quick menu to show the list" }
        )
        vim.api.nvim_create_user_command(
            "CommandoExit",
            Commando.exit,
            { nargs = "*", desc = "Exit terminal" }
        )
    end,
}
