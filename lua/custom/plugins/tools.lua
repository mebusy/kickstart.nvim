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
  {
    'vim-airline/vim-airline',
    -- if has('macunix')
    --     " markdown chrome browse
    --     " autocmd BufRead,BufNewFile *.{md,mdown,mkd,mkdn,markdown,mdwn} map <Leader>md :! $chrome_app"/Contents/MacOS/Google Chrome" "%:p"<CR>
    --     autocmd BufRead,BufNewFile *.{md,mdown,mkd,mkdn,markdown,mdwn} map <Leader>md :! open -a "Google Chrome" "%:p"<CR>
    -- endif
    config = function()
      if vim.fn.has 'macunix' == 1 then
        -- Open Markdown files in Google Chrome
        vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
          pattern = { '*.md', '*.mdown', '*.mkd', '*.mkdn', '*.markdown', '*.mdwn' },
          callback = function()
            vim.keymap.set('n', '<Leader>md', function()
              local file_path = vim.fn.expand '%:p' -- Get full path of current file
              vim.cmd("!open -a 'Google Chrome' '" .. file_path .. "'")
            end, { noremap = true, silent = true })
          end,
        })
      end
    end,
  },
}
