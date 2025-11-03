local function identify(element_name)
        return function(el)
                local marker = pandoc.Str("[" .. element_name .. "] ")
                -- Elements with a 'content' table (most common)
                if el.content then
                        table.insert(el.content, 1, marker)
                        return el
                end
                -- Elements with 'text' (like RawBlock)
                if el.text then
                        el.text = "[" .. element_name .. "] " .. el.text
                        return el
                end
                -- Elements with 'rows' (Table)
                if el.rows then
                        -- Injecting into a table is complex, so we'll just mark a nearby Para
                        return pandoc.Para(marker)
                end
                return el
        end
end

Para = identify("Para")
Plain = identify("Plain")
Div = identify("Div")
BulletList = identify("BulletList")
OrderedList = identify("OrderedList")
ListItem = identify("ListItem")
Header = identify("Header")
RawBlock = identify("RawBlock")
BlockQuote = identify("BlockQuote")
Table = identify("Table")
