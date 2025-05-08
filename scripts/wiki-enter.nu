#!/usr/bin/env nu

def parser [] {
  $in
  | str replace -r 'title: (.*)' "# $1\n"                           # strip title tag (needs \n to counter 3rd cmd)
  | str replace -r 'extract: ' ''                                   # strip extract tag
  | str replace -r -a "([^\n])(?!\n-)\n" '$1 '                      # join paragraphs into single lines (don't match lists)
  | str replace -r -a "\n" "\n\n"                                   # separate paragraphs
  | str replace -r -a '(##.*) {#.*}' '$1'                           # strip subheading tags
  | str replace -r -a ' {2,}' ' '                                   # remove double-plus spaces
  | str replace -r -a ' ,' ','                                      # fix spaced commas
  | lines | str trim --right | to text                              # remove trailing whitespaces
  # | str replace -r -a '(?<=<figure>)(.*)<em>([^<]*)</em>' '$1*$2*'  # emphasis with markdown tags
  | str replace -r -a '<figure>.*src="(\S*)"[^>]*?title="([^"]*?)".*' '![$2](https://en.wikipedia.org/wiki/File:$1)'
  # | str replace -r -a '<figure>.*src="(\S*)".*<figcaption>(.*)</figcaption>.*' '![$2](https://en.wikipedia.org/wiki/File:$1)'
  | tr -d '\000-\011\013\014\016-\037'          # Why is this here
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
