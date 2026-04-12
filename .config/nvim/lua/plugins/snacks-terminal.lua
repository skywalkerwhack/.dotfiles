if true then
  return {
    "folke/snacks.nvim",
    opts = {
      terminal = {
        shell = "fish",
        -- This defines the window properties for the terminal
        win = {
          style = "float", -- Ensure it is a floating window
          width = 0.8, -- 80% of screen width
          height = 0.8, -- 80% of screen height
          border = "rounded", -- Optional: adds a nice rounded border
        },
      },
    },
    keys = {
      -- Map Alt+i to toggle the floating terminal
      {
        "<M-i>",
        function()
          Snacks.terminal.toggle()
        end,
        desc = "Toggle Terminal",
      },
      -- Map Alt+i in terminal mode so you can close it with the same key
      {
        "<M-i>",
        function()
          Snacks.terminal.toggle()
        end,
        mode = "t",
        desc = "Toggle Terminal",
      },
    },
  }
end
