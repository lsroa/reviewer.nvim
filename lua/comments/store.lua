M = {}

--- @type string[]
local files = {}

--- @alias path string
--- @alias line string
--- @type table<path,{[line]: Thread}>
local threads = {}

--- @param new_files string[];
function M.set_files(new_files)
  files = {}
  for _, file in ipairs(new_files) do
    vim.schedule(function()
      if vim.fn.filereadable(file) == 1 then
        table.insert(files, file)
      end
    end)
  end
end

--- @return string[]
function M.get_files()
  return files
end

--- @return table<path,{[line]: Thread}>
function M.get_threads()
  return threads
end

--- @param new_threads Thread[]
function M.set_threads(new_threads)
  threads = {}
  for _, thread in ipairs(new_threads) do
    if vim.fn.filereadable(thread.path) == 1 then
      table.insert(threads, thread)
    end
  end
end

--- @param file string
--- @return Thread[] | nil
function M.get_threads_by_file(file)
  if not threads[file] then
    return
  end
  local thread_list = {}
  for _, thread in pairs(threads[file]) do
    if not thread.isResolved then
      table.insert(thread_list, thread)
    end
  end
  return thread_list
end

--- @param file path
--- @param current_line line
--- @return Thread | nil
function M.get_thread(file, current_line)
  if not threads[file] then
    return nil
  end

  return threads[file][current_line]
end

--- @param thread Thread
function M.set_thread(thread)
  if not threads[thread.path] then
    threads[thread.path] = {}
  end

  threads[thread.path][thread.originalLine] = thread
end

return M
