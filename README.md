# commando.nvim

A Neovim plugin to manage and run custom commands via [Harpoon](https://github.com/ThePrimeagen/harpoon) and [Vimux](https://github.com/preservim/vimux) integration.

Allows you to store and quickly execute templated commands in tmux, with support for placeholders like the current test file or nearest test.

---

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
return {
  {
    "davigar15/commando",
    dependencies = {
      "preservim/vimux",
      { "ThePrimeagen/harpoon", branch = "harpoon2" },
    },
    config = function()
      local commando = require("commando")

      -- Show commando list
      vim.keymap.set("n", "<leader>cm", commando.show)

      -- Run commands by index
      vim.keymap.set("n", "<leader>ch", function() commando.run(1) end)
      vim.keymap.set("n", "<leader>cj", function() commando.run(2) end)
      vim.keymap.set("n", "<leader>ck", function() commando.run(3) end)
      vim.keymap.set("n", "<leader>cl", function() commando.run(4) end)
      vim.keymap.set("n", "<leader>c;", function() commando.run(5) end)
    end,
  },
}
