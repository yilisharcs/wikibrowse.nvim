local function has_class(elem, classes)
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

local references = {}

function Superscript(elem)
        local superscript = {}
        for _, inline in ipairs(elem.content) do
                if inline.t == "Link" and inline.target:find("#cite_note", 1, true) then
                        local identifier = inline.target:sub(2)
                        local text = pandoc.utils.stringify(inline.content)
                        local note_label = text:match("%[(.+)%]")
                        if not note_label then
                                -- Fallback for cases where link text is not like [a] or [1]
                                local num = identifier:match("^cite_note%-(%d+)$")
                                if not num then return elem end
                                note_label = num
                        end
                        references[identifier] = note_label
                        table.insert(superscript, pandoc.RawInline("markdown", "[^" .. note_label .. "]"))
                else
                        return elem
                end
        end
        return superscript
end

local function find_ordered_list(blocks)
        if not blocks then return nil end
        local first_block = blocks[1]
        if first_block.t == "OrderedList" then
                return first_block
        elseif first_block.t == "Div" then
                return find_ordered_list(first_block.content)
        end
end

-- NOTE: I have no idea how to read this code.
function Div(elem)
        if has_class(elem, "reflist") then
                local ol = find_ordered_list(elem.content)
                if not ol then return elem end

                local new_blocks = {}
                for i, item_blocks in ipairs(ol.content) do
                        local first_block = item_blocks[1]
                        local content_blocks = {}
                        if first_block.t == "Plain" and first_block.content[1].attr.identifier:find("cite_note", 1, true) then
                                local cite_note_span = first_block.content[1]
                                local ref_text_span_content = nil
                                for _, inline in ipairs(cite_note_span.content) do
                                        if inline.t == "Span" and has_class(inline, "reference-text") then
                                                if #inline.content > 0 then
                                                        ref_text_span_content = inline.content
                                                end
                                                break
                                        end
                                end
                                if ref_text_span_content then
                                        table.insert(content_blocks, pandoc.Para(ref_text_span_content))
                                elseif #item_blocks > 1 then
                                        for block_index = 2, #item_blocks do
                                                table.insert(content_blocks, item_blocks[block_index])
                                        end
                                end
                        else
                                for _, block in ipairs(item_blocks) do
                                        table.insert(content_blocks, block)
                                end
                        end
                        if #content_blocks > 0 then
                                local identifier = first_block.content[1].attr.identifier
                                local note_label = references[identifier]
                                if not note_label then
                                        local num = identifier:match("^cite_note%-(%d+)$")
                                        if num then
                                                note_label = num
                                        else
                                                if ol.style == "LowerAlpha" then
                                                        note_label = string.char(string.byte("a") + i - 1)
                                                else
                                                        note_label = tostring(ol.start + i - 1)
                                                end
                                        end
                                end
                                local note_key = pandoc.RawInline("markdown", "[^" .. note_label .. "]:")
                                local first_content_block = content_blocks[1]
                                if first_content_block.t == "Para" or first_content_block.t == "Plain" then
                                        table.insert(first_content_block.content, 1, pandoc.Space())
                                        table.insert(first_content_block.content, 1, note_key)
                                else
                                        table.insert(content_blocks, 1, pandoc.Para({ note_key }))
                                end
                                for _, block in ipairs(content_blocks) do
                                        table.insert(new_blocks, block)
                                end
                        end
                end
                return new_blocks
        end
end
