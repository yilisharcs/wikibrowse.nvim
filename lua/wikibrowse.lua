local M = {}

M.setup = function()
  -- vim.api.nvim_create_user_command(
  --   'WikiBrowse',
  --   'lua WikiBrowse()',
  --   {}
  -- )
end

local function create_floating_window(opts)
  opts = opts or {}
  local width = opts.width or math.floor(vim.o.columns * 0.8)
  local height = opts.height or math.floor(vim.o.lines * 0.8)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)
  local buf = vim.api.nvim_create_buf(false, true)

  local win_config = {
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    style = 'minimal',
    border = 'rounded',
  }
  local win = vim.api.nvim_open_win(buf, true, win_config)

  return { buf = buf, win = win }
end

M.wiki_search = function()
  local float = create_floating_window()

  local on_exit = function(obj)
    vim.schedule(function()
      if obj.code == 0 and obj.stdout then
        local lines = vim.split(obj.stdout, '\n', { trimempty = true })
        vim.api.nvim_buf_set_lines(float.buf, 0, -1, false, lines)
      else
        local error_msg = obj.stderr or ("Exited with code: " .. obj.code)
        vim.notify(error_msg, vim.log.levels.ERROR)
      end
    end)
  end

  vim.system({
    'nu',
    '-c',
    'ls **/*',
    -- 'http get https://en.wikipedia.org/wiki/Printing_press',
  }, { text = true }, on_exit)

  -- local current_slide = 1
  -- vim.keymap.set('n', 'n', function()
  --   current_slide = math.min(current_slide + 1, #parsed.slides)
  --   vim.api.nvim_buf_set_lines(float.buf, 0, -1, false, parsed.slides[current_slide])
  -- end, { buffer = float.buf })
  -- vim.keymap.set('n', 'p', function()
  --   current_slide = math.max(current_slide - 1, 1)
  --   vim.api.nvim_buf_set_lines(float.buf, 0, -1, false, parsed.slides[current_slide])
  -- end, { buffer = float.buf })
  vim.keymap.set('n', 'q', function()
    vim.api.nvim_win_close(float.win, true)
  end, { buffer = float.buf })
end

-- M.WikiSearch()

return M
