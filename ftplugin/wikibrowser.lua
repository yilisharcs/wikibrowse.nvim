local move = require('wikibrowse.index')

vim.keymap.set('n', 'q', function() vim.api.nvim_win_close(0, true) end, { buffer = true })

vim.keymap.set('n', 'j', function() move.cursor_jump('j') end, { buffer = true })
vim.keymap.set('n', 'k', function() move.cursor_jump('k') end, { buffer = true })
