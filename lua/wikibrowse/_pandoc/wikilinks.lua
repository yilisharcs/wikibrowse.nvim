function Link(elem)
        if not elem.target:match("^/wiki/") then return end
        elem.target = string.sub(elem.target, 7)
        elem.title = ""
        return elem
end
