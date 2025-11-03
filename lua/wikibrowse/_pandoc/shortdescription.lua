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

function Div(elem)
        if has_class(elem, "shortdescription") then
                return {}
        end
end
