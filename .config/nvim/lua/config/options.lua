-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Yank to system clipboard, used very often.
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], {
  desc = "Yank to system clipboard",
})

-- Paste without overwriting yank register
vim.keymap.set("x", "<leader>p", [["_dP]], {
  desc = "Paste without clobbering clipboard",
})

-- Delete without yanking
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], {
  desc = "Delete without yank",
})
