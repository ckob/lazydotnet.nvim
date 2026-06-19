# lazydotnet.nvim

A Neovim plugin that seamlessly integrates the [lazydotnet](https://github.com/ckob/lazydotnet) terminal UI for .NET development directly into a floating window.

## ✨ Features

- **Seamless Integration**: Run `lazydotnet` inside a floating Neovim terminal.
- **Toggleable UI**: Easily hide and restore the UI without losing your state using a single keybind.
- **Editor Bridge**: Open files and jump to specific lines directly from the `lazydotnet` UI right into your Neovim session.
- **Smart Window Management**: Gracefully handles terminal buffer cleanup when the process exits.

## ⚡️ Requirements

- **Neovim** >= 0.8.0
- **[lazydotnet](https://github.com/ckob/lazydotnet)** CLI tool installed and available in your `$PATH`.

## 📦 Installation

Install using your preferred package manager. Here is an example using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
return {
  "ckob/lazydotnet.nvim",
  cmd = "LazyDotnet",
  init = function()
    -- Toggle the UI in both normal and terminal modes
    vim.keymap.set({ "n", "t" }, "<C-.>", "<Cmd>LazyDotnet<CR>", { desc = "Toggle LazyDotnet" })
  end,
  opts = {
    -- Optional: Configure if your lazydotnet executable is not in your PATH
    -- cmd = { "path/to/lazydotnet" },
  },
}
```

## 🚀 Usage

You can launch or toggle the UI by calling the command:

```vim
:LazyDotnet
```

Or by pressing the key combination you defined in your configuration (e.g., `<C-.>`).

- **If the TUI is closed**: It will open in a new floating window.
- **If the TUI is open**: It will be hidden, keeping the process running in the background.
- **If the TUI is hidden**: It will restore the window exactly where you left off.
- **Quitting the TUI**: Pressing the application's quit key (usually `q`) inside the TUI will terminate the background process and clean up the buffer.

## ⚙️ Configuration

`lazydotnet.nvim` comes with the following default configuration:

```lua
---@type LazyDotnetConfig
require("lazydotnet").setup({
  -- The command to run lazydotnet.
  -- You can pass arguments here as well, e.g., { "lazydotnet", "--project", "my-project.csproj" }
  cmd = { "lazydotnet" },

  -- Floating window configuration
  window = {
    width_ratio = 0.9,       -- Width relative to the editor width (0.0 to 1.0)
    height_ratio = 0.9,      -- Height relative to the editor height (0.0 to 1.0)
    border = "rounded",      -- "none" | "single" | "double" | "rounded" | "solid" | "shadow"
  },
})
```

## 🤝 Contributing

Pull requests and issues are welcome! Feel free to open an issue to discuss any changes or features you'd like to see.

## 📝 License

[MIT](./LICENSE)
