# wikibrowse.nvim

Browse wikipedia articles from the comfort of your favorite editor.

# Requirements

`nushell`

# Usage

```vim
:Wikibrowse <args>
```

# TODO

- [x] un-hardcode pizza as query
- [x] fix the script path
- [x] use non-floating buffer for article
- [x] implement get article
- [ ] config opts and keymaps (lang opts)
- [ ] change article language
- [ ] refresh window rather than close it if a query is made while the window is open
- [ ] handle disambiguation links (contain "(disambiguation)" in fullurl)
- [ ] implement link follows
- [x] pass json title object to wiki_enter to name the window
- [ ] prepend en.wikipedia.org/wiki/ to all File:foobar.extension to access the image
