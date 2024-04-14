return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "vimdoc", "lua", "ruby", "go", "bash", "dockerfile",
        "git_config", "gitcommit", "gitignore", "hcl", "helm",
        "html", "javascript", "json", "jq", "make", "cmake", 
        "nix", "python", "rust", "sql", "terraform", "tmux",
        "typescript", "vim", "yaml", "toml",
      },

      -- Install parsers Async
      sync_install = false,

      -- Auto install missing parsers when entering buffer
      -- Set to false if you don't have `tree-sitter` CLI installed locally
      auto_install = true, 

      indent = {
        enable = true,
      },

      highlight = {
        -- `false` disables the whole extension
        enable = true,

        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on "syntax" being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = { "markdown" },
      },
    })
    
    local treesitter_parser_config = require("nvim-treesitter.parsers").get_parser_configs()
      treesitter_parser_config.templ = {
        install_info = {
          url = "https://github.com/vrischmann/tree-sitter-templ.git",
          files = {"src/parser.c", "src/scanner.c"},
          branch = "master",
        },
      }
      
    vim.treesitter.language.register("templ", "templ")
  end
}
