syn match WikiBrowseEntry /^\zs@\s.*\ze\s#pageid:\d\+$/
syn match WikiBrowsePageId /#pageid:\d*/ conceal

hi WikiBrowseEntry guifg=Black guibg=#e0d561 gui=bold
