local M = {}

M.Comment = {}

--- @class Comment
--- @field url string
--- @field body string
--- @field author string

--- @param url string
--- @param body string
--- @param author string
--- @return Comment
function M.Comment.new(url, body, author)
  return {
    url = url,
    body = body,
    author = author,
  }
end

M.Thread = {}

--- @class Thread
--- @field comments Comment[]
--- @field isResolved boolean
--- @field originalLine integer
--- @field path string

--- @param comments Comment[]
--- @param isResolved boolean
--- @param originalLine integer
--- @param path string
--- @return Thread
function M.Thread.new(comments, isResolved, originalLine, path)
  return {
    comments = comments,
    isResolved = isResolved,
    originalLine = originalLine,
    path = path,
  }
end

--- @alias Hunk {old_start: integer, old_count: integer, new_start: integer, new_count: integer}

return M
