-- stylua: ignore

-- return {
--   "ayu-theme/ayu-vim",
--   lazy = false,
--   priority = 1000,
--   config = function()
--     vim.g.ayucolor = "dark" -- or "light" or "mirage"
--     vim.cmd("colorscheme ayu")
--   end,
-- }

return {
  "Shatur/neovim-ayu",
  lazy = false,
  priority = 1000,
  config = function()
    require("ayu").setup({
      mirage = true,
      overrides = {
        Normal = { bg = "None" },
        NormalFloat = { bg = "None" },
        ColorColumn = { bg = "None" },
        SignColumn = { bg = "None" },
        Folded = { bg = "None" },
        FoldColumn = { bg = "None" },
        CursorLine = { bg = "None" },
        CursorColumn = { bg = "None" },
        VertSplit = { bg = "None" },
      },
    })
    vim.cmd("colorscheme ayu")
  end,
}
