return {
  'numToStr/Comment.nvim',
  lazy = false,

  config = function ()
    require("Comment").setup({
      padding = false,
      sticky = true,
    })
  end
}

