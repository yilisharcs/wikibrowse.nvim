local M = {}

function M.check()
        if vim.g.wikibrowse_checkhealth == true then return true end
        if vim.version().minor < 11 then
                vim.notify("Neovim is not version 0.11.0 or above.", vim.log.levels.WARN, { title = "wikibrowse" })
                return false
        end
        if vim.fn.executable("nu") == 0 then
                vim.notify("Required executable `nu` not found.", vim.log.levels.ERROR, { title = "wikibrowse" })
                return false
        elseif vim.fn.executable("pandoc") == 0 then
                vim.notify("Required executable `pandoc` not found.", vim.log.levels.ERROR, { title = "wikibrowse" })
                return false
        end
        return true
end

return M
