#!/usr/bin/env nu

def parser [] {
  $in
  | str replace -r 'title: (.*)' "# $1\n"       # strip title tag (needs \n to counter 3rd cmd)
  | str replace -r 'extract: ' ''               # strip extract tag
  | str replace -r -a "([^\n])(?!\n-)\n" '$1 '  # join paragraphs into single lines (don't match lists)
  | str replace -r -a "\n" "\n\n"               # separate paragraphs
  | str replace -r -a '(##.*) {#.*}' '$1'       # strip subheading tags
  | str replace -r -a ' {2,}' ' '               # remove double-plus spaces
  | lines | str trim --right | to text          # remove trailing whitespaces
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
