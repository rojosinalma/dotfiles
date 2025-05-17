-- nc j]]leader
vim.g.mapleader = " "

-- quick cmds
vim.keymap.set("n", "<leader>ee", vim.cmd.Ex, { desc = "Open nvim explorer"}) -- open nvim explorer
vim.keymap.set("n", "<leader>ll", vim.cmd.Lazy, { desc = "Open Lazy"} ) -- open Lazy
vim.keymap.set("n", "<leader>so", vim.cmd.so, { desc = "Reload current file"} ) -- source current file
vim.keymap.set("n", "<A-s>", vim.cmd.write) -- save
vim.keymap.set("n", "<C-c>", "<Esc>") -- escape

-- windows & splits 
-- NOTE: The rest of the bindings are taken care of in nvim-tmux-navigator
vim.keymap.set("n", "<A-d>", vim.cmd.vnew)
vim.keymap.set("n", "<A-v>", vim.cmd.new)
vim.keymap.set("n", "<A-q>", vim.cmd.qa)
vim.keymap.set("n", "<A-=>", "<C-w>=")

-- Go to tab 1-4 with Alt+1-4
vim.keymap.set("n", "<A-1>", "<cmd>BufferLineGoToBuffer 1<CR>", { desc = "Go to buffer 1" })
vim.keymap.set("n", "<A-2>", "<cmd>BufferLineGoToBuffer 2<CR>", { desc = "Go to buffer 2" })
vim.keymap.set("n", "<A-3>", "<cmd>BufferLineGoToBuffer 3<CR>", { desc = "Go to buffer 3" })
vim.keymap.set("n", "<A-4>", "<cmd>BufferLineGoToBuffer 4<CR>", { desc = "Go to buffer 4" })

-- resize normal mode
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>")          -- Ctrl + Up: Decrease window height
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>")        -- Ctrl + Down: Increase window height
vim.keymap.set("n", "<C-Left>", ":vertical resize +2<CR>") -- Ctrl + Left: Widen window
vim.keymap.set("n", "<C-Right>", ":vertical resize -2<CR>") -- Ctrl + Right: Narrow window

-- resize terminal mode
vim.keymap.set("t", "<C-Down>", "<cmd>resize -2<CR>")          -- Ctrl + Up: Decrease terminal height
vim.keymap.set("t", "<C-Up>", "<cmd>resize +2<CR>")        -- Ctrl + Down: Increase terminal height
vim.keymap.set("t", "<C-Left>", "<cmd>vertical resize +2<CR>") -- Ctrl + Left: Widen terminal
vim.keymap.set("t", "<C-Right>", "<cmd>vertical resize -2<CR>") -- Ctrl + Right: Narrow terminal

-- nvimtree
vim.keymap.set("n", "<C-b>", vim.cmd.NvimTreeToggle)
vim.keymap.set("n", "<A-b>", vim.cmd.NvimTreeToggle, { desc = "Toggle NvimTree" } )
vim.keymap.set("n", "<A-f>", vim.cmd.NvimTreeFindFile, { desc = "Show current file in the tree" } )
vim.keymap.set("n", "<A-r>", vim.cmd.NvimTreeRefresh, { desc = "Refresh NvimTree" } )

-- search highlight
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- lsp related
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = "Rename Buffer"} )
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = "[C]ode [A]ction"} )

vim.keymap.set("n", "<A-w>", function()
  if vim.bo.modified then
    -- Prompt user to save or discard changes
    local choice = vim.fn.confirm("Save changes before closing?", "&Yes\n&No\n&Cancel", 1)
    if choice == 1 then
      vim.cmd("write")              -- Save the file
      vim.cmd("Bdelete")            -- Close the buffer
    elseif choice == 2 then
      vim.cmd("Bdelete!")           -- Discard changes and close buffer
    end
    -- If choice == 3 (Cancel), do nothing
  else
    vim.cmd("Bdelete")              -- Close buffer if no changes
  end
end)

