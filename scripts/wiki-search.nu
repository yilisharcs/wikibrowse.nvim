#!/usr/bin/env nu

let api = ([
  'https://en.wikipedia.org/w/api.php?action=query',
  '&format=json',
  '&prop=extracts|info',
  '&generator=search',
  '&inprop=url',
  '&exsentences=1',
  '&exlimit=max',
  '&exintro',
  '&explaintext',
  '&redirects',
] | str join)

# def main [x: string] {
def main [] {
  let x = 'pizza'

  let query = ($x | url encode)

  http get $"($api)&gsrsearch=($query)"
  | flatten
  | get pages
  # | sort-by
  # | to json
}
