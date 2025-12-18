local M = {}

M.get_position = function()
  local current_line = vim.api.nvim_win_get_cursor(0)[1]
  local file = vim.fn.expand('%:.')
  return file, current_line
end

return M
