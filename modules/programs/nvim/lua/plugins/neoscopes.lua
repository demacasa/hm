vim.pack.add({
  { src = 'https://github.com/smartpde/neoscopes' },
})

local neoscopes = require('neoscopes')

local function load_experimental_scopes(google3_root)
  local exp_scopes_file = google3_root .. '/experimental/users/mdem/configs/nvim/neoscopes.lua'

  if vim.fn.filereadable(exp_scopes_file) == 1 then
    local status, result = pcall(dofile, exp_scopes_file)

    if status then
      if type(result) == 'table' then
        return result
      else
        vim.notify('Error: ' .. exp_scopes_file .. ' did not return a table.', vim.log.levels.ERROR)
      end
    else
      vim.notify('Error executing ' .. exp_scopes_file .. ': ' .. tostring(result), vim.log.levels.ERROR)
    end
  end
  return {}
end

neoscopes.clear()
neoscopes.add_startup_scope()

local cwd = vim.fn.getcwd(-1)
if cwd and string.match(cwd, '/google3$') then
  local google3_root = cwd
  local experimental_scopes = load_experimental_scopes(google3_root)

  for _, scope in ipairs(experimental_scopes) do
    local absolute_dirs = {}
    if scope.dirs then
      for _, dir in ipairs(scope.dirs) do
        table.insert(absolute_dirs, google3_root .. '/' .. dir)
      end
      neoscopes.add({ name = scope.name, dirs = absolute_dirs })
    end
  end
end
