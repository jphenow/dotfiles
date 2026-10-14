-- The pinned LazyVim uses the old nvim-treesitter API (`nvim-treesitter.configs`),
-- which only exists on `master`. Upstream's default branch is now `main`, and
-- lazy.nvim ignores lockfile commits whose branch differs, so a fresh install
-- would get `main` and fail. Drop this when upgrading LazyVim past v13.
return {
  { "nvim-treesitter/nvim-treesitter", branch = "master" },
  { "nvim-treesitter/nvim-treesitter-textobjects", branch = "master" },
}
