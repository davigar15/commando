local utils = require("commando.utils")

return {
    replace = function(cmd)
        cmd = cmd:gsub("{test_file}", utils.get_test_file() or "")
        cmd = cmd:gsub("{test_nearest}", utils.get_nearest_test() or "")
        return cmd
    end,
}
