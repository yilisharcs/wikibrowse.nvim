function Str(elem)
        if elem.text == ">" then
                return pandoc.RawInline("markdown", ">")
        end
end
