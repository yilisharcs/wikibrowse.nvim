#!/usr/bin/env nu

# Sends a GET request to the Wikipedia API to retrieve
# an article by title or id, or a list of summaries
def get-article [opts: record] {
  if ([
    ($opts.pageid | is-empty)
    ($opts.title | is-empty)
    ($opts.search | is-empty)
  ] | all {}) {
    return $"(ansi red)Missing arguments."
  }

  # Default url, defined here to avoid repetition
  mut url = ([
    'https://',
    $opts.lang,
    '.wikipedia.org/w/api.php?action=query',
    '&format=json',
    '&prop=revisions',
    '&rvprop=content',
    '&rvslots=main',
  ] | str join)

  if not ($opts.search | is-empty) {
    $url = ([
      "https://",
      $opts.lang,
      ".wikipedia.org/w/api.php?action=query",
      "&format=json",
      "&prop=extracts|info",
      "&generator=search",
      "&inprop=url",
      "&exsentences=1",
      "&exlimit=max",
      "&exintro",
      "&explaintext",
      "&redirects",
      "&gsrsearch=",
      ($opts.search | url encode)
    ] | str join)
  } else if not ($opts.title | is-empty) {
    $url = ([$url '&titles=' $opts.title] | str join)
  } else if not ($opts.pageid | is-empty) {
    $url = ([$url '&pageids=' $opts.pageid] | str join)
  }

  http get $url
  | if not ($opts.search | is-empty) {
    flatten
    | get pages
    | values
    | flatten
    | sort-by index
    | select -i pageid title index extract fullurl
  } else {
    get query.pages
    | flatten
    | select title revisions.slots.main.*
    | rename title extract
  }
}

def parse-article [--wrap] {
  flatten
  | update extract {
    to text | pandoc --from mediawiki --to markdown_phpextra
  }
  | to text | lines
  # strip extract tag
  | update 1 { str replace "extract: " "" }
  # strip title tag
  | update 0 { str replace -r "title: (.*)" "# $1" | append "" } | flatten
  # strip subheading tags
  | each { str replace -r "(##.*) {#.*}" "$1" }
  # strip wikilink markers
  | each { str replace -m -a ' "wikilink"' '' }
  # join paragraphs into single lines
  | split list ""
  | each {
    if not (
      # ignore html tags
      $in | str starts-with "<" | first) and not (
      # ignore lists
      $in | str starts-with "-   " | first) {
      str join " "
    } else {
      return $in
    }
  }
  # # join paragraphs into single lines
  # | split list ""
  # | each {
  #   if not (
  #     # ignore html tags
  #     $in | str starts-with "<" | first) and not (
  #     # ignore lists
  #     $in | str starts-with "-   " | first) {
  #     str join " "
  #   } else {
  #     return $in
  #   }
  # }
  # # separate lines with newlines
  # | each { append "" } | flatten
  # # join lists into single lines
  # | to text | str replace -a "\n    " " "
  # # separate lists with newlines
  # | str replace -r -a "(-   .*)" "$1\n"
  # # remove excess newline at the end of file
  # | str replace -r -a "\n$" ""
  # | lines
  # parse image blocks
  | split list ""
  | each {
    if (
      $in.0 | str starts-with "<figure>") or (
      $in.0 | str starts-with "<table>"
    ) {
      str join "\n"
      | pandoc --from html --to markdown
    } else if ($in.0 | str starts-with "<File:") {
      str join " "
    } else {
      return $in
    }
  }
  # separate lines with newlines (again)
  | each { append "" } | flatten
  # parse images cont.
  | each {
    $in
    # | str replace -r -a '<figure>.*src="(\S*)"[^>]*?title="([^"]*?)".*' "![$2](File:$1)"
    # | str replace -r -a "%7C" '\|'
    | str replace -r -a '<File:([^>]+)>([^\\]*)\\\|([^<]*)' "$3 <File:$1$2>\n"
    # | str replace -r -a '<File:([^>]+)>'
    | str replace -a "  <" " <"
  }
  | to text
  | tr -d '\000-\011\013\014\016-\037'          # Why is this here
}

def main [
  --lang (-l): string    # Which language to return results with
  --wrap (-w)            # Whether to join lines for line wrapping
  --pageid (-i): int     # Article id
  --title (-t): string   # Article title
  --search (-s): string  # Retrieve article summaries or one article
] {
  mut opts = {
    lang: $lang
    pageid: $pageid
    title: $title
    search: $search
  }

  if ($opts.lang | is-empty) { $opts.lang = "en" }

  get-article $opts
  | if ($opts.search | is-empty) {
    if $wrap {
      parse-article --wrap
    } else {
      parse-article
    }
  } else {
    return $in
  }
}

# dev func for api testing
def "main api" [] {
  get-article {
    lang: en
    pageid: 24768
    title: null
    search: null
  }
  | to json
  | save -f pandoc.json
}

# dev func for post-processing
def "main parser" [] {
  $env.config = ($env.config | update use_ansi_coloring false)

  open pandoc.json
  | parse-article
  | table -e
  | save -f output.barfoo
}
