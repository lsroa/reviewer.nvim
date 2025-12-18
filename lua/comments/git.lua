local M = {}

local store = require('comments.store')

M.fetch_files = function()
  vim.system({ "git", "diff", "origin/master...HEAD", "--name-only" }, { text = true }, function(out)
    if out.code ~= 0 then
      return
    end
    local files = vim.split(out.stdout, "\n", { trimempty = true })
    store.set_files(files)
  end)
end

return M
