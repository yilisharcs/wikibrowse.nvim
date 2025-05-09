local win = require('wikibrowse.window')
local plugin = vim.api.nvim__get_runtime({ 'lua/wikibrowse' }, false, {})[1]
local root = vim.fn.fnamemodify(plugin, ":h:h")
local sh_search = root .. '/scripts/wiki-search.nu'
local sh_enter = root .. '/scripts/wiki-to-md.nu'

-- TODO: expose this as a config option
local lang = 'en'

local M = {}

M.setup = function()
  if vim.fn.executable('nu') == 0 then
    vim.notify('nushell not found.', vim.log.levels.ERROR)
    return
  end
  if vim.fn.executable('pandoc') == 0 then
    vim.notify('pandoc not found.', vim.log.levels.ERROR)
    return
  end

  vim.api.nvim_create_user_command('WikiBrowse', function(opts)
    M.wiki_search(opts.args)
  end, { nargs = '+' })
end

local state = {
  floating = {
    buf = -1,
    win = -1,
  }
}

M.wiki_search = function(query)
  if not vim.api.nvim_win_is_valid(state.floating.win) then
    state.floating = win.create_floating_window({ buf = state.floating.buf })

    vim.api.nvim_set_option_value('filetype', 'wikibrowser', { buf = state.floating.buf })

    local on_exit = function(obj)
      vim.schedule(function()
        if obj.code == 0 and obj.stdout then
          local json_results = vim.json.decode(obj.stdout)

          if json_results then
            local lines = {}
            table.insert(lines, '# Search Results:')
            table.insert(lines, '')
            for _, item in ipairs(json_results) do
              if item and item.title and item.extract and item.fullurl then
                table.insert(lines, '@ ' .. item.title .. ' #pageid:' .. item.pageid)
                table.insert(lines, item.extract .. '...')
                table.insert(lines, '')
              end
            end

            -- Set modifiable to edit buffer contents, then reset nomodifiable
            vim.api.nvim_set_option_value('modifiable', true, { buf = state.floating.buf })
            vim.api.nvim_buf_set_lines(state.floating.buf, 0, -1, false, lines)
            vim.api.nvim_set_option_value('modifiable', false, { buf = state.floating.buf })

            vim.api.nvim_win_set_cursor(0, { 3, 0 })
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
      sh_search,
      lang,
      query,
    }, { text = true }, on_exit)
  else
    vim.api.nvim_win_hide(state.floating.win)
  end
end

M.wiki_enter = function()
  local current_line = vim.api.nvim_win_get_cursor(0)[1]
  local index = vim.api.nvim_buf_get_lines(state.floating.buf, current_line - 1, current_line, false)[1]

  vim.api.nvim_win_close(0, true)
  local on_content_exit = function(obj)
    vim.schedule(function()
      if obj.code == 0 and obj.stdout then
        -- local json_article = vim.json.decode(obj.stdout)
        --
        -- if json_article then
        -- local title = json_article[1].title
        -- local buf = win.create_article_buffer(title)

        local content_lines = vim.split(obj.stdout, '\n', { trimempty = true })
        local title = content_lines[1]:sub(3, -1) -- "# $title" notation
        local buf = win.create_article_buffer(title)

        -- local content_lines = vim.split(json_article[1].extract, '\n', { trimempty = true })
        vim.api.nvim_set_option_value('modifiable', true, { buf = buf })
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, content_lines)
        -- vim.api.nvim_buf_set_lines(buf, 0, 0, false, { title })
        -- vim.api.nvim_buf_set_lines(buf, 1, 1, false, { '' })
        vim.api.nvim_set_option_value('modifiable', false, { buf = buf })

        vim.api.nvim_set_option_value('filetype', 'wikiarticle', { buf = buf })
        -- vim.api.nvim_set_option_value('filetype', 'markdown', { buf = buf })
        -- end
      else
        local error_msg = obj.stderr or ('Exited with code: ' .. obj.code)
        vim.notify(error_msg, vim.log.levels.ERROR)
      end
    end)
  end

  local pageid = string.match(index, 'pageid:(%d+)')
  if string.match(index, 'pageid:(%d+)') then
    vim.system({
      sh_enter,
      '--lang',
      lang,
      pageid,
    }, { text = true }, on_content_exit)
  else
    vim.notify('No Page ID found on this line.', vim.log.levels.WARN)
  end
end

vim.keymap.set('n', '<CR>', function()
  require('wikibrowse').wiki_enter()
end, { buffer = state.floating.buf })

return M
