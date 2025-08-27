--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Wrapper = require('@lorry.project/lib/Wrapper')

local Arg = {}

export type Arg = typeof(Arg) & Wrapper.Unwrappable<Unwrapped>

export type ArgProps = {
  path: string?,
  value: string?,
  expression: string?,
}

export type Unwrapped = {
  path: Wrapper.UnwrappedPath?,
  value: string?,
  expression: string?,
}

export type ArgImpl = Arg & ArgProps

function Arg:new(o: ArgProps): Arg
  return Meta:type(o, self, "Resource.Arg")
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

function Arg:unwrap(): Unwrapped
  local this = self::ArgImpl
  return {
    path = Wrapper:unwrap_path(this.path),
    value = this.value,
    expression = this.expression,
  }
end

return Arg
