local M = {}

local function is_vim_func_string(s)
  return type(s) == "string" and s:match "^[bwtglsav]:[_%d%w]+$"
end

local function manage_definitions(definitions, group)
  for key, definition in pairs(definitions) do
    vim.validate {
      definition = { definition, "table" },
    }
    -- When group is nil, it does not set augroup.
    local opt = { group = group }
    local event
    local cb_or_cmd
    if type(key) == "number" then
      -- Each definition has all params to set.
      -- {
      --   {'TextYankPost', ...},
      --   {'VimEnter', ...},
      -- }
      if #definition == 3 then
        -- ex. {'TextYankPost', '*', function() vim.highlight.on_yank{} end},
        opt.pattern = definition[2]
        event = definition[1]
        cb_or_cmd = definition[3]
      elseif #definition == 4 then
        -- ex. {'VimEnter', '*', {'once'}, function() vim.cmd[[echo 'Hello, World!']] end},
        opt.once = definition[1].once and true or false
        opt.nested = definition[1].nested and true or false
        opt.pattern = definition[3]
        event = definition[2]
        cb_or_cmd = definition[4]
      else
        error "each definition should have 3 values (+options (once, nested))"
      end
    else
      -- One event has many definitions
      -- {
      --   ['BufNewFile,BufRead'] = {
      --     {'*.hoge', 'set filetype=hoge'},
      --     {'*.fuga', 'set filetype=fuga'},
      --   },
      -- }
      for _, d in ipairs(definition) do
        if #d == 2 or #d == 3 then
          opt.pattern = d[1]
          event = key
          cb_or_cmd = d[2]
        else
          error "each definition should have 2 values (+options (once, nested))"
        end
      end
    end
    if type(cb_or_cmd) == "function" or is_vim_func_string(cb_or_cmd) then
      opt.callback = cb_or_cmd
    else
      opt.command = cb_or_cmd
    end
    vim.api.nvim_create_autocmd(event, opt)
  end
end

M.set = function(groups)
  vim.validate { groups = { groups, "table" } }
  for name, definitions in pairs(groups) do
    vim.validate {
      definitions = { definitions, "table" },
    }
    if type(name) == "number" then
      -- This section deals with the pattern that has no augroup.
      --   require'agrp'.set{
      --     {
      --       ['BufNewFile,BufRead'] = {
      --         {'*.hoge', 'set filetype=hoge'},
      --       },
      --     },
      --   }
      manage_definitions(definitions)
    else
      -- This is for the usual pattern that has augroup.
      --   require'agrp'.set{
      --     MyFavorites = {
      --       {'QuickFixCmdPost', '*grep*', 'cwindow'},
      --     },
      --   }
      vim.api.nvim_create_augroup(name, {})
      manage_definitions(definitions, name)
    end
  end
end

return M
