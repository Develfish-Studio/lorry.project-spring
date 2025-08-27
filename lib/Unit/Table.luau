--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Wrapper = require('@lorry.project/lib/Wrapper')

local Table = {}

export type Table = typeof(Table) & Wrapper.Unwrappable<Unwrapped>

export type TableProps = {
  table: string,
  schema: string,
}

export type Unwrapped = TableProps

export type TableImpl = Table & TableProps

function Table:new(o: TableProps): Table
  return Meta:type(o, self, 'Unit.Table')
end

function Table:from_full_name(name: string): Table
  local schema, table = self.name:match("([^.]+).([^.]+)")
  return Table:new({
    table = table,
    schema = schema,
  })
end

function Table:unwrap(): Unwrapped
  local this = self::TableImpl
  return {
    table = this.table,
    schema = this.schema,
  }
end

return Table
