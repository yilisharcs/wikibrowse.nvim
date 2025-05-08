runtime syntax/markdown.vim

syn match markdownUrl "\S\+" nextgroup=markdownUrlTitle skipwhite contained conceal
syn region markdownLink matchgroup=markdownLinkDelimiter start="(" end=")" contains=markdownUrl keepend contained concealends

hi! def link markdownLinkText Constant
