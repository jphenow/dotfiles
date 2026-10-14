-- `;` is mapped to `:` (see config/keymaps.lua), so drop it from flash's f/t
-- repeat keys. Pressing f/t again (or `,` backwards) still repeats.
return {
  "folke/flash.nvim",
  opts = function(_, opts)
    opts.modes = opts.modes or {}
    opts.modes.char = opts.modes.char or {}
    opts.modes.char.keys = { "f", "F", "t", "T", "," }
  end,
}
