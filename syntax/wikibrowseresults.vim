runtime! syntax/markdown.vim

syn match WikibrowseEntry /^\zs##\s.*\ze\s@page:\S*$/
syn match WikibrowsePageTitle /@page:\S*/ conceal

hi default link WikibrowseEntry DiffAdd
