local Meta = require('@develfish-repo.core/Meta')
local Wrapper = require('@develfish-repo.core/Wrapper')
local Spring = require('@develfish-repo.spring/Spring')
local Project = require('@develfish-repo.core/Project')
local Module = require('@develfish-repo.spring/Module')
local Projection = require('@develfish-repo.spring/Projection')
local Unit = require('@develfish-repo.spring/Unit')
local Entity = require('@develfish-repo.spring/jpa/Entity')
local Signal = require('@develfish-repo.spring/resource/Signal')
local View = require('@develfish-repo.spring/resource/View')
local Request = require('@develfish-repo.spring/resource/Request')
local Override = require('@develfish-repo.spring/resource/Override')
local Filter = require('@develfish-repo.spring/resource/Filter')
local Link = require('@develfish-repo.spring/resource/Link')
local Fetch = require('@develfish-repo.spring/resource/Fetch')
local Validate = require('@develfish-repo.spring/resource/Validate')
local case = require('@develfish-repo.core/util/string/case')

export type Resource = Wrapper.Unwrappable<Unwrapped> & Spring.ResourceRef & {
  __type: 'Resource',

  title: string?,
  description: string?,
  projection: Projection.Projection,
  unit: Unit.Unit,
  signals: {Signal.Signal},
  views: {View.View},
  requests: {Request.Request},
  overrides: {Override.Override},
  filters: {Filter.Filter},
  fetches: {Fetch.Fetch},
  validations: {Validate.Validate},
  links: {Link.Link},

  unwrap_resource: (self: Resource) -> UnwrappedResource,
  unwrap_signals: (self: Resource) -> UnwrappedSignals,
  unwrap_views: (self: Resource) -> UnwrappedViews,
  unwrap_requests: (self: Resource) -> Request.UnwrappedRequests,
}

