# wikipedia.nvim

Browse wikipedia articles from the comfort of your favorite editor.

# Usage

```lua
require('wikibrowse').wiki_open()
```

# TODO

- [ ] use command below to name the window after the title of the article

```lua
vim.api.nvim_create_autocmd("BufNew", {
  pattern = "*",
  callback = function()
    if vim.bo.buftype == "nofile" then
      vim.api.nvim_buf_set_name(0, "Scratch")
    end
  end,
})```
