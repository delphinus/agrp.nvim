local M = {
  funcs = {},
  my_name = (function()
    local file = debug.getinfo(1, 'S').source
    return file:match'/(%a+)%.lua$'
  end)()
}

local function make_command(events, patterns, cmd_or_func)
  local command
  if type(cmd_or_func) == 'string' then
    command = cmd_or_func
  else
    table.insert(M.funcs, cmd_or_func)
    command = ([[lua require'%s'.funcs[%d]()]]):format(M.my_name, #M.funcs)
  end
  return ('autocmd %s %s %s'):format(events, patterns, command)
end

M.set = function(groups)
  vim.validate{groups = {groups, 'table'}}
  for name, definitions in pairs(groups) do
    vim.validate{
      name = {name, 'string'},
      definitions = {definitions, 'table'},
    }
    local cmds = {'augroup '..name, 'autocmd!'}
    for key, definition in pairs(definitions) do
      vim.validate{
        definition = {definition, 'table'},
      }
      if type(key) == 'number' then
        if vim.tbl_count(definition) == 3 then
          table.insert(cmds, make_command(unpack(definition)))
        else
          error'each definition should have 3 values'
        end
      else
        for _, d in ipairs(definition) do
          if vim.tbl_count(d) == 2 then
            table.insert(cmds, make_command(key, unpack(d)))
          else
            error'each definition should have 2 values'
          end
        end
      end
    end
    table.insert(cmds, 'augroup END')
    vim.api.nvim_exec(table.concat(cmds, '\n'), false)
  end
end

return M
