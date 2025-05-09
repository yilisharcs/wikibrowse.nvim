#!/usr/bin/env nu

def parser [] {
  lines
  # strip extract tag
  | update 1 { str replace -r "extract: " "" }
  # strip title tag
  | update 0 { str replace -r "title: (.*)" "# $1" | append "" } | flatten
  # strip subheading tags
  | each { str replace -r "(##.*) {#.*}" "$1" }
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
  | to text | str replace -r -a "\n    " " "
  # separate lists with newlines
  | str replace -r -a "(-   .*)" "$1\n"
  # remove excess newlines from previous command
  | str replace -r -a "\n\n\n" "\n\n"
  # remove excess newline at the end of file
  | str replace -r -a "\n$" ""
  | lines | split list ""
  # parse image blocks
  | each {
    if (
      $in.0 | str starts-with "<figure>") or (
      $in.0 | str starts-with "<File:"
    ) {
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
    | str replace -r -a '<figure>.*src="(\S*)"[^>]*?title="([^"]*?)".*' "![$2](File:$1)"
    # | str replace -r -a "%7C" '\|'
    | str replace -r -a '<File:([^>]+)>([^\\]*)\\\|([^<]*)' "$3 <File:$1$2>\n"
    | str replace -r -a "  <" " <"
  }
  | to text

  # | lines
  # | to text
  # | tr -d '\000-\011\013\014\016-\037'          # Why is this here
}

def main [lang: string, pageids: string] {
  let url = ([
    'https://',
    $lang,
    '.wikipedia.org/w/api.php?action=query',
    '&format=json',
    '&prop=revisions',
    '&rvprop=content',
    '&rvslots=main',
    '&pageids=',
    $pageids
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
    | str replace --regex --multiline --all ' "wikilink"' ''
  }
  | to text
  | parser
}
