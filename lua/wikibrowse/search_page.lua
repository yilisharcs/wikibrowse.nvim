local M = {}

M.get_article_index = function()
  local articles = {}

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  for k, v in ipairs(lines) do
    if v:match('^@') then
      table.insert(articles, k)
    end
  end

  return articles
end

M.cursor_jump = function()
  local index = M.get_article_index()
  P(index)

  local cursor = vim.api.nvim_win_get_cursor(0)[1]
  local line_count = vim.api.nvim_buf_line_count(0)

  -- local direction = 0
  -- if key == 'j' then
  --   direction = cursor + 1
  -- elseif key == 'k' then
  --   direction = cursor - 1
  -- end

  -- for i = direction, line_count do
  --   local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
  --   if line:match('^@') then
  --     P(i, line)
  --     break
  --   end
  -- end
end



local get_index_list = function()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
end

local jump = function(key)
  local cursor = vim.api.nvim_win_get_cursor(0)[1]
  local line_count = vim.api.nvim_buf_line_count(0)

  local direction = 0
  if key == 'j' then
    direction = cursor + 1
  elseif key == 'k' then
    direction = cursor - 1
  end

  for i = direction, line_count do
    local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
    if line:match('^@') then
      P(i, line)
      break
    end
  end
end

-- vim.keymap.set('n', 'j', function() jump('j') end, { buffer = true })
--
-- vim.keymap.set('n', 'k', function() jump('k') end, { buffer = true })


vim.keymap.set('n', '<leader>c', function() M.cursor_jump() end, {})

return M
