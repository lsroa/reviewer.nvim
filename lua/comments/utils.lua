local M = {}
local function file_exist()
  local path = vim.api.nvim_buf_get_name(0):gsub('^' .. vim.fn.getcwd() .. '/', '')
  if parsed_comments[path] == nil then
    return
  end
end

local function place_signs(bufnr, lines)
  for line in pairs(lines) do
    vim.fn.sign_place(0, 'Comments', 'GithubComment', bufnr, { lnum = line, priority = 100 })
  end
end

M.get_position = function()
  local current_line = vim.api.nvim_win_get_cursor(0)[1]
  local file = vim.api.nvim_buf_get_name(0):gsub('^' .. vim.fn.getcwd() .. '/', '')
  return file, current_line
end

return M
