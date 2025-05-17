return {
  "nvim-telescope/telescope.nvim",

  tag = '0.1.6',

  dependencies = {
    "nvim-lua/plenary.nvim"
  },

  config = function()
    require('telescope').setup({
      pickers = {
        find_files = {
          hidden = true
        }
      }
    })

    local builtin = require('telescope.builtin')
    vim.keymap.set('n', '<leader>ef', builtin.find_files, { desc = '[E]asy [F]ind' })
    vim.keymap.set('n', '<A-p>', builtin.find_files, {})
    vim.keymap.set('n', '<A-l>', builtin.buffers, { desc = '[A]ll Buffer [L]ist' })
    vim.keymap.set('n', '<A-.>', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
    vim.keymap.set('n', '<A-g>', builtin.git_files, { desc = 'Show git files' } )
    vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
    vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
    vim.keymap.set("n", "<leader>hh", "<cmd>Telescope help_tags<CR>", { desc = "Search help docs" })
    vim.keymap.set("n", "<leader>man", "<cmd>Telescope man_pages<CR>", { desc = "Search man pages" })
    vim.keymap.set("n", "<leader>cmd", "<cmd>Telescope commands<CR>", { desc = "Search commands" })


    vim.keymap.set('n', '<leader>pws', function()
      local word = vim.fn.expand("<cword>")
      builtin.grep_string({ search = word })
    end)

    vim.keymap.set('n', '<leader>pWs', function()
      local word = vim.fn.expand("<cWORD>")
      builtin.grep_string({ search = word })
    end)

    vim.keymap.set('n', '<leader>ps', function()
      builtin.grep_string({ search = vim.fn.input("Grep > ") })
    end)
    -- require if installed
    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')
  end
}

