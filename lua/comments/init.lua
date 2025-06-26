local M = {}

local store = require('comments.store')
local render = require('comments.render')
local utils = require('comments.utils')
local telescope_utils = require("comments.telescope")
local gh = require('comments.gh')


M.jump = function(direction)
  local file, cursor = utils.get_position()

  local threads = store.get_threads_by_file(file)
  if not threads then
    return
  end
  local lines = {}
  for _, thread in pairs(threads) do
    if thread.originalLine ~= cursor then
      table.insert(lines, thread.originalLine)
    end
  end

  table.insert(lines, cursor)
  table.sort(lines)


  local prev_line = nil
  for i = 1, #lines do
    if cursor == lines[i] then
      if lines[i + 1 * direction] ~= nil then
        prev_line = lines[i + 1 * direction]
      elseif cursor == lines[#lines] then
        prev_line = lines[1]
      else
        prev_line = lines[#lines]
      end
    end
  end

  vim.api.nvim_win_set_cursor(0, { prev_line, 0 })
end

local place_signs = function()
  local file, _ = utils.get_position()
  local threads = store.get_threads_by_file(file)
  if threads then
    for _, thread in pairs(threads) do
      vim.fn.sign_place(0,
        'Comments',
        'GithubComment',
        vim.api.nvim_get_current_buf(),
        { lnum = thread.originalLine, priority = 100 })
    end
  end
end

M.open_comment = function()
  local file, current_line = utils.get_position()

  local threads = store.get_threads_by_file(file)

  if not threads then
    return
  end

  for _, thread in pairs(threads) do
    if thread.originalLine == current_line then
      for _, comment in ipairs(thread.comments) do
        local cmd = 'xdg-open'
        if vim.fn.has('mac') == 1 then
          cmd = 'open'
        end
        os.execute(cmd .. ' ' .. comment.url)
        return
      end
    end
  end
end

local MAX_COL = 120

M.show_comment = function()
  local file, current_line = utils.get_position()

  local thread = store.get_thread(file, current_line)

  if thread == nil then
    return
  end

  local t, width, height = render.render_thread(thread, MAX_COL)

  vim.lsp.util.open_floating_preview(vim.tbl_flatten(t), 'markdown',
    {
      width = width,
      height = height - 1,
      border = 'rounded',
      x_offset = 10,
      relative = 'cursor'
    })
end


M.setup = function()
  -- Fecth data
  gh.fetch_comments()
  gh.fetch_files()

  -- Register signs
  vim.fn.sign_define('GithubComment', { text = '💬' })
  vim.fn.sign_define('GithubResolvedComment', { text = '✅' })


  -- Register autocommands
  vim.api.nvim_create_autocmd('User', {
    pattern = 'CommentsLoaded',
    callback = place_signs,
  })
  vim.api.nvim_create_autocmd({ 'BufWinEnter' }, {
    callback = function()
      place_signs()
    end
  })

  -- Define commands
  vim.api.nvim_create_user_command('ShowComment', M.show_comment, {})
  vim.api.nvim_create_user_command('GHNext', function() M.jump(1) end, { bar = true })
  vim.api.nvim_create_user_command('GHPrev', function() M.jump(-1) end, { bar = true })
  vim.api.nvim_create_user_command('OpenComment', M.open_comment, {})
  vim.api.nvim_create_user_command('GHComments', telescope_utils.list_comments, {})
  vim.api.nvim_create_user_command('GHFiles', telescope_utils.list_pr_files, {})
  vim.api.nvim_create_user_command('GHThreads', function()
    local file = utils.get_position()
    vim.print(store.get_threads_by_file(file))
  end, {})
end

return M
