local rtp = vim.api.nvim_get_runtime_file("lua/wikibrowse/_pandoc", false)[1]

local M = {}

local function request(url)
        local co = coroutine.running()
        vim.net.request(url, {}, function(err, resp)
                if err then
                        coroutine.resume(co, nil, err)
                else
                        coroutine.resume(co, resp)
                end
        end)
        return coroutine.yield()
end

---@param str string[]
---@return string[]
function M.titles(str)
        local args = table.concat(str, " ")
        local query = vim.uri_encode(args)
        local url = table.concat({
                "https://",
                vim.g.wikibrowse.lang,
                ".wikipedia.org/w/api.php?action=query",
                "&format=json",
                "&formatversion=2",
                "&prop=extracts|info|pageprops",
                "&ppprop=disambiguation",
                "&gsrlimit=20",
                "&exlimit=max",
                "&exsentences=1",
                "&exintro",
                "&explaintext",
                "&inprop=url",
                "&redirects",
                "&generator=search",
                "&gsrsearch=",
                query,
        })

        local resp, err = request(url)
        if err then
                vim.notify("request failed: " .. err, vim.log.levels.ERROR)
                return
        end
        local json = vim.json.decode(resp.body)
        if json.error then error(json.error.info) end

        -- Build the results page content
        local lines = {}
        table.insert(lines, "# SEARCH RESULTS")
        table.insert(lines, "")

        local pages = json.query.pages
        table.sort(
                pages,
                function(a, b) return (a.index or 0) < (b.index or 0) end
        )

        for _, item in ipairs(pages) do
                local prefix = "^https://%a+%.wikipedia%.org/wiki/"
                local page = item.canonicalurl:gsub(prefix, "")
                table.insert(lines, "## " .. item.title .. " @page:" .. page)
                -- table.insert(lines, item.extract) -- FIXME: QUESTION: Why did I comment this out?
                for line in item.extract:gmatch("[^\r\n]+") do
                        table.insert(lines, line)
                end
                table.insert(lines, "")
        end
        return lines
end

-- Nushell equivalent of "main enter"
function M.content(page)
        local url = table.concat({
                "https://",
                vim.g.wikibrowse.lang,
                ".wikipedia.org/w/api.php?action=parse",
                "&format=json",
                "&formatversion=2",
                "&prop=text|revid",
                "&page=",
                page,
        })

        local resp, err = request(url)
        if err then
                vim.notify("request failed: " .. err, vim.log.levels.ERROR)
                return
        end
        local json = vim.json.decode(resp.body)
        if not json.parse then error(json.error.info) end

        local pflags = {
                "pandoc",
                "--from=html",
                "--to=gfm-raw_html",
                "--strip-comments=true",
                "--wrap=auto",
                ("--lua-filter=%s/editor_links.lua"):format(rtp),
                ("--lua-filter=%s/figures.lua"):format(rtp),
                ("--lua-filter=%s/footnotes.lua"):format(rtp),
                ("--lua-filter=%s/shortdescription.lua"):format(rtp),
                ("--lua-filter=%s/string_symbols.lua"):format(rtp),
                ("--lua-filter=%s/wikilinks.lua"):format(rtp),
                -- ("--lua-filter=%s/tables.lua"):format(rtp),
                -- ("--lua-filter=%s/_identify.lua"):format(rtp),
        }

        local co = coroutine.running()
        vim.system(
                pflags,
                { stdin = json.parse.text },
                function(obj) coroutine.resume(co, obj) end
        )
        local obj = coroutine.yield()

        json.parse.text = obj.stdout
        return json
end

-- -- TODO: implement this
-- function M._debug()
--         if vim.fn.filereadable("./logfile.txt") then vim.fs.rm("logfile.txt") end
--         if not vim.fn.filereadable("pizza.json") then
--                 -- create
--                 -- file
--         end
--         if not vim.fn.filereadable("battle_of_midway.json") then
--                 -- create
--                 -- file
--         end
-- end

return M
