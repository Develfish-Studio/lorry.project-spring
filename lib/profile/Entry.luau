local Meta = require('@develfish-repo.core/Meta')
local Wrapper = require('@develfish-repo.core/Wrapper')
local OBJECT = require('@develfish-repo.core/util/object')

export type Entry = Wrapper.Unwrappable<Unwrapped> & {
  name: string,
  config: Data,
}

export type Data = {
  [string]: any
}

export type Unwrapped = {
  name: string,
  config: Data,
}

local Entry = {
  __type = 'Entry',
  name = nil,
  config = nil,
}

function Entry:new(o): Entry
  return Meta:type(o, self)
end

function Entry:from(name: string, config: Data): Entry
  return Entry:new({
    name = name,
    config = config,
  })
end

function Entry.copy(self: Entry): Entry
  return Entry:new({
    name = self.name,
    config = OBJECT.deep_copy(self.config),
  })
end

function Entry.unwrap(self: Entry): Unwrapped
  return {
    name = self.name,
    config = self.config,
  }
end

return Entry