export type Unwrapped = {
  project: Project.UnwrappedProject,
  module: Module.UnwrappedModule,
  unit: Unit.UnwrappedUnit,
  package: Module.UnwrappedPackage,
  entity: Entity.Unwrapped,
  projection: Projection.Unwrapped,
  resource: UnwrappedResource,
  signals: UnwrappedSignals,
  views: UnwrappedViews,
  requests: Request.UnwrappedRequests,
  links: {Link.Unwrapped},
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

export type UnwrappedSignals = {
  [string]: {Signal.Unwrapped}
}

local Resource = {
  __type = 'Resource',

  Signal = Signal,
  View = View,
  Request = Request,
  Override = Override,
  Filter = Filter,
  Link = Link,
  Fetch = Fetch,
  Validate = Validate,

  title = nil,
  description = nil,
  projection = nil,
  unit = nil,
  signals = nil,
  views = nil,
  requests = nil,
  overrides = nil,
  filters = nil,
  fetches = nil,
  validations = nil,
  links = nil,
}

function Resource:new(o): Resource
  return Meta:type(o, self)
end

function Resource:from(projection: Projection.Projection, unit: Unit.Unit): Resource
  return Resource:new({
    projection = projection,
    unit = unit,
    signals = Meta:array {},
    views = Meta:array {},
    requests = Meta:array {},
    overrides = Meta:array {},
    filters = Meta:array {},
    fetches = Meta:array {},
    validations = Meta:array {},
    links = Meta:array {},
  })
end

function Resource.with_title(self: Resource, title: string): Resource
  self.title = title
  return self
end

function Resource.with_description(self: Resource, description: string): Resource
  self.description = description
  return self
end

function Resource.with_rules(self: Resource, children: {any}): Resource
  for _, child in children do
    if child.__type == 'Signal' then
      self.signals[#self.signals + 1] = child::Signal.Signal
    elseif child.__type == 'View' then
      self.views[#self.views + 1] = child::View.View
    elseif child.__type == 'Request' then
      self.requests[#self.requests + 1] = child::Request.Request
    elseif child.__type == 'Override' then
      self.overrides[#self.overrides + 1] = child::Override.Override
    elseif child.__type == 'Filter' then
      self.filters[#self.filters + 1] = child::Filter.Filter
    elseif child.__type == 'Fetch' then
      self.fetches[#self.fetches + 1] = child::Fetch.Fetch
    elseif child.__type == 'Validation' then
      self.validations[#self.validations + 1] = child::Validate.Validate
    elseif child.__type == 'Link' then
      self.links[#self.links + 1] = child::Link.Link
    end
  end

  return self
end

function Resource.with_default_signals(self: Resource, topic: string): Resource
  local signals = {
    Signal:create(topic, '#result'),
    Signal:update(topic, '#result'),
    Signal:remove(topic, '#result'),
    Signal:replace(topic, '#result'),
  }

  for _, signal in signals do
    self.signals[#self.signals + 1] = signal
  end

  return self
end

function Resource.with_expanded_signals(self: Resource, topic: string): Resource
  local signals = {
    Signal:create(topic, '#result.created'),
    Signal:update(topic, '#result.updated'),
    Signal:upsert(topic, '#result.updated'),
    Signal:remove(topic, '#result.removed'),
    Signal:replace(topic, '#result.removed', 'removed'),
    Signal:replace(topic, '#result.created', 'created'),
  }

  for _, signal in signals do
    self.signals[#self.signals + 1] = signal
  end

  return self
end

function Resource.unwrap_resource(self: Resource): UnwrappedResource
  local name = self.projection.name .. '_' .. self.unit.name
  local pascal_name = case.snakeToPascal(name)
  return {
    name = name,
    snake_name = name,
    camel_name = case.snakeToCamel(name),
    pascal_name = pascal_name,
    kebab_name = case.snakeToKebab(name),
    title = self.title or pascal_name,
    description = self.description,
  }
end

function Resource.unwrap_signals(self: Resource): UnwrappedSignals
  local signals: UnwrappedSignals = {}
  for i, signal in self.signals do
    local array = signals[signal.action] or Meta:array({})
    array[#array + 1] = signal:unwrap()
    signals[signal.action] = array
  end
  return signals
end

function Resource.unwrap_requests(self: Resource): Request.UnwrappedRequests
  local by_name: Request.UnwrappedRequests = {}

  for i, request in self.requests do
    by_name[request.name] = request:unwrap(self)
  end

  for i, request_name in { 'create', 'replace', 'update', 'upsert', 'select', 'get', 'remove', 'find' } do
    if not by_name[request_name] then
      local r = Request:from(request_name, self.unit)
      by_name[request_name] = r:unwrap(self)
    end
  end

  return by_name
end

export type UnwrappedViews = {
  by_view: {
    [string]: {string},
  },
  by_column: {
    [string]: {}
  }
}

function Resource.unwrap_views(self: Resource): UnwrappedViews
  local by_view = Meta:table {}
  local by_column = Meta:table {}

  for _, child in self.views do
    local unwrapped = child:unwrap()

    local columns = by_view[unwrapped.name] or Meta:array({})

    for i, c in unwrapped.columns do
      columns[#columns + 1] = c

      local views = by_column[c] or Meta:array({})
      views[#views + 1] = unwrapped.name
      by_column[c] = views
    end

    by_view[child.name] = columns
  end

  return {
    by_view = by_view,
    by_column = by_column,
  }
end

function Resource.unwrap(self: Resource): Unwrapped
  return {
    project = self.unit.module.parent.project:unwrap_project(),
    module = self.unit.module:unwrap_module(),
    unit = self.unit:unwrap_unit(),
    package = self.unit.module:unwrap_package(),
    entity = self.unit.entity:unwrap(),
    projection = self.projection:unwrap(),
    resource = self:unwrap_resource(),
    signals = self:unwrap_signals(),
    views = self:unwrap_views(),
    requests = self:unwrap_requests(),
    links = Wrapper:unwrap_array(self.links),
  }
end

return Resource
