#!/usr/bin/env nu

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
  | get extract
  | to text
  | pandoc --from mediawiki --to markdown_phpextra
  | tr -d '\000-\011\013\014\016-\037' # Why is this here
}
