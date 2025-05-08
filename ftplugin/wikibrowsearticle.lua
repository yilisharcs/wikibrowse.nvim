vim.cmd("runtime! ftplugin/markdown.vim ftplugin/markdown.lua")

local wiki = require("wikibrowse")
vim.keymap.set("n", "<C-]>", function() wiki.follow() end, { buffer = true })

-- vim.wo.concealcursor = "nc"
-- vim.wo.conceallevel = 3
