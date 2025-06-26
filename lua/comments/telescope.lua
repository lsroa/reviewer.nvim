local store = require("comments.store")

local M = {}

M.list_pr_files = function()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local devicons = require("nvim-web-devicons")
  local ICON = 4
  local FILENAME = 42
  local PADDING = 5
  local max_width = 0
  local files = store.get_files()

  for _, path in pairs(files) do
    max_width = math.max(max_width, #path)
  end

  local displayer = require("telescope.pickers.entry_display").create({
    separator = " ",
    items = {
      { width = 2 },
      { width = 40 },
      { remaining = true },
    },
  })



  pickers.new({
    layout_strategy = "center",
    layout_config = {
      width = ICON + FILENAME + max_width + PADDING,
      height = #files + 4 -- prompt line + borders
    },
    sorting_strategy = "ascending",
    previewer = false,
  }, {
    prompt_title = "PR Files",
    finder = finders.new_table {
      results = files,
      entry_maker = function(entry)
        return {
          value = entry,
          ordinal = entry,
          display = function(file)
            local path = file.value
            local filename = path:match("[^/]+$")
            local icon, icon_highlight = devicons.get_icon(filename, nil, { default = true })
            return displayer {
              { icon,                           icon_highlight },
              { " " .. path:gmatch("[^/]+$")(), "Normal" },
              { " " .. path,                    "TelescopeResultsComment" },
            }
          end,
        }
      end,
    },
    sorter = conf.generic_sorter({}),
  }):find()
end

M.list_comments = function()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values

  local comments = {}
  local max_width = 0
  local COUNT = 2
  local TAIL = 40

  local displayer = require("telescope.pickers.entry_display").create({
    separator = " ",
    items = {
      { width = COUNT },
      { width = TAIL },
      { remaining = true },
    },
  })

  for file, thread_by_line in pairs(store.get_threads()) do
    local total_comments_per_file = 0
    for _, thread in pairs(thread_by_line) do
      total_comments_per_file = total_comments_per_file + #thread.comments
      max_width = math.max(max_width, #file)
    end
    table.insert(comments, total_comments_per_file .. "|" .. file)
  end

  local BASE_HEIGHT = 4 -- header + border
  local PADDING = 8     -- padding + space between

  pickers.new({
    layout_strategy = "center",
    layout_config = {
      height = #comments + BASE_HEIGHT,
      width = COUNT + max_width + TAIL + PADDING,
    },
    sorting_strategy = "ascending",
    previewer = false,
  }, {
    prompt_title = "Comments",
    finder = finders.new_table {
      results = comments,
      entry_maker = function(entry)
        local count, path = entry:match('^(.-)|(.+)$')
        return {
          value = path,
          ordinal = path,
          display = function()
            return displayer {
              { count .. " ",                   "@keyword.return" },
              { " " .. path:gmatch("[^/]+$")(), "TelescopeResultsFunction" },
              { " " .. path,                    "TelescopeResultsComment" },
            }
          end,
        }
      end,
    },
    sorter = conf.generic_sorter({}),
  }):find()
end

return M
