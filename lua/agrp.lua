local M = {
  funcs = {},
  my_name = (function()
    local file = debug.getinfo(1, 'S').source
    return file:match'/(%a+)%.lua$'
  end)()
}

M.set = function(groups)
  vim.validate{groups = {groups, 'table'}}
  for name, definitions in pairs(groups) do
    vim.validate{
      name = {name, 'string'},
      definitions = {definitions, 'table'},
    }
    local cmds = {'augroup '..name, 'autocmd!'}
    for _, d in ipairs(definitions) do
      vim.validate{
        d = {
          d,
          function() return type(d) == 'table' and vim.tbl_count(d) == 3 end,
          'each definition containing 3 values'
        },
      }
      local events, patterns, cmd_or_func = d[1], d[2], d[3]
      local command
      if type(cmd_or_func) == 'string' then
        command = cmd_or_func
      else
        table.insert(M.funcs, cmd_or_func)
        command = ([[lua require'%s'.funcs[%d]()]]):format(M.my_name, #M.funcs)
      end
      table.insert(cmds, 'autocmd '..events..' '..patterns..' '..command)
    end
    table.insert(cmds, 'augroup END')
    vim.api.nvim_exec(table.concat(cmds, '\n'), false)
  end
end

return M
