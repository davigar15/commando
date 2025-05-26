local M = {}

-- @param commando Commando
function M.create_default(commando)
    local harpoon_available, _ = pcall(require, "harpoon")
    if harpoon_available then
        local harpoon = require("harpoon")
        harpoon:setup({
            commando = {
                select = function(list_item, _, _)
                    commando.run(list_item.value)
                end,
            },
        })
        return harpoon:list("commando")
    end
end

return M
