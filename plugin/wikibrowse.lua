if vim.g.loaded_wikibrowse == 1 then return end
vim.g.loaded_wikibrowse = 1

vim.api.nvim_create_user_command("Wikibrowse", function(args) require("wikibrowse").search(args.fargs) end, {
        desc = "Search Wikipedia articles",
        nargs = "*",
})

local width = math.floor(vim.o.columns * 0.79)
local height = math.floor(vim.o.lines * 0.63)
local col = math.floor((vim.o.columns - width) / 2) -- Center the window
local row = math.floor((vim.o.lines - height) / 2) - 2

local DEFAULTS = {
        -- database = vim.fs.joinpath(vim.fn.stdpath("data"), "wikibrowse"),
        lang = "en",
        winopts = {
                width = width,
                height = height,
                col = col,
                row = row,
        },
}

vim.g.wikibrowse = vim.tbl_deep_extend("force", DEFAULTS, vim.g.wikibrowse or {})
