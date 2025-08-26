--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Case = require('@develfish-repo.utils/lib/Case')
local Unit = require('../Unit/Unit')
local Module = require('../Module/Module')
local Projection = require('./Projection')
local Request = require('./Request')

local Link = {}

export type Link = typeof(Link)

export type LinkOwner = {}

export type LinkProps = {
  name: string,
  resource: LinkOwner,
}

export type Unwrapped = {
  link: UnwrappedLink,
  unit: Unit.UnwrappedUnit,
  package: Module.UnwrappedPackage,
  projection: Projection.Unwrapped,
  resource: ResourceRef.UnwrappedResource,
  requests: Request.Unwrapped,
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

function Link:from_resource(name: string, resource: LinkOwner): Link
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
    pascal_name = Case.snake_to_pascal(this.name),
    kebab_name = Case.snake_to_kebab(this.name),
  }
end

function Link:unwrap_in_context(resource: LinkOwner): Unwrapped
  local this = self::LinkImpl
  return {
    link = this:unwrap_link(),
    unit = resource.unit:unwrap_unit(),
    package = resource.unit.module:unwrap_package(),
    projection = resource.projection:unwrap(),
    requests = resource:unwrap_requests(),
    resource = resource:unwrap_resource(),
  }
end

return Link
