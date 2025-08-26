--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')

local Role = {}

export type Role = typeof(Role) & Wrapper.Unwrappable<Unwrapped>

export type RoleProps = {
  expression: string,
}

export type Unwrapped = RoleProps

export type RoleImpl = Role & RoleProps

function Role:new(o: RoleProps): Role
  return Meta:type(o, self, "Resource.Role")
end

function Role:from(expression: string): Role
  return Role:new({
    expression = expression,
  })
end

function Role:unwrap(): Unwrapped
  local this = self::RoleImpl
  return {
    expression = this.expression,
  }
end

return Role
