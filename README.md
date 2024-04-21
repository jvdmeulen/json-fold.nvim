# json-fold.nvim
Plugin for Neovim that can fold and expand JSON-objects and JSON-arrays.

It tries to fold/expand as close to the cursor as possible

Code voor Lazy
```lua
{
    "jvdmeulen/json-fold.nvim",
    config = function()
        -- make commands public
        local j = require('json-fold')
        vim.api.nvim_create_user_command('JsonExpand', function() j.process_json('expand') end, {nargs = 0})
        vim.api.nvim_create_user_command('JsonCompress', function() j.process_json('compress') end, {nargs = 0})

        -- Keybindings for normal mode
        vim.api.nvim_set_keymap('n', '<leader>jc', ':JsonCompress<CR>', { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<leader>jd', ':JsonExpand<CR>', { noremap = true, silent = true })
    end
}
```

