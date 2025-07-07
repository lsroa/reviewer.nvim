# reviewer.nvim
This nvim plugin mimics some PyCharm features for reviewving PRs. it realys heavily on `gh cli` so github is the only supported provider for now

#### Features
- List PR files (with comment counts)
- List Pr Comments (filtering resolved conversations)
- Preview comments
- Sign column for comments 💬
- Jump through comments within the buffer
- Open comments in the web

#### Config
```lua
{
  "lsroa/reviewer.nvim",
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
  },
  config = function()
    require('comments').setup()

    vim.keymap.set('n', '<leader>gc', '<cmd>ShowComment<CR>', opts)
    vim.keymap.set('n', '<leader>fp', '<cmd>PRFiles<CR>', opts)
    vim.keymap.set('n', '<leader>fc', '<cmd>PRComments<CR>', opts)

    vim.keymap.set('n', ']g', function()
      require('comments').jump(1)
      vim.defer_fn(function()
        require('comments').show_comment()
      end, 50)
    end, opts)

    vim.keymap.set('n', '[g', function()
      require('comments').jump(-1)
      vim.defer_fn(function()
        require('comments').show_comment()
      end, 50)
    end, opts)
  end
}
```
