local Projection = require('./Projection')
local Request = require('./Request')
local Unit = require('../Unit/Unit')

local Target = {
  Projection = Projection,
  Request = Request,
  Unit = Unit,
}

export type UnwrappedResource = {
  name: string,
  snake_name: string,
  camel_name: string,
  pascal_name: string,
  kebab_name: string,
  title: string,
  description: string?,
}

export type Target = typeof(Target)

export type TargetImpl = Target & {
  unit: Unit.Unit,
  projection: Projection.Projection,
  unwrap_resource: (self: Target) -> UnwrappedResource,
  unwrap_requests: (self: Target) -> {Request.Unwrapped}
}

return Target
