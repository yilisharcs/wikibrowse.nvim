syn match WikiBrowseEntry /^\zs@\s.*\ze#pageid:\d\+$/
syn match WikiBrowsePageId /#pageid:\d*/ conceal

hi WikiBrowseEntry guifg=#e0d561 gui=bold
