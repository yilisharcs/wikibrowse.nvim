#!/usr/bin/env nu

def main [lang: string, ...str: string] {
  let args = ($str | str join ' ')
  let query = ($args | url encode)

  let url = ([
    'https://',
    $lang,
    '.wikipedia.org/w/api.php?action=query',
    '&format=json',
    '&prop=extracts|info|langlinks',
    '&generator=search',
    '&inprop=url',
    '&exsentences=1',
    '&exlimit=max',
    '&exintro',
    '&explaintext',
    '&redirects',
    '&gsrsearch=',
    $query
  ] | str join)

  http get $url
  | flatten
  | get pages
  | values
  | flatten
  | sort-by index
  | select -i pageid title index extract fullurl langlinks
  | to json
}
