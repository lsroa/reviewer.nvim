local M = {}

local store = require('comments.store')
local core = require('comments.core')

local function parse_thread(result)
  local threads = result.data.repository.pullRequest.reviewThreads.edges
  for _, edges in ipairs(threads) do
    for _, thread in pairs(edges.node.comments) do
      local comments = {}
      for _, raw_comment in pairs(thread) do
        if vim.fn.filereadable(edges.node.path) == 1 then
          local comment = core.Comment.new(
            raw_comment.url,
            raw_comment.body,
            raw_comment.author.login
          )
          table.insert(comments, comment)
        end
      end
      store.set_thread(core.Thread.new(comments, edges.node.isResolved, edges.node.originalLine, edges.node.path))
    end
  end
end

M.fetch_files = function()
  vim.system({ "gh", "pr", "view", "--json", "files" }, { text = true }, function(out)
    if out.code ~= 0 then
      return
    end
    local files = vim.json.decode(out.stdout).files
    store.set_files(files)
  end)
end

M.fetch_comments = function()
  local repo = nil
  local pr = nil
  local query = [[
    query FetchUnresolvedReviewComments($owner: String!, $repo: String!, $pr: Int!) {
      repository(owner: $owner, name: $repo) {
        pullRequest(number: $pr) {
          reviewThreads(first: 50) {
            edges {
              node {
                isResolved
                line
                originalLine
                path
                comments(first: 10) {
                  nodes {
                    author {
                      login
                    }
                    body
                    url
                  }
                }
              }
            }
          }
        }
      }
    }
  ]]


  local done = function()
    if repo ~= nil and pr ~= nil then
      local owner = repo:gsub("/(.*)$", "")
      repo = repo:gsub("^(.*)/", "")
      local command = {
        "gh",
        "api",
        "graphql",
        "-F", "pr=" .. tonumber(pr),
        "-F", "repo=" .. repo,
        "-f", "query=" .. query,
        "-f", "owner=" .. owner
      }
      vim.system(command, { text = true }, function(out)
        if out.code ~= 0 then
          vim.print("error")
          vim.print(out.stderr)
          vim.print(out.stdout)
          return
        end

        local result = vim.json.decode(out.stdout)
        parse_thread(result)

        vim.schedule(function()
          vim.api.nvim_exec_autocmds('User', { pattern = 'CommentsLoaded' })
        end)
      end)
    end
  end

  vim.system({ 'gh', 'repo', 'view', '--json', 'nameWithOwner', '-q', '.nameWithOwner' }, { text = true }, function(out)
    if out.code ~= 0 then
      return
    end
    repo = out.stdout:gsub('\n', '')
    done()
  end)

  vim.system({ 'gh', 'pr', 'view', '--json', 'number', '-q', '.number' }, { text = true }, function(out)
    if out.code ~= 0 then
      return
    end


    pr = out.stdout:gsub('\n', '')
    done()
  end)
end

return M
