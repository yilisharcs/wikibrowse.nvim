#!/usr/bin/env nu

def "main search" [lang: string, ...str: string] {
        let args = ($str | str join " ")
        let query = ($args | url encode)
        let url = ([
                "https://",
                $lang,
                ".wikipedia.org/w/api.php?action=query",
                "&format=json",
                "&formatversion=2",
                "&prop=extracts|info|pageprops",
                "&ppprop=disambiguation"
                "&gsrlimit=20",
                "&exlimit=max",
                "&exsentences=1",
                "&exintro",
                "&explaintext",
                "&inprop=url",
                "&redirects",
                "&generator=search",
                "&gsrsearch=",
                $query
        ] | str join)
        http get $url
        | get query.pages
        | select title index extract lastrevid canonicalurl
        | sort-by index
        | to json
}

const bin = (path self)
let root = ($bin | path dirname | path dirname)
let pflags = [
        --strip-comments=true
        --wrap=auto
        --lua-filter=([$root pandoc/editor_links.lua] | path join)
        --lua-filter=([$root pandoc/figures.lua] | path join)
        --lua-filter=([$root pandoc/footnotes.lua] | path join)
        --lua-filter=([$root pandoc/shortdescription.lua] | path join)
        --lua-filter=([$root pandoc/string_symbols.lua] | path join)
        --lua-filter=([$root pandoc/wikilinks.lua] | path join) # NOTE: Must precede tables filter else links break
        --lua-filter=([$root pandoc/tables.lua] | path join)
        # --lua-filter=([$root pandoc/_identify.lua] | path join)
]

def markdown_get [lang: string, title: string] {
        let url = ([
                "https://",
                $lang,
                ".wikipedia.org/w/api.php?action=parse",
                "&format=json",
                "&formatversion=2",
                "&prop=text|revid",
                "&page=",
                $title
        ] | str join)
        http get $url
        | get parse
}

def "main enter" [lang: string, title: string] {
        markdown_get $lang $title
        | update text {
                pandoc ...$pflags --from=html --to=gfm-raw_html
        }
        | to json
}

def "main debug" [] {
        if ("logfile.txt" | path exists) {
                rm logfile.txt
        }
        if not ("pizza.json" | path exists) {
                markdown_get en Pizza | to json | save -f pizza.json
        }
        if not ("battle_of_midway.json" | path exists) {
                markdown_get en Battle_of_Midway | to json | save -f battle_of_midway.json
        }
        open ./pizza.json
        | get text
        # | tee { pandoc ...$pflags --from=html --to=html | save -f pizza.html }
        # | tee { pandoc ...$pflags --from=html --to=markdown | save -f pizza.markdown }
        |       pandoc ...$pflags --from=html --to=gfm-raw_html | save -f pizza.gfm.md

        # open ./battle_of_midway.json
        # | get text
        # | tee { pandoc ...$pflags --from=html --to=html | save -f battle_of_midway.html }
        # | tee { pandoc ...$pflags --from=html --to=markdown | save -f battle_of_midway.markdown }
        # |       pandoc ...$pflags --from=html --to=gfm-raw_html | save -f battle_of_midway.gfm.md
}

def main [] { print $"(ansi red_bold)Subcommand required.(ansi reset)" }
