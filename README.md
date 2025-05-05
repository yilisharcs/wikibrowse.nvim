# wikibrowse.nvim

Browse wikipedia articles from the comfort of your favorite editor.

# Requirements

`nushell`

# Usage

```lua
require('wikibrowse').wiki_open()

require('wikibrowse').wiki_get()
```

Currently is mapped by default to `<leader>y` and `<CR>`.

# TODO

- [ ] un-hardcode pizza as query
- [x] fix the script path
- [ ] use non-floating buffers
- [x] implement get article
- [ ] config opts and keymaps
