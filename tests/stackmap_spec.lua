local find_map = function(lhs)
  local maps = vim.api.nvim_get_keymap('n')
  for _, map in ipairs(maps) do
    if map.lhs == lhs then
      return map
    end
  end
end

describe('stackmap', function()
  before_each(function()
    pcall(vim.keymap.del, 'n', 'asdf')
    pcall(vim.keymap.del, 'n', 'asdf_1')
    pcall(vim.keymap.del, 'n', 'asdf_2')
    require('stackmap')._clear()
  end)

  it('can be required', function()
    local ok, stackmap = pcall(require, 'stackmap')
  end)

  it('can push a single map', function()
    local rhs = "echo 'this is a test'"
    require('stackmap').push('test1', 'n', {
      asdf = rhs
    })

    local found = find_map('asdf')

    assert.are.same(rhs, found.rhs)
  end)

  it('can push multiple maps', function()
    local rhs = "echo 'this is a test'"
    require('stackmap').push('test1', 'n', {
      ['asdf_1'] = rhs .. '1',
      ['asdf_2'] = rhs .. '2'
    })

    local found_1 = find_map('asdf_1')
    local found_2 = find_map('asdf_2')

    assert.are.same(rhs .. '1', found_1.rhs)
    assert.are.same(rhs .. '2', found_2.rhs)
  end)

  it('can delete mappins after pop: no existing', function()
    local rhs = "echo 'this is a test'"
    require('stackmap').push('test1', 'n', {
      asdf = rhs
    })

    local found = find_map('asdf')

    assert.are.same(rhs, found.rhs)

    require('stackmap').pop('test1', 'n')
    local after_pop = find_map('asdf')
    assert.are.same(nil, after_pop)
  end)

  it('can delete mappins after pop: yes existing', function()
    vim.keymap.set('n', 'asdf', 'echo "OG MAPPING"')

    local rhs = "echo 'this is a test'"
    require('stackmap').push('test1', 'n', {
      asdf = rhs
    })

    local found = find_map('asdf')

    assert.are.same(rhs, found.rhs) -- it was set to the new mapping

    require('stackmap').pop('test1', 'n')

    local after_pop = find_map('asdf')
    assert.are.same('echo "OG MAPPING"', after_pop.rhs)
  end)
end)
