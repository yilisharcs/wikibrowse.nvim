local M = {}

M.results_page = function(opts)
        if not vim.api.nvim_buf_is_valid(opts.buf) then opts.buf = vim.api.nvim_create_buf(false, true) end
        local win_config = {
                relative = "editor",
                width = opts.width,
                height = opts.height,
                row = opts.row,
                col = opts.col,
                -- TODO: Add keys below to plugin defaults
                style = "minimal",
                border = "rounded",
                title = " Wikibrowse ",
                title_pos = "center",
        }
        local win = vim.api.nvim_open_win(opts.buf, true, win_config)
        return { buf = opts.buf, win = win }
end

M.article_buffer = function(page)
        local buflist = vim.api.nvim_list_bufs()
        for _, bufnr in ipairs(buflist) do
                if vim.api.nvim_buf_is_valid(bufnr) then
                        local bufname = vim.api.nvim_buf_get_name(bufnr)
                        bufname = bufname:gsub("^wikibrowse://", "")
                        if bufname == page then
                                vim.api.nvim_set_current_buf(bufnr)
                                return
                        end
                end
        end

        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_set_current_buf(buf)
        vim.bo[buf].filetype = "wikibrowsearticle"
        vim.api.nvim_buf_set_name(buf, "wikibrowse://" .. page)
        return buf
end

return M
