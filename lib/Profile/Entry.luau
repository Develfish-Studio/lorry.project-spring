--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')
local Table = require('@develfish-repo.utils/lib/Table')

local Entry = {}

export type Entry = typeof(Entry) & EntryProps & Wrapper.Unwrappable<Unwrapped>

export type EntryProps = {
  name: string,
  config: Data,
}

export type Data = {
  [string]: any
}

export type Unwrapped = EntryProps

function Entry:new(o: EntryProps): Entry
  return Meta:type(o, self, "Profile.Entry")
end

function Entry:from(name: string, config: Data): Entry
  return Entry:new({
    name = name,
    config = config,
  })
end

function Entry:copy(): Entry
  local this = self::Entry
  return Entry:new({
    name = this.name,
    config = Table:deep_copy(this.config),
  })
end

function Entry:unwrap(): Unwrapped
  local this = self::Entry
  return {
    name = this.name,
    config = this.config,
  }
end

return Entry
