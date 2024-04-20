return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("lualine").setup({
      options = {
        theme = "dracula",
      },

      disabled_filetypes = {
        'NVimTree',
        'Lazy',
      },

      sections = {
        lualine_a = {
          'mode',
          'windows',
          'tabs',
        },
      },
    })
  end
}
