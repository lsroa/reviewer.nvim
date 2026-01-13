local M = {}

M.get_position = function()
  local current_line = vim.api.nvim_win_get_cursor(0)[1]
  local file = vim.fn.expand('%:.')
  return file, current_line
end

M.keys = function(obj)
  local keys = {}
  for key, _ in pairs(obj) do
    table.insert(keys, key)
  end
  return keys
end

--- @param width integer | nil
--- @param height integer | nil
--- @param cb fun(text: string) | nil
M.open_text_box = function(width, height, cb)
  width = width or 40
  height = height or 5
  cb = cb or function(content) print(content) end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')
  vim.cmd('startinsert')

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'cursor',
    row = 1,
    col = 0,
    width = width,
    height = height,
    style = 'minimal',
    border = 'rounded'
  })

  vim.api.nvim_win_set_option(win, 'wrap', true)
  vim.api.nvim_win_set_option(win, 'linebreak', true)
  vim.api.nvim_win_set_option(win, 'breakindent', true)

  local function submit_text()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local content = table.concat(lines, "\n")

    cb(content)

    vim.api.nvim_win_close(win, true)
  end

  vim.keymap.set('n', '<CR>', submit_text, { buffer = buf, desc = "Submit text" })
  vim.keymap.set('n', 'q', function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
end


return M
