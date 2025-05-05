vim.keymap.set('n', 'q', function() vim.api.nvim_win_close(0, true) end, { buffer = true })
