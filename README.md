# agrp.nvim

Yet another utility to set augroup in Neovim

## What's this?

This makes you easily define augroup & autocmd with Neovim native APIs. There are `vim.api.nvim_create_augroup` & `vim.api.nvim_create_autocmd`, but they have a bit complex syntax. This plugin is meant to be used as a syntax sugar.

## Usage

### Standard augroup & autocmd

```lua
require'agrp'.set{
  MyHelloWorld = {
    {'VimEnter', '*', 'echo "Hello World!"'},
  },
  MyFavorites = {
    {'VimEnter', '*', 'doautocmd ColorScheme solarized8'},
    {'QuickFixCmdPost', '*grrep*', 'cwindow'},
  },
}
```

This will execute the script below.

```lua
vim.api.nvim_create_augroup { name = "MyHelloWorld", clear = true }
vim.api.nvim_create_autocmd {
  group = "MyHelloWorld",
  event = "VimEnter",
  pattern = "*",
  callback = [[echo 'Hello World!']],
}

vim.api.nvim_create_augroup { name = "MyFavorites", clear = true }
vim.api.nvim_create_autocmd {
  group = "MyFavorites",
  event = "VimEnter",
  pattern = "*",
  callback = [[doautocmd ColorScheme solarized8]],
}
vim.api.nvim_create_autocmd {
  group = "MyFavorites",
  event = "QuickFixCmdPost",
  pattern = "*grep*",
  callback = [[cwindow]],
}
```

### Bind with Lua functions

It can binds Lua functions.

```lua
require'agrp'.set{
  MyFavorites2 = {
    -- See https://github.com/neovim/neovim/pull/12279
    {'TextYankPost', '*', vim.highlight.on_yank},
    -- Quit with `q` when run with `-R`
    {
      'VimEnter',
      '*',
      function()
        if vim.opt.readonly:get() then
          vim.api.nvim_set_keymap('n', 'q', '<Cmd>qa<CR>', {})
        end
      end,
    },
  },
}
```

In this case, it runs below.

```lua
vim.api.nvim_create_augroups { name = "MyFavorites2", clear = true }
vim.api.nvim_create_autocmd {
  group = "MyFavorites2",
  event = "TextYankPost",
  pattern = "*",
  callback = vim.highlight.on_yank,
}
vim.api.nvim_create_autocmd {
  group = "MyFavorites2",
  event = "VimEnter",
  pattern = "*",
  callback = function()
    if vim.opt.readonly:get() then
      vim.api.nvim_set_keymap("n", "q", "<Cmd>qa<CR>", {})
    end
  end,
}
```

### Multi definitions for one event

Multi definitions can be gathered into one table.

```lua
require'agrp'.set{
  MyFiledetect = {
    ['BufNewFile,BufRead'] = {
      {'*.hoge', 'set filetype=hoge'},
      {'*.fuga', 'set filetype=fuga'},
      {'*.foo', 'set filetype=foo'},
    },
  },
}
```

### autocmd without augroup

For ftdetct, you can define autocmd without any augroup.

NOTE: This is not recommended for the normal use of autocmd.

```lua
require'agrp'.set{
  {
    ['BufNewFile,BufRead'] = {
      {'*.hoge', 'set filetype=hoge'},
      {'*.fuga', 'set filetype=fuga'},
      {'*.foo', 'set filetype=foo'},
    },
  },
}
```

### `++once` and `++nested` options

Options for autocmd should be set in a table just before the command (or Lua function).

```lua
require'agrp'.set{
  RunOnlyOnce = {
    {'InsertCharPre', '*', {'once'}, function()
      vim.api.nvim_echo({
        {'Inserting a char: '..vim.v.char, 'WarningMsg'},
      }, false, {})
    end},
  },
}
```

## Caveats

This plugin itself will be deprecated when the [official PR][] or similar one will be merged.
