vim.bo.modifiable = false
vim.bo.swapfile = false

vim.wo.cursorline = false
vim.wo.number = true

vim.wo.wrap = true
vim.wo.linebreak = true

vim.wo.concealcursor = 'nc'
vim.wo.conceallevel = 3

vim.bo.syntax = 'on'

-- vim.keymap.set('n', '<CM>', function()
--   vim.cmd('norm f(gf')
-- end)

vim.keymap.set({ 'n', 'x', 'o' }, 'j', "(&wrap ? 'gj' : 'j')", { expr = true, buffer = true })
vim.keymap.set({ 'n', 'x', 'o' }, 'k', "(&wrap ? 'gk' : 'k')", { expr = true, buffer = true })

vim.keymap.set('n', 'q', function()
  vim.bo.buflisted = false
  vim.api.nvim_buf_delete(0, { unload = true })
end, { buffer = true })
