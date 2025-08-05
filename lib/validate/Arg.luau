local Meta = require('@develfish-repo.core/Meta')
local Wrapper = require('@develfish-repo.core/Wrapper')

export type Arg = Wrapper.Unwrappable<Unwrapped> & {
  __type: 'Arg',
  path: string,
  value: string?,
  expression: string?,
}

export type Unwrapped = {
  path: Wrapper.UnwrappedPath?,
  value: string?,
  expression: string?,
}

local Arg = {
  __type = 'Arg',
  path = nil,
  value = nil,
  expression = nil,
}

function Arg:new(o): Arg
  return Meta:type(o, self)
end

function Arg:from_path(path: string): Arg
  return Arg:new({
    path = path,
  })
end

function Arg:from_value(value: string): Arg
  return Arg:new({
    value = value,
  })
end

function Arg:from_expression(epression: string): Arg
  return Arg:new({
    epression = epression,
  })
end

function Arg.unwrap(self: Arg): Unwrapped
  return {
    path = Wrapper:unwrap_path(self.path),
    value = self.value,
    expression = self.expression,
  }
end

return Arg
