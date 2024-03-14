vim.g.base46_cache = vim.fn.stdpath "data" .. "/nvchad/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
    config = function()
      require "options"
    end,
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "nvchad.autocmds"

vim.schedule(function()
  require "mappings"
end)

local vim = vim
local Plug = vim.fn['plug#']

-- setting up vim-plug
local plugpath = vim.fn.stdpath "data" .. "/site/autoload/lazy.nvim"

if not vim.loop.fs_stat(plugpath) then
  local plug_raw ="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
  vim.fn.system { "curl", "-fLo", plugpath, "--create-dirs", plug_raw }
end

vim.call('plug#begin')

Plug('mg979/vim-visual-multi')

vim.call('plug#end')
