-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Muscle memory carried over from the old vim/init.vim.
-- Not ported: `w!!` (sudo tee can't prompt for a password in neovim),
-- <leader>ev/sv (lazy.nvim can't re-source the config), pastetoggle (removed
-- in neovim 0.10; bracketed paste handles it). j/k already move by display line.
local map = vim.keymap.set

map("n", ";", ":", { desc = "Command line" }) -- flash's ; repeat is turned off in plugins/flash.lua
map("i", "jj", "<Esc>", { desc = "Exit insert" })
map("i", "kk", "<Esc>", { desc = "Exit insert" })
map("n", "Q", "gqap", { desc = "Format paragraph" })
map("v", "Q", "gq", { desc = "Format selection" })

-- RenameFile: was <leader>q, which is LazyVim's quit group. Snacks also tells
-- the LSP about the rename; <leader>cR does the same when the LSP supports it.
vim.api.nvim_create_user_command("RenameFile", function()
  Snacks.rename.rename_file()
end, { desc = "Rename current file" })

-- PromoteToLet: turns `foo = bar` on the current line into rspec's `let(:foo) { bar }`.
vim.api.nvim_create_user_command("PromoteToLet", function()
  vim.cmd([[s/\(\w\+\) = \(.*\)$/let(:\1) { \2 }/]])
  vim.cmd("normal! ==")
end, { desc = "Promote assignment to rspec let" })
map("n", "<leader>p", "<cmd>PromoteToLet<cr>", { desc = "Promote to let (rspec)" })
