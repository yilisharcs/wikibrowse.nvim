local M = {}

function M.log(stdout)
        local file = assert(io.open("./logfile.txt", "a"))
        if file then
                file:write(M.inspect(stdout) .. "\n")
        end
        file:close()
end

function M.inspect(t, indent)
        t = type(t) == "table" and t or { t }
        indent = indent or ""
        local next_indent = indent .. "        "
        local s = "{\n"
        for k, v in pairs(t) do
                s = s .. next_indent .. "[" .. tostring(k) .. "] = "
                if type(v) == "table" then
                        s = s .. M.inspect(v, next_indent)
                else
                        s = s .. tostring(v)
                end
                s = s .. ",\n"
        end
        s = s .. indent .. "}"
        return s
end

function M.has_class(elem, classes)
        if not elem.classes then return false end
        classes = type(classes) == "table" and classes or { classes }
        for _, class in ipairs(classes) do
                for _, item in ipairs(elem.classes) do
                        if item == class then
                                return true
                        end
                end
        end
        return false
end

-- local row_contains = function(row, name)
--         for _, cell in ipairs(row.cells) do
--                 if cell.content then
--                         for _, block in ipairs(cell.content) do
--                                 if has_class(block, name) then
--                                         return true
--                                 end
--                         end
--                 end
--         end
--         return false
-- end

function M.escape_markdown_brackets(text)
        text = text:gsub("%[", "\\[")
        text = text:gsub("%]", "\\]")
        return text
end

return M
