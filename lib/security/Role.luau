local Meta = require('@develfish-repo.core/Meta')
local Wrapper = require('@develfish-repo.core/Wrapper')

export type Role = Wrapper.Unwrappable<Unwrapped> & {
  __type: 'Role',
  expression: string,
}

export type Unwrapped = {
  expression: string,
}

local Role = {
  __type = 'Role',
  expression = nil,
}

function Role:new(o): Role
  return Meta:type(o, self)
end

function Role:from(expression: string): Role
  return Role:new({
    expression = expression,
  })
end

function Role.unwrap(self: Role): Unwrapped
  return {
    expression = self.expression,
  }
end

return Role
