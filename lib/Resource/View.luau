--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Wrapper = require('@lorry.project/lib/Wrapper')

local View = {}

export type View = typeof(View) & Wrapper.Unwrappable<Unwrapped>

export type ViewProps = {
  name: string,
  columns: {string},
}

export type Unwrapped = {
  name: string,
  columns: {string},
}

export type ViewImpl = View & ViewProps

function View:new(o: ViewProps): View
  return Meta:type(o, self, "Resource.View")
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

function View:unwrap(): Unwrapped
  local this = self::ViewImpl
  return {
    name = this.name,
    columns = this.columns,
  }
end

return View
