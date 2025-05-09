#!/usr/bin/env nu

def get-article [
  opts_lang: string
  pageid: string
] {
  let url = ([
    'https://',
    $opts_lang,
    '.wikipedia.org/w/api.php?action=query',
    '&format=json',
    '&prop=revisions',
    '&rvprop=content',
    '&rvslots=main',
    '&pageids=',
    $pageid
  ] | str join)

  http get $url
  | get query.pages
  | flatten
  | select title revisions.slots.main.*
  | rename title extract
  | update extract {
    $in
    | to text
    | pandoc --from mediawiki --to markdown_phpextra
  }
}

def parse-article [] {
  to text | lines
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
  # separate lines with newlines
  | each { append "" } | flatten
  # join lists into single lines
  | to text | str replace -a "\n    " " "
  # separate lists with newlines
  | str replace -r -a "(-   .*)" "$1\n"
  # remove excess newlines from previous command
  | str replace -a "\n\n\n" "\n\n"
  # remove excess newline at the end of file
  | str replace -r -a "\n$" ""
  # parse image blocks
  | lines | split list ""
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
  # | table
  # | to text

# | lines
# | to text
# | tr -d '\000-\011\013\014\016-\037'          # Why is this here
}

def main [
  --lang (-l): string
  --wrap (-w)
  pageid: string
] {
  mut opts_lang = 'en'
  if not ($lang | is-empty) { $opts_lang = $lang }

  mut opts_wrap = true
  if not $wrap { $opts_wrap = false }

  get-article $opts_lang $pageid
  | parse-article
}

def "main test" [] {
  $env.config = ($env.config | update use_ansi_coloring false)

  open pandoc.nuon
  | parser
  | save -f output.barfoo
}
