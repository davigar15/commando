local M = { last_command = nil }

function M.set_last_command(cmd) M.last_command = cmd end
function M.get_last_command() return M.last_command end

return M
