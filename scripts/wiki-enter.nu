#!/usr/bin/env nu

def parser [] {
  $in
  | str replace -r 'title: (.*)' "# $1\n"     # remove title tag (needs \n to counter 4th cmd)
  | str replace -r 'extract: ' ''             # remove extract tag
  | str replace -r -a "([^\n])\n" '$1 '       # join paragraphs into single lines
  | str replace -r -a "\n" "\n\n"             # separate paragraphs
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
