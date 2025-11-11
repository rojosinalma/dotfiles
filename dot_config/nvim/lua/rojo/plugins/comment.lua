return {
  'numToStr/Comment.nvim',
  lazy = false,

  config = function ()
    require("Comment").setup({
      padding = false,
      sticky = true,
    })

    -- Add Alt+/ keybinding for commenting
    local api = require('Comment.api')

    -- Normal mode: comment current line
    vim.keymap.set('n', '<A-/>', api.toggle.linewise.current, { desc = 'Toggle comment on current line' })

    -- Visual mode: comment selected block
    local esc = vim.api.nvim_replace_termcodes('<ESC>', true, false, true)
    vim.keymap.set('x', '<A-/>', function()
      vim.api.nvim_feedkeys(esc, 'nx', false)
      api.toggle.linewise(vim.fn.visualmode())
    end, { desc = 'Toggle comment on visual selection' })
  end
}

