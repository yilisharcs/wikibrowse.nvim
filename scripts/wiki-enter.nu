#!/usr/bin/env nu

let api = ([
  'https://en.wikipedia.org/w/api.php?action=query',
  '&format=json',
  '&prop=extracts',
  '&explaintext',
  '&exsectionformat=wiki'

  # '&prop=revisions',
  # # '&prop=revisions|links',
  # # '&prop=revisions|links|extlinks|images|imageinfo|iwlinks|videoinfo',
  # '&rvprop=content',
  # '&rvslots=main'
] | str join)

def main [x: string] {
  let query = ($x | url encode)

  http get $"($api)&pageids=($query)"
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
  | to text
  | tr -d '\000-\011\013\014\016-\037'
}
