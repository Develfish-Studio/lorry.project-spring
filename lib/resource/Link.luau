local Meta = require('@develfish-repo.core/Meta')
local Wrapper = require('@develfish-repo.core/Wrapper')
local Spring = require('@develfish-repo.spring/Spring')
local Module = require('@develfish-repo.spring/Module')
local Projection = require('@develfish-repo.spring/Projection')
local Request = require('@develfish-repo.spring/resource/Request')
local Unit = require('@develfish-repo.spring/Unit')
local case = require('@develfish-repo.core/util/string/case')

export type Link = Wrapper.Unwrappable<Unwrapped> & {
  __type: 'Link',
  name: string,
  resource: Spring.ResourceRef,
  unwrap_link: (self: Link) -> UnwrappedLink,
  unwrap_resource: (self: Link) -> ResourceRef.UnwrappedResource,
  unwrap_requests: (self: Link) -> {Request.Unwrapped},
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

local Link = {
  __type = 'Link',
  name = nil,
  resource = nil,
}

function Link:new(o): Link
  return Meta:type(o, self)
end

function Link:from_resource(name: string, resource: Spring.ResourceRef): Link
  assert(name ~= nil)
  assert(resource ~= nil)
  return Link:new({
    name = name,
    resource = resource,
  })
end

function Link.unwrap_link(self: Link): UnwrappedLink
  return {
    name = self.name,
    snake_name = self.name,
    camel_name = case.snakeToCamel(self.name),
    pascal_name = case.snakeToPascal(self.name),
    kebab_name = case.snakeToKebab(self.name),
  }
end

function Link.unwrap(self: Link): Unwrapped
  return {
    link = self:unwrap_link(),
    unit = self.resource.unit:unwrap_unit(),
    package = self.resource.unit.module:unwrap_package(),
    projection = self.resource.projection:unwrap(),
    requests = self.resource:unwrap_requests(),
    resource = self.resource:unwrap_resource(),
  }
end

return Link
