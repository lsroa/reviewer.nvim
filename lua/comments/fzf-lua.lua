local M = {}

local store = require("comments.store")
local fzf = require("fzf-lua")

M.list_comments = function()
  local comments = {}
  for file, thread_by_line in pairs(store.get_threads()) do
    table.insert(comments, file)
  end

  fzf.fzf_exec(comments, {
    title = "> Comments",
    actions = {
      ["default"] = function(file)
        vim.cmd("e " .. file[1])
      end
    }
  })
end

return M
