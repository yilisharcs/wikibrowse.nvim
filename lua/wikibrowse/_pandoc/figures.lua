function Link(elem)
        if elem.target:match("/File:") then
                elem.content[1].src = "https:" .. elem.content[1].src
                return elem.content
        end
end

function Figure(elem)
        local function set_img_caption(el)
                if el.t == "Image" and elem.caption.long[1].content then
                        el.caption = elem.caption.long[1].content
                        return el
                end
        end
        elem = pandoc.walk_block(elem, { Inline = set_img_caption })
        elem.caption = {}
        return elem
end
