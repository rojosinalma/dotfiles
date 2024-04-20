return {
  "alexghergh/nvim-tmux-navigation",
  config = function ()
    local nvim_tmux_nav = require('nvim-tmux-navigation')

    nvim_tmux_nav.setup {
        disable_when_zoomed = true -- defaults to false
    }
    
    -- match to whatever bindings are in .tmux.conf
    vim.keymap.set('n', "<A-left>", nvim_tmux_nav.NvimTmuxNavigateLeft)
    vim.keymap.set('n', "<A-down>", nvim_tmux_nav.NvimTmuxNavigateDown)
    vim.keymap.set('n', "<A-up>", nvim_tmux_nav.NvimTmuxNavigateUp)
    vim.keymap.set('n', "<A-right>", nvim_tmux_nav.NvimTmuxNavigateRight)
    --vim.keymap.set('n', "<A-\\>", nvim_tmux_nav.NvimTmuxNavigateLastActive)
    --vim.keymap.set('n', "<A-apace>", nvim_tmux_nav.NvimTmuxNavigateNext)
  end
}
