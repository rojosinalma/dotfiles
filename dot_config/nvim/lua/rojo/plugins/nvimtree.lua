return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    require("nvim-tree").setup({
      git = {
        ignore = false,
      },

      view = {
        width = 35,
        side = left,
        adaptive_size = false,
      },

      update_focused_file = {
        enable = true,         -- Always show/focus the current file in the tree
        update_cwd = true,     -- Optional: updates cwd to match file's directory
      },
    })
  end,
}
