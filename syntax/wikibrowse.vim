if !exists("b:current_syntax") || b:current_syntax != "markdown"
  finish
endif

syn match WikiBrowseURL / — https.*/ conceal " cchar=&
hi def WikiBrowseURL guifg=NONE guibg=NONE
