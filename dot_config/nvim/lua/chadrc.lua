local M = {}

M.ui = {
  vim.o.cursorlineopt =='number,line',

  theme = "chadracula-evondev",
  telescope = { style = "bordered" },

  hl_override = {
    CursorLine = {
      bg = "#313244",
    },
  },

  statusline = {
    theme = "minimal",
    separator_style = "round"
  },

  tabufline = {
    enabled = true,
    lazyload = true,
  },

  nvdash = {
    load_on_startup = true,
  }

}

return M
