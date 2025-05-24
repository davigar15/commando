local function in_tmux() return vim.env.TMUX ~= nil and vim.env.TMUX ~= "" end
return {
    run = function(cmd)
        local ok, err = pcall(vim.cmd, "VimuxOpenRunner")
        if ok then
            vim.cmd("VimuxRunCommand('" .. cmd .. "')")
        else
            vim.notify(
                "Failed to run VimuxOpenRunner: " .. err,
                vim.log.levels.ERROR
            )
        end
    end,
    check = function()
        if not in_tmux() then
            return false
        end

        local ok, err = pcall(vim.cmd, "VimuxOpenRunner")
        if not ok then
            return false
        end

        return true
    end,
}
