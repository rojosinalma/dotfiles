return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = "nvim-tree/nvim-web-devicons",
  config = function()
    local function smart_bdelete(bufnr)
      bufnr = bufnr or vim.api.nvim_get_current_buf()
      -- Only act if buffer exists and isn't unloaded
      if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_get_option(bufnr, "modifiable") then
        if vim.bo[bufnr].modified then
          -- Prompt user to save or discard changes
          local choice = vim.fn.confirm("Save changes before closing?", "&Yes\n&No\n&Cancel", 1)
          if choice == 1 then
            vim.api.nvim_buf_call(bufnr, function() vim.cmd("write") end)
            vim.cmd("Bdelete " .. bufnr)
          elseif choice == 2 then
            vim.cmd("Bdelete! " .. bufnr)
          end
          -- If Cancel, do nothing
        else
          vim.cmd("Bdelete " .. bufnr)
        end
      else
        vim.cmd("Bdelete! " .. bufnr)
      end
    end

    require("bufferline").setup{
      options = {
        indicator = { style = 'none' },
        offsets = {
          {
            filetype = "NvimTree",
            text = "Tree",
            separator = false,
            text_align = 'left',
          }
        },
        mode = 'buffers',
        close_command = smart_bdelete,
        middle_mouse_command = smart_bdelete,
        color_icons = true,
        show_buffer_icons = false,
        show_buffer_close_icons = false,
        show_close_icon = false,
      }
    }
  end
}

