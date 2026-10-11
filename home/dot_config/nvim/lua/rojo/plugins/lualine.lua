return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local lazy_status = require("lazy.status")

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

        lualine_x = {
          {
            lazy_status.updates,
            cond = lazy_status.has_updates,
          },
          { "encoding" },
          { "fileformat" },
          { "filetype" },
        }
      },
    })
  end
}
