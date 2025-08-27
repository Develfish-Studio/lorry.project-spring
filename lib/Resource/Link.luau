--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Case = require('@lorry.utils/lib/Case')
local Unit = require('../Unit/Unit')
local Module = require('../Module/Module')
local Target = require('./Target')
local Projection = require('./Projection')
local Request = require('./Request')

local Link = {}

export type Link = typeof(Link)

export type LinkProps = {
  name: string,
  resource: Target.Target,
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

export type Unwrapped = {
  link: UnwrappedLink,
  unit: Unit.UnwrappedUnit,
  package: Module.UnwrappedPackage,
  projection: Projection.Unwrapped,
  resource: Target.UnwrappedResource,
  requests: {Request.Unwrapped},
}

export type UnwrappedLink = {
  name: string,
  snake_name: string,
  camel_name: string,
  pascal_name: string,
  kebab_name: string,
}

export type LinkImpl = Link & LinkProps

function Link:new(o: LinkProps): Link
  return Meta:type(o, self, "Resource.Link")
end

function Link:from_resource(name: string, resource: Target.Target): Link
  assert(name ~= nil)
  assert(resource ~= nil)
  return Link:new({
    name = name,
    resource = resource,
  })
end

function Link:unwrap_link(): UnwrappedLink
  local this = self::LinkImpl
  return {
    name = this.name,
    snake_name = this.name,
    camel_name = Case:snake_to_camel(this.name),
    pascal_name = Case:snake_to_pascal(this.name),
    kebab_name = Case:snake_to_kebab(this.name),
  }
end

function Link:unwrap(): Unwrapped
  local this = self::LinkImpl
  local target = this.resource::Target.TargetImpl
  return {
    link = this:unwrap_link(),
    unit = target.unit:unwrap_unit(),
    package = target.unit.module:unwrap_package(),
    projection = target.projection:unwrap(),
    requests = target:unwrap_requests(),
    resource = target:unwrap_resource(),
  }
end

return Link
