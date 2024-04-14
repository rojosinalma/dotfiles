-- nc j]]leader
vim.g.mapleader = " "

-- cmds
vim.keymap.set("n", "<leader>ee", vim.cmd.Ex)
vim.keymap.set("n", "<C-L>", vim.cmd.Lazy)
vim.keymap.set("n", "<leader>so", vim.cmd.so)

-- windows & splits
vim.keymap.set("n", "<A-d>", vim.cmd.vnew)
vim.keymap.set("n", "<A-v>", vim.cmd.new)
vim.keymap.set("n", "<A-q>", vim.cmd.quit)
vim.keymap.set("n", "<A-right>", "<C-W>l") -- next window
vim.keymap.set("n", "<A-left>", "<C-W>h") -- prev window
vim.keymap.set("n", "<A-w>", vim.cmd.bd)

vim.keymap.set("n", "<C-Up>", ":resize +2<CR>")
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>")
vim.keymap.set("n", "<C-Left>", ":vertical resize +2<CR>")
vim.keymap.set("n", "<C-Right>", ":vertical resize -2<CR>")

-- terminal
vim.keymap.set("t", "<C-Up>", "<cmd>resize +2<CR>")
vim.keymap.set("t", "<C-Down>", "<cmd>resize -2<CR>")

vim.keymap.set("t", "<C-Left>", "<cmd>vertical resize +2<CR>")
vim.keymap.set("t", "<C-Right>", "<cmd>vertical resize -2<CR>")

-- nvimtree
vim.keymap.set("n", "<C-b>", vim.cmd.NvimTreeToggle)

-- search highlight
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

