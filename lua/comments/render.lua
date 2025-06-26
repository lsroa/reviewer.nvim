local M = {}

--- @param comment Comment
--- @param max_width integer
--- @return string[], integer, integer
local function render_comment(comment, max_width)
  local block = {}
  local width = 0
  local lines_with_extra_line = 0
  local extra_space_for_extra_line = 0

  table.insert(block, ' **@' .. comment.author .. '**')

  for comment_line in comment.body:gmatch('([^\n]*)\n?') do
    if #comment_line > max_width then
      lines_with_extra_line = lines_with_extra_line + 1
      extra_space_for_extra_line = 1
      -- TODO add an extra space at 120 of the coomment
    end
    table.insert(block, ' ' .. comment_line .. ' ')
    width = math.max(width, #comment_line + 2 + extra_space_for_extra_line)
  end

  width = math.max(width, #comment.author + 6)
  local height = #block + lines_with_extra_line

  return block, width, height
end

--- @param thread Thread
--- @param max_width integer
--- @return string[], integer, integer
function M.render_thread(thread, max_width)
  local t = {}
  local total_height = 0
  local width = 0

  for _, comment in ipairs(thread.comments) do
    local block, comment_width, comment_height = render_comment(comment, max_width)
    total_height = total_height + comment_height
    width = math.max(width, comment_width)
    table.insert(t, block)
  end

  return t, math.min(max_width, width), total_height
end

return M
