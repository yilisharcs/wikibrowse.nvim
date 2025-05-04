local M = {}

M.setup = function()

end

vim.api.nvim_create_user_command(
  'WikiBrowse',
  'lua WikiBrowse()',
  {}
)

function WikiBrowse()
  local bufnr = 0

  local on_exit = function(obj)
    vim.schedule(function()
      if obj.code == 0 and obj.stdout then
        local lines = vim.split(obj.stdout, '\n', { trimempty = true })
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
      else
        local error_msg = obj.stderr or ("Exited with code: " .. obj.code)
        vim.notify(error_msg, vim.log.levels.ERROR)
      end
    end)
  end

  vim.system({
    'nu',
    '-c',
    'http get https://en.wikipedia.org/wiki/Printing_press',
  }, { text = true }, on_exit)
end

return M
