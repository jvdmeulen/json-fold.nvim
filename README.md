# json-fold.nvim
A plugin for Neovim that can fold and unfold JSON-objects and JSON-arrays as close to the cursor as possible.

Code voor Lazy
```lua
{
    "jvdmeulen/json-fold.nvim",
    config = function()
        require('json-fold').setup()

        -- Keybindings for normal mode
        vim.api.nvim_set_keymap('n', '<leader>jc', ':JsonFoldFromCursor<CR>', { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<leader>jd', ':JsonUnfoldFromCursor<CR>', { noremap = true, silent = true })
    end
}
```
After the setup there are two commands you can assign
* :JsonFoldFromCursor
* :JsonUnfoldFromCursor


![A little preview](https://github.com/jvdmeulen/json-fold.nvim/assets/129403/672534c6-76e1-4e95-a98c-64de7226a375)


For debugging purposes there is a optional debug flag you can enable
```lua
require('json-fold').setup({
    debug = true
})
```

