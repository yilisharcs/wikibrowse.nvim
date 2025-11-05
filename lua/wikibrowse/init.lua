local fetch = require("wikibrowse.fetch")
local window = require("wikibrowse.window")

local M = {}

function M.search(fargs)
        coroutine.resume(coroutine.create(function()
                local ok, err = pcall(function()
                        local buf = window.results()
                        local lines = fetch.titles(fargs)
                        if lines then
                                vim.schedule(function()
                                        vim.api.nvim_set_option_value(
                                                "modifiable",
                                                true,
                                                { buf = buf }
                                        )
                                        vim.api.nvim_buf_set_lines(
                                                buf,
                                                0,
                                                -1,
                                                false,
                                                lines
                                        )
                                        vim.api.nvim_set_option_value(
                                                "modifiable",
                                                false,
                                                { buf = buf }
                                        )
                                        vim.api.nvim_win_set_cursor(0, { 3, 0 })
                                end)
                        end
                end)
                if not ok then
                        vim.notify(
                                "search failed: " .. err,
                                vim.log.levels.ERROR
                        )
                end
        end))
end

local function wikiget(page)
        coroutine.resume(coroutine.create(function()
                local ok, err = pcall(function()
                        local buf, exists = window.article(page)
                        vim.api.nvim_set_current_buf(buf)
                        if exists then return end

                        local content = fetch.content(page)
                        if content and content.parse then
                                local lines = vim.split(
                                        content.parse.text,
                                        "\n",
                                        { trimempty = true }
                                )
                                vim.schedule(
                                        function()
                                                vim.api.nvim_buf_set_lines(
                                                        buf,
                                                        0,
                                                        -1,
                                                        false,
                                                        lines
                                                )
                                        end
                                )
                        end
                end)

                if not ok then
                        vim.notify(
                                "wikiget failed: " .. err,
                                vim.log.levels.ERROR,
                                { title = "wikibrowse" }
                        )
                end
        end))
end

function M.enter()
        local buf = window.results()
        local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
        local index = vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1]
        local page = index:match("@page:(%S+)")
        if page == nil then
                vim.notify(
                        "Article title not found on this line.",
                        vim.log.levels.WARN
                )
                return
        end
        vim.api.nvim_win_close(0, true)
        vim.schedule(function() wikiget(page) end)
end

local function get_link_destination(row, col)
        local bufnr = vim.api.nvim_get_current_buf()
        local parser = vim.treesitter.get_parser(bufnr, "markdown_inline")
        if not parser then
                vim.notify(
                        "No `markdown_inline` parser found",
                        vim.log.levels.ERROR,
                        { title = "wikibrowse" }
                )
                return
        end

        local inline_root = parser:parse()[1]:root()
        local node_at_cursor =
                inline_root:named_descendant_for_range(row, col, row, col)
        if not node_at_cursor then return end

        if node_at_cursor:type() == "link_destination" then
                return vim.split(
                        vim.treesitter.get_node_text(node_at_cursor, bufnr),
                        "\\n"
                )[1]
        elseif node_at_cursor:type() == "link_text" then
                local parent = node_at_cursor:parent()
                if parent and parent:type() == "inline_link" then
                        for i = 0, parent:named_child_count() - 1 do
                                local child = parent:named_child(i)
                                if
                                        child
                                        and child:type()
                                                == "link_destination"
                                then
                                        return vim.split(
                                                vim.treesitter.get_node_text(
                                                        child,
                                                        bufnr
                                                ),
                                                "\\n"
                                        )[1]
                                end
                        end
                end
        elseif node_at_cursor:type() == "inline_link" then
                for i = 0, node_at_cursor:named_child_count() - 1 do
                        local child = node_at_cursor:named_child(i)
                        if child and child:type() == "link_destination" then
                                return vim.split(
                                        vim.treesitter.get_node_text(
                                                child,
                                                bufnr
                                        ),
                                        "\\n"
                                )[1]
                        end
                end
        end
end

local function resolve_link(link)
        local type
        if link:match("^https?://") then
                type = "external"
                return link, type
        else
                type = "wiki"
                return link, type
        end
end

function M.follow()
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        local link_destination = get_link_destination(row - 1, col)
        if not link_destination then
                vim.notify(
                        "Not a URL.",
                        vim.log.levels.WARN,
                        { title = "wikibrowse" }
                )
                return
        end

        local resolved_link, link_type = resolve_link(link_destination)
        local bufnr = vim.api.nvim_get_current_buf()
        local winnr = vim.api.nvim_get_current_win()
        local article = {
                bufnr = bufnr,
                from = { bufnr, row, col, 0 },
                tagname = link_destination,
        }
        if link_type == "wiki" then
                wikiget(resolved_link)
                vim.fn.settagstack(winnr, { items = { article } }, "t")
        elseif link_type == "external" then
                vim.ui.open(resolved_link)
        end
end

function M.jump(cmd)
        local index = function()
                local articles = { prev = {}, next = {} }
                local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
                for k, v in ipairs(lines) do
                        if v:match("^##%s") then
                                table.insert(articles.next, k)
                        end
                end
                for i = #articles.next, 1, -1 do
                        table.insert(articles.prev, articles.next[i])
                end
                return { prev = articles.prev, next = articles.next }
        end

        local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
        if cmd == "prev" then
                for _, v in ipairs(index().prev) do
                        if v < row then
                                vim.api.nvim_win_set_cursor(0, { v, 0 })
                                break
                        end
                end
        elseif cmd == "next" then
                for _, v in ipairs(index().next) do
                        if v > row then
                                vim.api.nvim_win_set_cursor(0, { v, 0 })
                                break
                        end
                end
        end
end

return M
