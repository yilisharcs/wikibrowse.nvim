local M = {}

M.get_article_index = function()
  local articles_prev = {}
  local articles_next = {}

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  for k, v in ipairs(lines) do
    -- Articles are currently marked with a preceding "@ "
    -- Consider changing this later to make it more robust
    if v:match('^@') then
      table.insert(articles_next, k)
    end
  end

  for i = #articles_next, 1, -1 do
    table.insert(articles_prev, articles_next[i])
  end

  return { prev = articles_prev, next = articles_next }
end

M.cursor_jump = function(key)
  local cursor = vim.api.nvim_win_get_cursor(0)[1] -- get line, ignore row
  local index = M.get_article_index()
  local prev, next = index.prev, index.next

  if key == 'k' then
    for _, i in ipairs(prev) do
      if i < cursor then
        vim.api.nvim_win_set_cursor(0, { i, 0 })
        break
      end
    end
  elseif key == 'j' then
    for _, i in ipairs(next) do
      if i > cursor then
        vim.api.nvim_win_set_cursor(0, { i, 0 })
        break
      end
    end
  end
end

return M
