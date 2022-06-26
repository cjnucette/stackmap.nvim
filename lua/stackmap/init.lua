local M = {}

local function find_mapping(maps, lhs)
  for _, map in ipairs(maps) do
    if map.lhs == lhs then
      return map
    end
  end
end -- returns an implicit nil

-- _<name>: this name convention means internal,
-- you can use it, but this can change in ways that can break your code.
-- use it at your own peril.
M._stack = {}

function M.push(name, mode, mappings)
  local maps = vim.api.nvim_get_keymap(mode) -- returns array of global mappings
  local existing_maps = {}

  for lhs, rhs in pairs(mappings) do
    local existing = find_mapping(maps, lhs)
    if existing then
      existing_maps[lhs] = existing
    end

    -- TODO: need some wayt to pass options in here
    vim.keymap.set(mode, lhs, rhs)
  end

  -- TODO: metatables POGSLIDE
  M._stack[name] = M._stack[name] or {}

  M._stack[name][mode] = {
    existing = existing_maps,
    mappings = mappings
  }
end

function M.pop(name, mode)
  local state = M._stack[name][mode]
  M._stack[name][mode] = nil

  -- if not state then return end

  for lhs, _ in pairs(state.mappings) do
    if state.existing[lhs] then
      -- vim.keymap.del(state.mode, lhs)
      vim.keymap.set(mode, lhs, state.existing[lhs].rhs)
    else
      vim.keymap.del(mode, lhs)
    end
  end
end

function M._clear()
  M._stack = {}
end

-- testing
-- TODO: remove this
M.push('debug_mode', 'n', {
  [' th'] = "echo 'Hello'",
  [' tz'] = "echo 'Goodbye'",
})

return M
