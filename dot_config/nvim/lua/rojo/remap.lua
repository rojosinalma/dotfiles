-- nc j]]leader
vim.g.mapleader = " "

-- quick cmds
vim.keymap.set("n", "<leader>ee", vim.cmd.Ex) -- open nvim explorer
vim.keymap.set("n", "<leader>ll", vim.cmd.Lazy) -- open Lazy
vim.keymap.set("n", "<leader>so", vim.cmd.so) -- source current file
vim.keymap.set("n", "<A-s>", vim.cmd.write) -- save

-- windows & splits 
-- NOTE: The rest of the bindings are taken care of in nvim-tmux-navigator
vim.keymap.set("n", "<A-d>", vim.cmd.vnew)
vim.keymap.set("n", "<A-v>", vim.cmd.new)
vim.keymap.set("n", "<A-q>", vim.cmd.quit)
vim.keymap.set("n", "<A-w>", vim.cmd.bd)
vim.keymap.set("n", "<A-=>", "<C-w>=")

-- resize normal mode
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>")
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>")
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>")
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>")

-- resize terminal mode
vim.keymap.set("t", "<C-Up>", "<cmd>resize +2<CR>")
vim.keymap.set("t", "<C-Down>", "<cmd>resize -2<CR>")
vim.keymap.set("t", "<C-Left>", "<cmd>vertical resize -2<CR>")
vim.keymap.set("t", "<C-Right>", "<cmd>vertical resize +2<CR>")

-- nvimtree
vim.keymap.set("n", "<C-b>", vim.cmd.NvimTreeToggle)
vim.keymap.set("n", "<A-b>", vim.cmd.NvimTreeToggle, { desc = "Toggle NvimTree" } )
vim.keymap.set("n", "<A-f>", vim.cmd.NvimTreeFindFileToggle, { desc = "Show current file in the tree" } )
vim.keymap.set("n", "<A-r>", vim.cmd.NvimTreeRefresh, { desc = "Refresh NvimTree" } )

-- search highlight
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- lsp related
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, {})
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action)
