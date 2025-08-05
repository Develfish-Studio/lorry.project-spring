local Meta = require('@develfish-repo.core/Meta')
local Wrapper = require('@develfish-repo.core/Wrapper')

export type Table = Wrapper.Unwrappable<Unwrapped> & {
  __type: 'Table',
  table: string,
  schema: string,
}

export type Unwrapped = {
  table: string,
  schema: string,
}

local Table = {
  __type = 'Table',
  table = nil,
  schema = nil,
}

function Table:new(o): Table
  return Meta:type(o, self)
end

function Table:from(name: string): Table
  local schema, table = self.name:match("([^.]+).([^.]+)")
  return Table:new({
    table = table,
    schema = schema,
  })
end

function Table.unwrap(self: Table): Unwrapped
  return {
    table = self.table,
    schema = self.schema,
  }
end

return Table
