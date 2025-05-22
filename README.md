# commando.nvim

A Neovim plugin to manage and run custom commands via [Harpoon](https://github.com/ThePrimeagen/harpoon) and [Vimux](https://github.com/preservim/vimux) integration.

Allows you to store and quickly execute templated commands in tmux, with support for placeholders to customize command execution based on your current context.

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
      vim.keymap.set("n", "<leader>xm", commando.show)

      -- Run commands by index
      vim.keymap.set("n", "<leader>xh", function() commando.run(1) end)
      vim.keymap.set("n", "<leader>xj", function() commando.run(2) end)
      vim.keymap.set("n", "<leader>xk", function() commando.run(3) end)
      vim.keymap.set("n", "<leader>xl", function() commando.run(4) end)
      vim.keymap.set("n", "<leader>x;", function() commando.run(5) end)
    end,
  },
}
```

---

## Usage

- Press `<leader>xm` to toggle the Commando command list (powered by Harpoon UI).
- Select or run a command from the list to execute it inside your tmux runner via Vimux.
- Commands can contain placeholders to dynamically adapt to your current file or cursor position.

---

## Executing Tests

Currently, commando has built-in support for Python test execution placeholders. These help you run test commands targeting the current file or the nearest test function/class above your cursor.

### Supported placeholders for tests:

| Placeholder    | Description                                                   |
|----------------|---------------------------------------------------------------|
| `{test_file}`  | Expands to the full path of the current file                  |
| `{test_nearest}` | Expands to the current file plus the nearest Python test function or test class above the cursor |

### How {test_nearest} works
Searches upward from the cursor to find the closest Python test function (def test_*) above.

Searches further upward to find an enclosing class definition (class *) if any.

Returns a string combining file path, optional class, and test function separated by ::, which works with test runners like pytest.

### Example command
pytest --maxfail=1 --disable-warnings {test_nearest}

If your cursor is inside:

```python
class TestMyFeature:
    def test_behavior(self):
        ...
```

The expanded command run by commando will be:

```sh
pytest --maxfail=1 --disable-warnings path/to/file.py::TestMyFeature::test_behavior
```

---

## Requirements

- [vimux](https://github.com/preservim/vimux) — to run commands inside tmux
- [harpoon](https://github.com/ThePrimeagen/harpoon) — to manage and select commands interactively

---

## License

MIT License

---

Contributions and issues are welcome!
