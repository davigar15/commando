local M = {}

local terminal = {
    buf = nil,
    win = nil,
    job_id = nil,
    type = nil, -- "split" or "floating"
}

local function ensure_terminal(style)
    if
        terminal.buf
        and vim.api.nvim_buf_is_valid(terminal.buf)
        and terminal.win
        and vim.api.nvim_win_is_valid(terminal.win)
    then
        return
    end

    -- Create window first (split or floating)
    if style == "floating" then
        terminal.buf = vim.api.nvim_create_buf(false, true)

        local width = math.floor(vim.o.columns * 0.8)
        local height = math.floor(vim.o.lines * 0.6)
        local row = math.floor((vim.o.lines - height) / 2)
        local col = math.floor((vim.o.columns - width) / 2)

        terminal.win = vim.api.nvim_open_win(terminal.buf, true, {
            relative = "editor",
            width = width,
            height = height,
            row = row,
            col = col,
            style = "minimal",
            border = "rounded",
        })
        -- Setup keymaps to close (hide) floating window without killing terminal
        local opts = {
            noremap = true,
            silent = true,
            nowait = true,
            buffer = terminal.buf,
        }
        vim.keymap.set("n", "q", function()
            if terminal.win and vim.api.nvim_win_is_valid(terminal.win) then
                vim.api.nvim_win_close(terminal.win, false) -- false = hide, no kill
                terminal.win = nil -- Clear the window handle, but keep buf and job
            end
        end, opts)

        vim.keymap.set("n", "<ESC>", function()
            if terminal.win and vim.api.nvim_win_is_valid(terminal.win) then
                vim.api.nvim_win_close(terminal.win, false)
                terminal.win = nil
            end
        end, opts)
    else
        vim.cmd("botright split")
        vim.cmd("resize 15")
        terminal.buf = vim.api.nvim_create_buf(false, true)
        terminal.win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(terminal.win, terminal.buf)
    end

    terminal.job_id = vim.fn.termopen(os.getenv("SHELL") or "bash", {
        on_exit = function()
            terminal.job_id = nil
            terminal.win = nil
            terminal.buf = nil
        end,
    })

    terminal.type = style
    if style == "split" then
        vim.cmd("wincmd p")
    end
end

M.run = function(cmd, style)
    ensure_terminal(style)

    if terminal.job_id then
        vim.api.nvim_chan_send(terminal.job_id, cmd .. "\n")
        vim.api.nvim_win_call(terminal.win, function() vim.cmd("normal! G") end)
    else
        vim.notify("Terminal not running", vim.log.levels.ERROR)
    end
end

M.exit = function()
    if
        terminal.job_id
        and terminal.win
        and vim.api.nvim_win_is_valid(terminal.win)
    then
        vim.api.nvim_chan_send(terminal.job_id, "exit\n")
        vim.api.nvim_win_close(terminal.win, true)
    else
        vim.notify("No terminal open", vim.log.levels.WARNING)
    end
end

return M
