local config = vim.g.wikibrowse
local path = vim.api.nvim__get_runtime({ "lua/wikibrowse" }, false, {})[1]
local root = vim.fs.dirname(vim.fs.dirname(path))
local script = vim.fs.joinpath(root, "bin/wikibrowse.nu")

local health = require("wikibrowse.health")
local window = require("wikibrowse.window")

local M = {}

-- TODO: Make this a global value for modularity?
local win_state = {
        floating = {
                buf = -1,
                win = -1,
        },
}

function M.search(query)
        if not health.check() then return end
        if not vim.api.nvim_win_is_valid(win_state.floating.win) then
                win_state.floating = window.results_page({
                        width = config.winopts.width,
                        height = config.winopts.height,
                        col = config.winopts.col,
                        row = config.winopts.row,
                        buf = win_state.floating.buf,
                })
                vim.api.nvim_set_option_value("filetype", "wikibrowseresults", { buf = win_state.floating.buf })
                vim.api.nvim_set_option_value(
                        "syntax",
                        "wikibrowseresults",
                        { buf = win_state.floating.buf, scope = "local" }
                )
        end
        local on_exit = function(obj)
                vim.schedule(function()
                        local lines = {}
                        table.insert(lines, "# SEARCH RESULTS")
                        table.insert(lines, "")
                        local stdout = vim.json.decode(obj.stdout)
                        for _, item in ipairs(stdout) do
                                local prefix = "^https://%a+%.wikipedia%.org/wiki/"
                                local page = item.canonicalurl:gsub(prefix, "")
                                table.insert(lines, "## " .. item.title .. " @page:" .. page)
                                table.insert(lines, item.extract)
                                table.insert(lines, "")
                        end
                        vim.api.nvim_set_option_value("modifiable", true, { buf = win_state.floating.buf })
                        vim.api.nvim_buf_set_lines(win_state.floating.buf, 0, -1, false, lines)
                        vim.api.nvim_set_option_value("modifiable", false, { buf = win_state.floating.buf })
                        vim.api.nvim_win_set_cursor(0, { 3, 0 })
                end)
        end
        vim.system({
                script,
                "search",
                config.lang,
                query,
        }, { text = true }, on_exit)
end

function M.jump(cmd)
        local index = function()
                local articles = { prev = {}, next = {} }
                local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
                for k, v in ipairs(lines) do
                        if v:match("^##%s") then table.insert(articles.next, k) end
                end
                for i = #articles.next, 1, -1 do
                        table.insert(articles.prev, articles.next[i])
                end
                return { prev = articles.prev, next = articles.next }
        end
        local row, _col = unpack(vim.api.nvim_win_get_cursor(0))
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

local function wikiget(page)
        local buf = window.article_buffer(page)
        if not buf then return end
        local on_exit = function(obj)
                vim.schedule(function()
                        local stdout = vim.json.decode(obj.stdout)
                        local lines = vim.split(stdout.text, "\n", { trimempty = true })
                        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
                end)
        end
        vim.system({
                script,
                "enter",
                config.lang,
                page,
        }, { text = true }, on_exit)
end

function M.enter()
        local row, _col = unpack(vim.api.nvim_win_get_cursor(0))
        local index = vim.api.nvim_buf_get_lines(win_state.floating.buf, row - 1, row, false)[1]
        local page = index:match("@page:(%S+)")
        if page == nil then
                vim.notify("Page name not found on this line.", vim.log.levels.WARN)
                return
        end
        vim.api.nvim_win_close(0, true)
        wikiget(page)
end

local function get_link_destination(row, col)
        local bufnr = vim.api.nvim_get_current_buf()
        local parser = vim.treesitter.get_parser(bufnr, "markdown_inline")
        if not parser then
                vim.notify("No `markdown_inline` parser found", vim.log.levels.ERROR, { title = "wikibrowse" })
                return
        end

        local inline_root = parser:parse()[1]:root()
        local node_at_cursor = inline_root:named_descendant_for_range(row, col, row, col)
        if not node_at_cursor then return end

        if node_at_cursor:type() == "link_destination" then
                return vim.split(vim.treesitter.get_node_text(node_at_cursor, bufnr), "\\n")[1]
        elseif node_at_cursor:type() == "link_text" then
                local parent = node_at_cursor:parent()
                if parent and parent:type() == "inline_link" then
                        for i = 0, parent:named_child_count() - 1 do
                                local child = parent:named_child(i)
                                if child and child:type() == "link_destination" then
                                        return vim.split(vim.treesitter.get_node_text(child, bufnr), "\\n")[1]
                                end
                        end
                end
        elseif node_at_cursor:type() == "inline_link" then
                for i = 0, node_at_cursor:named_child_count() - 1 do
                        local child = node_at_cursor:named_child(i)
                        if child and child:type() == "link_destination" then
                                return vim.split(vim.treesitter.get_node_text(child, bufnr), "\\n")[1]
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
                vim.notify("Not a URL.", vim.log.levels.WARN, { title = "wikibrowse" })
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

return M
