local M = {}

local float = {
        buf = -1,
        win = -1,
}

function M.results()
        local winopts = vim.g.wikibrowse.winopts
        if not vim.api.nvim_win_is_valid(float.win) then
                if not vim.api.nvim_buf_is_valid(float.buf) then
                        float.buf = vim.api.nvim_create_buf(false, true)
                end
                local config = {
                        relative = "editor",
                        width = winopts.width,
                        height = winopts.height,
                        row = winopts.row,
                        col = winopts.col,
                        style = "minimal",
                        border = "rounded",
                        title = " wikibrowse ",
                        title_pos = "center",
                }
                float.win = vim.api.nvim_open_win(float.buf, true, config)
                vim.api.nvim_set_option_value(
                        "filetype",
                        "wikibrowseresults",
                        { buf = float.buf }
                )
                vim.api.nvim_set_option_value(
                        "syntax",
                        "wikibrowseresults",
                        { buf = float.buf, scope = "local" }
                )
        end
        return float.buf
end

function M.article(page)
        local buflist = vim.api.nvim_list_bufs()
        for _, bufnr in ipairs(buflist) do
                if vim.api.nvim_buf_is_valid(bufnr) then
                        local bufname = vim.api.nvim_buf_get_name(bufnr)
                        bufname = bufname:gsub("^wikibrowse://", "")
                        if bufname == page then return bufnr, true end
                end
        end

        local buf = vim.api.nvim_create_buf(false, true)
        vim.bo[buf].filetype = "wikibrowsearticle"
        vim.api.nvim_buf_set_name(buf, "wikibrowse://" .. page)
        return buf, false
end

return M
