# agrp.nvim

Yet another utility to set augroup in Neovim

## What's this?

This makes you easily define augroup & autocmd in Lua instead of executing Vim commands.

Yes, there is [official PR][] for the same purpose, but it shows no signs of being merged. I cannot stand anymore! ;(

[official PR]: https://github.com/neovim/neovim/pull/12378

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

This will execute command below.

```vim
augroup MyHelloWorld
  autocmd!
  autocmd VimEnter * echo 'Hello World!'
augroup END

augroup MyFavorites
  autocmd!
  autocmd VimEnter * doautocmd ColorScheme solarized8
  autocmd QuickFixCmdPost *grep* cwindow
augroup END
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

```vim
" Lua functions will be wrapped and stored in this plugin.
augroup MyFavorites2
  autocmd!
  autocmd TextYankPost * lua require'agrp'.funcs[1]()
  autocmd VimEnter * lua require'agrp'.funcs[2]()
augroup END
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
