-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    -- auto add `end` for if, def, etc...
    'tpope/vim-endwise',
    -- automatic closing of quotes, parenthesis, brackets, etc
    'Raimondi/delimitMate',
    'tpope/vim-surround',
    'vim-airline/vim-airline',
  },
  {
    'nvim-tree/nvim-tree.lua',
    event = 'VimEnter',
    dependencies = {
      -- Useful for getting pretty icons, but requires a Nerd Font.
      -- { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    -- empty setup using defaults
    config = function()
      -- nvim-tree
      -- disable netrw at the very start of your init.lua
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      require('nvim-tree').setup {
        renderer = {
          icons = {
            glyphs = {
              default = '📄', -- Change this to another symbol if needed
              symlink = '🔗',
              folder = {
                default = '📁',
                open = '📂',
                empty = '·',
                empty_open = '·',
                symlink = '🔗',
                symlink_open = '🔗',
              },
              git = {
                unstaged = '✗',
                staged = '✓',
                unmerged = '═',
                renamed = '➜',
                untracked = '★',
                deleted = '⊖',
                ignored = '◌',
              },
            },
          },
        },
      }
      vim.keymap.set('n', '<leader>fl', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
    end,
  },
}
