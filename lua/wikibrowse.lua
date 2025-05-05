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
    vim.api.nvim_set_option_value('cursorline', true, { win = state.floating.win })
    vim.api.nvim_set_option_value('winhighlight', 'CursorLine:Todo', { win = state.floating.win })

    vim.api.nvim_set_option_value('filetype', 'markdown', { buf = state.floating.buf })
    vim.api.nvim_set_option_value('modifiable', false, { buf = state.floating.buf })
    vim.api.nvim_set_option_value('swapfile', false, { buf = state.floating.buf })
    vim.api.nvim_set_option_value('wrap', true, { win = state.floating.win })

    local on_exit = function(obj)
      vim.schedule(function()
        if obj.code == 0 and obj.stdout then
          local decoded_json = vim.json.decode(obj.stdout)

          if decoded_json then
            local lines = {}
            local result_lines = {} -- Keep track of lines with search results
            table.insert(lines, '# Search Results:')
            table.insert(lines, '')
            for _, item in ipairs(decoded_json) do
              if item and item.title and item.extract and item.fullurl then
                -- table.insert(lines, '**[' .. item.title .. '](' .. item.fullurl .. ')**')
                -- table.insert(lines, '## **' .. item.title .. '** — ' .. item.fullurl)
                table.insert(lines, '## ' .. item.title)
                table.insert(lines, item.extract .. '...')
                table.insert(lines, '')
                table.insert(result_lines, #lines - 2)
              end
            end

            -- Set modifiable to edit buffer contents, then reset nomodifiable
            vim.api.nvim_set_option_value('modifiable', true, { buf = state.floating.buf })
            vim.api.nvim_buf_set_lines(state.floating.buf, 0, -1, false, lines)
            vim.api.nvim_set_option_value('modifiable', false, { buf = state.floating.buf })

            vim.keymap.set('n', 'j', function()
              local current_line = vim.api.nvim_win_get_cursor(0)[1]
              local next_result_line = nil
              for _, line_nr in ipairs(result_lines) do
                if line_nr > current_line then
                  next_result_line = line_nr
                  break
                end
              end
              if next_result_line then
                vim.api.nvim_win_set_cursor(0, { next_result_line, 0 })
              end
            end, { buffer = state.floating.buf, silent = true })

            vim.keymap.set('n', 'k', function()
              local current_line = vim.api.nvim_win_get_cursor(0)[1]
              local prev_result_line = nil
              for i = #result_lines, 1, -1 do
                local line_nr = result_lines[i]
                if line_nr < current_line then
                  prev_result_line = line_nr
                  break
                end
              end
              if prev_result_line then
                vim.api.nvim_win_set_cursor(0, { prev_result_line, 0 })
              end
            end, { buffer = state.floating.buf, silent = true })

            vim.keymap.set('n', 'q', function()
              vim.api.nvim_win_close(state.floating.win, true)
            end, { buffer = state.floating.buf })
          else
            vim.notify('Failed to decode JSON', vim.log.levels.ERROR)
          end
        else
          local error_msg = obj.stderr or ('Exited with code: ' .. obj.code)
          vim.notify(error_msg, vim.log.levels.ERROR)
        end
      end)
    end

    vim.system({
      -- TODO: surely there is a better way to get the script path?
      vim.env.HOME .. '/projects/nvim/wikibrowse.nvim/scripts/wiki-search.nu',
      'pizza',
    }, { text = true }, on_exit)
  else
    vim.api.nvim_win_hide(state.floating.win)
  end
end

vim.keymap.set('n', '<leader>y', function()
  require('wikibrowse').wiki_open()
end)

return M
