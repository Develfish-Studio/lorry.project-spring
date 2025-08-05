local Meta = require('@develfish-repo.core/Meta')
local Wrapper = require('@develfish-repo.core/Wrapper')

export type Producer = Wrapper.Unwrappable<Unwrapped> & {
  __type: 'Producer',
  action: string,
}

export type Unwrapped = {
  action: string,
}

local Producer = {
  __type = 'Producer',
  action = nil,
}

function Producer:new(o): Producer
  return Meta:type(o, self)
end

function Producer:from(action: string): Producer
  return Producer:new({
    action = action,
  })
end

function Producer.unwrap(self: Producer): Unwrapped
  return {
    action = self.action,
  }
end

return Producer
