#!/usr/bin/env nu

def parser [] {
  $in
  # strip title tag (needs \n to counter 3rd cmd)
  | str replace -r 'title: (.*)' "# $1\n"
  # strip extract tag
  | str replace -r 'extract: ' ''
  # join paragraphs into single lines (don't match lists)
  | str replace -r -a "([^\n])(?!\n-)\n" '$1 '
  # separate paragraphs
  | str replace -r -a "\n" "\n\n"
  # strip subheading tags
  | str replace -r -a '(##.*) {#.*}' '$1'
  # remove double-plus spaces
  | str replace -r -a ' {2,}' ' '
  # fix spaced commas
  | str replace -r -a ' ,' ','
  # parse images
  | str replace -r -a '<figure>.*src="(\S*)"[^>]*?title="([^"]*?)".*' '![$2](File:$1)'
  # parse image tables with black magic PART 1
  | str replace -r -a '<File:([^>]+)>([^\\]*)\\\|([^<]*?)' "$3\n<parse$1$2>"
  # parse image tables with black magic PART 2
  ## FIXME: I only need this second regex because the first one somehow eats the last tag
  ## NOTE: This also makes an extra newline
  | str replace -r -a '<parse([^>]+)>(.*)' "    $2 <$1>"
  | lines
  # remove trailing whitespaces
  | str trim --right
  # |
  | to text
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
