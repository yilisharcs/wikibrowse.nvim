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
  local width = opts.width or math.floor(vim.o.columns * 0.9)
  local height = opts.height or math.floor(vim.o.lines * 0.8)

  -- Calculate the position to center the window
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  -- Create a scratch buffer
  local buf = nil
  if vim.api.nvim_buf_is_valid(opts.buf) then
    buf = opts.buf
  else
    buf = vim.api.nvim_create_buf(false, true)
  end

  local win_config = {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = ' WikiBrowse ',
    title_pos = 'center',
  }

  local win = vim.api.nvim_open_win(buf, true, win_config)

  return { buf = buf, win = win }
end

local state = {
  floating = {
    buf = -1,
    win = -1,
  }
}

M.wiki_open = function()
  if not vim.api.nvim_win_is_valid(state.floating.win) then
    state.floating = create_floating_window({ buf = state.floating.buf })

    -- Float win options
    vim.api.nvim_set_option_value('swapfile', false, { buf = state.floating.buf })
    vim.api.nvim_set_option_value('filetype', 'markdown', { buf = state.floating.buf })
    vim.api.nvim_set_option_value('wrap', true, { win = state.floating.win })

    local on_exit = function(obj)
      vim.schedule(function()
        if obj.code == 0 and obj.stdout then
          local lines = vim.split(obj.stdout, '\n', { trimempty = true })
          vim.api.nvim_buf_set_lines(state.floating.buf, 0, -1, false, lines)
        else
          local error_msg = obj.stderr or ("Exited with code: " .. obj.code)
          vim.notify(error_msg, vim.log.levels.ERROR)
        end
      end)
    end

    local nu_query = {
      'ls', '**/*'
      -- 'http get https://en.wikipedia.org/wiki/Printing_press',
    }

    vim.system({
      'nu',
      '-c',
      table.concat(nu_query, ' '),
    }, { text = true }, on_exit)
  else
    vim.api.nvim_win_hide(state.floating.win)
  end

  -- local current_slide = 1
  -- vim.keymap.set('n', 'n', function()
  --   current_slide = math.min(current_slide + 1, #parsed.slides)
  --   vim.api.nvim_buf_set_lines(state.floating.buf, 0, -1, false, parsed.slides[current_slide])
  -- end, { buffer = state.floating.buf })
  -- vim.keymap.set('n', 'p', function()
  --   current_slide = math.max(current_slide - 1, 1)
  --   vim.api.nvim_buf_set_lines(state.floating.buf, 0, -1, false, parsed.slides[current_slide])
  -- end, { buffer = state.floating.buf })
  vim.keymap.set('n', 'q', function()
    vim.api.nvim_win_close(state.floating.win, true)
  end, { buffer = state.floating.buf })
end

vim.keymap.set({ 'n', 't' }, '<leader>y', function()
  require('wikibrowse').wiki_open()
end)

return M
