#!/usr/bin/env nu

def main [lang: string, pageids: string] {
  let url = ([
    'https://',
    $lang,
    '.wikipedia.org/w/api.php?action=query',
    '&format=json',
    '&prop=extracts',
    '&explaintext',
    '&exsectionformat=wiki',

    # '&prop=revisions',
    # # '&prop=revisions|links',
    # # '&prop=revisions|links|extlinks|images|imageinfo|iwlinks|videoinfo',
    # '&rvprop=content',
    # '&rvslots=main',
    '&pageids=',
    $pageids
  ] | str join)

  http get $url
  | flatten
  | get pages
  | flatten
  | get extract
  # | select pageid ns title revisions links extlinks images iwlinks
  # | reject pageid ns title revisions
  # | reject pageid ns revisions.slots.main.*
  # | get query
  # | flatten
  # | flatten
  # | select title revisions.slots.main.*
  # | rename title extract
  # | to text
  # | tr -d '\000-\011\013\014\016-\037'
}
