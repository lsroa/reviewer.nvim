local M = {}

local store = require("comments.store")
local fzf = require("fzf-lua")
local utils = require("fzf-lua.utils")
local icons = require("nvim-web-devicons")


M.list_comments = function()
  --- @type {text: string, file: string, line: integer, comment: Comment}[]
  local comments = {}
  for file, thread_by_line in pairs(store.get_threads()) do
    for _, thread in pairs(thread_by_line) do
      if not thread.isResolved then
        for _, comment in ipairs(thread.comments) do
          local preview = comment.body:gsub("\n", " "):sub(1, 60)
          if #comment.body > 60 then
            preview = preview .. "..."
          end

          local ext = string.gsub(file, "^.*%.", "")
          local icon, color = icons.get_icon_color(file, ext)
          local colored_icon = utils.ansi_from_rgb(color, icon)

          local entry = string.format("%s %s:%d %s - %s",
            colored_icon,
            file,
            thread.originalLine,
            comment.author,
            preview
          )
          table.insert(comments, {
            text = entry,
            file = file,
            line = thread.originalLine,
            comment = comment,
          })
        end
      end
    end
  end


  fzf.fzf_exec(vim.fn.map(comments, function(_, comment)
    return comment.text
  end), {
    actions = {
      ["default"] = function(selected, _)
        if #selected == 0 then
          return
        end
        for _, entry in ipairs(comments) do
          if selected[1]:find(entry.file) then
            vim.cmd(string.format("edit +%d %s", entry.line, entry.file))
            return
          end
        end
      end,
      ["ctrl-q"] = function(_, _)
        local qf_items = {}
        for _, entry in ipairs(comments) do
          table.insert(qf_items, {
            filename = entry.file,
            lnum = entry.line,
            text = string.format("%s: %s", entry.comment.author, entry.comment.body:gsub("\r", ""):sub(1, 100)),
          })
        end
        vim.fn.setqflist(qf_items)
        vim.cmd("copen")
      end,
    },
  })
end

M.list_pr_files = function()
  --- @type { filename: string, picker_text: string, lnum: integer}[]
  local files = {}
  for _, file in pairs(store.get_files()) do
    local ext = vim.fn.fnamemodify(file, ":e")
    local tail = vim.fn.fnamemodify(file, ":t")
    local icon, color = icons.get_icon_color(file, ext)
    local colored_icon = utils.ansi_from_rgb(color, icon)

    table.insert(files, {
      filename = file,
      picker_text = string.format("%s %s %s", colored_icon, utils.ansi_codes.blue(tail), file),
      lnum = 1
    })
  end

  fzf.fzf_exec(vim.fn.map(files, function(_, entry) return entry.picker_text end), {
    actions = {
      ["default"] = function(selected, _)
        if #selected == 0 then
          return
        end
        for _, entry in ipairs(files) do
          if selected[1]:find(entry.filename) then
            vim.cmd("e " .. entry.filename)
            return
          end
        end
      end,
      ["ctrl-v"] = function(selected, _)
        for _, entry in ipairs(files) do
          if entry.filename == selected[1] then
            vim.cmd("vs " .. entry.filename)
            return
          end
        end
      end,
      ["ctrl-q"] = function()
        vim.fn.setqflist(files)
        vim.cmd("copen")
      end,
    }
  })
end

return M
