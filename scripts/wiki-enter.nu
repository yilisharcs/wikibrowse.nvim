#!/usr/bin/env nu

let api = ([
  'https://en.wikipedia.org/w/api.php?action=query',
  '&format=json',
  '&prop=extracts',
  '&explaintext',
] | str join)

def main [x: string] {
  let query = ($x | url encode)

  http get $"($api)&pageids=($query)"
  | flatten
  | get pages
  | flatten
  | get extract
  | to text
  | tr -d '\000-\011\013\014\016-\037'
}
