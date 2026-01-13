local M = {}

local store = require('comments.store')

local function parse_diff(diff)
  --- @type table<path, Hunk[]>
  local hunks = {}
  local file

  for line in diff:gmatch("[^\n]+") do
    local f = line:match("^diff %-%-git a/.+ b/(.+)")
    if f then
      file = f
      hunks[file] = hunks[file] or {}
    end

    local old_start, old_count, new_start, new_count =
        line:match("^@@ %-(%d+),?(%d*) %+(%d+),?(%d*) @@")

    if new_start and file then
      table.insert(hunks[file], {
        old_start = tonumber(old_start),
        old_count = tonumber(old_count) ~= 0 and tonumber(old_count) or 1,
        new_start = tonumber(new_start),
        new_count = tonumber(new_count) ~= 0 and tonumber(new_count) or 1,
      })
    end
  end

  return hunks
end


M.fetch_files = function()
  vim.system({ "git", "diff", "origin/master...HEAD", "--unified=0" }, { text = true }, function(out)
    if out.code ~= 0 then
      return
    end

    local hunks = parse_diff(out.stdout)
    store.set_hunks(hunks)
  end)
end

return M
