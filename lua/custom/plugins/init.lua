-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'github/copilot.vim',
    config = function()
      -- Set the node command Copilot will use
      local nodePath = vim.fn.expand '~/.nvm/versions/node/v22.14.0/bin/node'
      -- if nodePath exists, then set vim.g.copilot_node_command
      if vim.fn.filereadable(nodePath) == 1 then
        vim.g.copilot_node_command = nodePath
      end
    end,
  },
  {
    -- extra installation: `./install_gadget.py --all`
    'puremourning/vimspector',
    config = function()
      -- let g:vimspector_enable_mappings = 'HUMAN'
      -- " F9: add breakpoint
      -- " <leader>F9: add conditional breakpoint
      -- " <leader>F8: run to Cursor

      -- " for normal mode - the word under the cursor
      -- nmap <Leader>di <Plug>VimspectorBalloonEval
      vim.keymap.set('n', '<Leader>di', '<Plug>VimspectorBalloonEval', { noremap = true })
      -- " for visual mode, the visually selected text
      -- xmap <Leader>di <Plug>VimspectorBalloonEval
      vim.keymap.set('x', '<Leader>di', '<Plug>VimspectorBalloonEval', { noremap = true })
      --
      -- nnoremap <Leader>dd :call vimspector#Launch() \| set mouse=a<CR>
      vim.keymap.set('n', '<Leader>dd', ':call vimspector#Launch() | set mouse=a<CR>', { noremap = true })
      -- " end vim-inspector
      -- nnoremap <Leader>de :call vimspector#Reset()  \| set mouse-=a<CR>
      vim.keymap.set('n', '<Leader>de', ':call vimspector#Reset()  | set mouse-=a<CR>', { noremap = true })
      --
      -- " toggle break point
      -- nnoremap <Leader>dt :call vimspector#ToggleBreakpoint()<CR>
      vim.keymap.set('n', '<Leader>dt', ':call vimspector#ToggleBreakpoint()<CR>', { noremap = true })
      -- " clean all break points
      -- nnoremap <Leader>dT :call vimspector#ClearBreakpoints()<CR>
      vim.keymap.set('n', '<Leader>dT', ':call vimspector#ClearBreakpoints()<CR>', { noremap = true })
    end,
  },
}
