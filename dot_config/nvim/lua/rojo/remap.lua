-- leader
vim.g.mapleader = " "

-- cmds
vim.keymap.set("n", "<leader>ee", vim.cmd.Ex)
vim.keymap.set("n", "<leader>L", vim.cmd.Lazy)
vim.keymap.set("n", "<leader>so", vim.cmd.so)

-- windows & splits
vim.keymap.set("n", "<A-d>", vim.cmd.vnew)
vim.keymap.set("n", "<A-v>", vim.cmd.new)
vim.keymap.set("n", "<A-w>", vim.cmd.close)
vim.keymap.set("n", "<A-q>", vim.cmd.quit)
vim.keymap.set("n", "<A-l>", vim.cmd.buffers)
