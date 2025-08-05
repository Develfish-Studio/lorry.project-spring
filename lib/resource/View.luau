local Meta = require('@develfish-repo.core/Meta')
local Wrapper = require('@develfish-repo.core/Wrapper')

export type View = Wrapper.Unwrappable<Unwrapped> & {
  __type: 'View',
  name: string,
  columns: {string},
}

export type Unwrapped = {
  name: string,
  columns: {string},
}

local View = {
  __type = 'View',
  name = nil,
  columns = Meta:array {},
}

function View:new(o): View
  return Meta:type(o, self)
end

function View:from(name: string, columns: {string}?): View
  return View:new({
    name = name,
    columns = columns or Meta:array {},
  })
end

function View:kafka(columns: {string}?): View
  return View:from('Kafka', columns)
end

function View:create(columns: {string}?): View
  return View:from('Create', columns)
end

function View:update(columns: {string}?): View
  return View:from('Update', columns)
end

function View:upsert(columns: {string}?): View
  return View:from('Upsert', columns)
end

function View:remove(columns: {string}?): View
  return View:from('Remove', columns)
end

function View:select(columns: {string}?): View
  return View:from('Select', columns)
end

function View.unwrap(self: View): Unwrapped
  return {
    name = self.name,
    columns = self.columns,
  }
end

return View
