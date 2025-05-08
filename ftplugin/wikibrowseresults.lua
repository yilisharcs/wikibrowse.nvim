vim.cmd("runtime! ftplugin/markdown.vim ftplugin/markdown.lua")

vim.bo.swapfile = false

vim.wo[0][0].cursorline = true
vim.wo[0][0].cursorlineopt = "both"
vim.wo[0][0].winhighlight = "CursorLine:CurSearch"
vim.wo[0][0].number = false
vim.wo[0][0].wrap = true
vim.wo[0][0].linebreak = true

vim.wo[0][0].concealcursor = "nc"
vim.wo[0][0].conceallevel = 3

local wiki = require("wikibrowse")
vim.keymap.set("n", "j", function() wiki.jump("next") end, { buffer = true })
vim.keymap.set("n", "k", function() wiki.jump("prev") end, { buffer = true })
vim.keymap.set("n", "<CR>", function() wiki.enter() end, { buffer = true })
vim.keymap.set("n", "q", function() vim.api.nvim_win_close(0, true) end, { buffer = true })
