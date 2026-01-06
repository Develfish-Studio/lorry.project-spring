--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Case = require('@lorry.utils/lib/Case')
local Project = require('@lorry.project/lib/Project')
local Wrapper = require('@lorry.project/lib/Wrapper')
local Unit = require('../Unit/Unit')
local Entity = require('../Unit/Entity/Entity')
local Module = require('../Module/Module')
local Target = require('./Target')
local Projection = require('./Projection')
local Signal = require('./Signal')
local View = require('./View')
local Request = require('./Request')
local Override = require('./Override')
local Filter = require('./Filter')
local Action = require('./Action')
local Link = require('./Link')
local Fetch = require('./Fetch')
local Validate = require('./Validate')

local Resource = {
  Fetch = Fetch,
  Filter = Filter,
  Signal = Signal,
  Override = Override,
  Validate = Validate,
  Request = Request,
  View = View,
  Link = Link,
}

export type Resource = typeof(Resource) & Target.Target

export type ResourceProps = {
  title: string?,
  description: string?,
  projection: Projection.Projection,
  unit: Unit.Unit,
  module: Module.Module?,
  signals: {Signal.Signal},
  views: {View.View},
  requests: {Request.Request},
  overrides: {Override.Override},
  filters: {Filter.Filter},
  fetches: {Fetch.Fetch},
  validations: {Validate.Validate},
  links: {Link.Link},
}


export type UnwrappedViews = {
  by_view: {
    [string]: {string},
  },
  by_column: {
    [string]: {}
  }
}

export type UnwrappedResource = Target.UnwrappedResource

export type UnwrappedSignals = {
  [string]: {Signal.Unwrapped}
}

export type Unwrapped = {
  project: Project.UnwrappedProject,
  module: Module.UnwrappedModule,
  unit: Unit.UnwrappedUnit,
  package: Module.UnwrappedPackage,
  unit_package: Module.UnwrappedPackage,
  unit_module: Module.UnwrappedModule,
  entity: Entity.Unwrapped,
  projection: Projection.Unwrapped,
  resource: UnwrappedResource,
  signals: UnwrappedSignals,
  views: UnwrappedViews,
  requests: Request.UnwrappedRequests,
  links: {Link.Unwrapped},
}

export type ResourceImpl = Resource & ResourceProps & Request.RequestOwner & Wrapper.Unwrappable<Unwrapped>

export type ConfigurerFunc = (this: ResourceImpl) -> ()

export type AnyChild =
  | Projection.Projection
  | Unit.Unit
  | View.View
  | Fetch.Fetch
  | Filter.Filter
  | Validate.Validate
  | Override.Override
  | Signal.Signal
  | Request.Request
  | Link.Link

function Resource:new(o: ResourceProps): Resource
  return Meta:type(o, self, "Resource")
end

function Resource:from(projection: Projection.Projection, unit: Unit.Unit, module: Module.Module?): Resource
  return Resource:new({
    projection = projection,
    unit = unit,
    module = module,
    views = Meta:array {},
    signals = Meta:array {},
    requests = Meta:array {},
    overrides = Meta:array {},
    filters = Meta:array {},
    fetches = Meta:array {},
    validations = Meta:array {},
    links = Meta:array {},
  })
end

function Resource:configure(configurer: {ConfigurerFunc}): Resource
  local this = self::ResourceImpl
  for _, func in configurer do
    func(this)
  end
  return this
end

function Resource:setup(children: {AnyChild}): Resource
  local this = self::ResourceImpl
  for _, child in children do
    this:with_child(child)
  end
  return this
end

function Resource:with_child(child: AnyChild): Resource
  local this = self::ResourceImpl
  local tag = Meta:typeof(child)
  if tag == 'Resource.Signal' then
    this.signals[#this.signals + 1] = child::Signal.Signal
  elseif tag == 'Resource.View' then
    this.views[#this.views + 1] = child::View.View
  elseif tag == 'Resource.Request' then
    this.requests[#this.requests + 1] = child::Request.Request
  elseif tag == 'Resource.Override' then
    this.overrides[#this.overrides + 1] = child::Override.Override
  elseif tag == 'Resource.Filter' then
    this.filters[#this.filters + 1] = child::Filter.Filter
  elseif tag == 'Resource.Fetch' then
    this.fetches[#this.fetches + 1] = child::Fetch.Fetch
  elseif tag == 'Resource.Validate' then
    this.validations[#this.validations + 1] = child::Validate.Validate
  elseif tag == 'Resource.Link' then
    this.links[#this.links + 1] = child::Link.Link
  end
  return this
end

function Resource:with_title(title: string): Resource
  local this = self::ResourceImpl
  this.title = title
  return this
end

function Resource:with_description(description: string): Resource
  local this = self::ResourceImpl
  this.description = description
  return this
end

function Resource:with_default_signals(topic: string): Resource
  local this = self::ResourceImpl
  return this:setup {
    Signal:create(topic, '#result'),
    Signal:update(topic, '#result'),
    Signal:remove(topic, '#result'),
    Signal:replace(topic, '#result'),
  }
end

function Resource:with_expanded_signals(topic: string): Resource
  local this = self::ResourceImpl
  return this:setup {
    Signal:create(topic, '#result.created'),
    Signal:update(topic, '#result.updated'),
    Signal:upsert(topic, '#result.updated'),
    Signal:remove(topic, '#result.removed'),
    Signal:replace(topic, '#result.removed', 'removed'),
    Signal:replace(topic, '#result.created', 'created'),
  }
end

function Resource:unwrap_resource(): UnwrappedResource
  local this = self::ResourceImpl
  local name = self.projection.name .. '_' .. self.unit.name
  local pascal_name = Case:snake_to_pascal(name)
  return {
    name = name,
    snake_name = name,
    pascal_name = pascal_name,
    camel_name = Case:snake_to_camel(name),
    kebab_name = Case:snake_to_kebab(name),
    title = this.title or pascal_name,
    description = this.description,
  }
end

function Resource:unwrap_signals(): UnwrappedSignals
  local this = self::ResourceImpl
  local signals: UnwrappedSignals = {}
  for i, signal in this.signals do
    local unwrapped = signal:unwrap()
    local array = signals[unwrapped.action] or Meta:array({})
    array[#array + 1] = unwrapped
    signals[unwrapped.action] = array
  end
  return signals
end

function Resource:unwrap_requests(): Request.UnwrappedRequests
  local this = self::ResourceImpl
  local by_name: Request.UnwrappedRequests = {}
  for i, request in this.requests do
    local unwrapped = request:unwrap_in_context(this)
    by_name[unwrapped.name] = unwrapped
  end
  for i, request_name in { 'create', 'replace', 'update', 'upsert', 'select', 'get', 'remove', 'find' } do
    if not by_name[request_name] then
      local r = Request:from(request_name, this.unit)
      by_name[request_name] = r:unwrap_in_context(this)
    end
  end
  return by_name
end

function Resource:unwrap_views(): UnwrappedViews
  local this = self::ResourceImpl
  local by_view = Meta:table {}
  local by_column = Meta:table {}
  for _, child in this.views do
    local unwrapped = child:unwrap()
    local columns = by_view[unwrapped.name] or Meta:array({})
    for i, c in unwrapped.columns do
      columns[#columns + 1] = c
      local views = by_column[c] or Meta:array({})
      views[#views + 1] = unwrapped.name
      by_column[c] = views
    end
    by_view[unwrapped.name] = columns
  end
  return {
    by_view = by_view,
    by_column = by_column,
  }
end

function Resource:unwrap_request_overrides(request: Request.RequestImpl): Wrapper.UnwrappedMap<Override.Unwrapped>
  local this = self::ResourceImpl
  local projection = this.projection::Projection.ProjectionImpl
  local overrides = Meta:table {}
  for _, item in projection.overrides do
    local unwrapped = item:unwrap()
    overrides[unwrapped.name] = unwrapped
  end
  for _, action in projection.actions do
    local action_impl = action::Action.ActionImpl
    if action_impl.method == request.name then
      for _, item in action_impl.overrides do
        local unwrapped = item:unwrap()
        overrides[unwrapped.name] = unwrapped
      end
    end
  end
  for _, item in this.overrides do
    local unwrapped = item:unwrap()
    overrides[unwrapped.name] = unwrapped
  end
  for _, item in request.overrides do
    local unwrapped = item:unwrap()
    overrides[unwrapped.name] = unwrapped
  end
  return overrides
end

function Resource:unwrap_request_filters(request: Request.RequestImpl): {Filter.Unwrapped}
  local this = self::ResourceImpl
  local projection = this.projection::Projection.ProjectionImpl
  local filters = Meta:array {}
  for _, item in projection.filters do
    local unwrapped = item:unwrap()
    filters[#filters + 1] = unwrapped
  end
  for _, action in projection.actions do
    local action_impl = action::Action.ActionImpl
    if action_impl.method == request.name then
      for _, item in action_impl.filters do
        local unwrapped = item:unwrap()
        filters[#filters + 1] = unwrapped
      end
    end
  end
  for _, item in this.filters do
    local unwrapped = item:unwrap()
    filters[#filters + 1] = unwrapped
  end
  for _, item in request.filters do
    local unwrapped = item:unwrap()
    filters[#filters + 1] = unwrapped
  end
  return filters
end

function Resource:unwrap_request_fetches(request: Request.RequestImpl): {Fetch.Unwrapped}
  local this = self::ResourceImpl
  local projection = this.projection::Projection.ProjectionImpl
  local fetches = Meta:array {}
  for _, item in projection.fetches do
    local unwrapped = item:unwrap()
    fetches[#fetches + 1] = unwrapped
  end
  for _, action in projection.actions do
    local action_impl = action::Action.ActionImpl
    if action_impl.method == request.name then
      for _, item in action_impl.fetches do
        local unwrapped = item:unwrap()
        fetches[#fetches + 1] = unwrapped
      end
    end
  end
  for _, item in this.fetches do
    local unwrapped = item:unwrap()
    fetches[#fetches + 1] = unwrapped
  end
  for _, item in request.fetches do
    local unwrapped = item:unwrap()
    fetches[#fetches + 1] = unwrapped
  end
  return fetches
end

function Resource:unwrap_request_validations(request: Request.RequestImpl): {Validate.Unwrapped}
  local this = self::ResourceImpl
  local projection = this.projection::Projection.ProjectionImpl
  local validations = Meta:array {}
  for _, item in projection.validations do
    local unwrapped = item:unwrap()
    validations[#validations + 1] = unwrapped
  end
  for _, action in projection.actions do
    local action_impl = action::Action.ActionImpl
    if action_impl.method == request.name then
      for _, item in action_impl.validations do
        local unwrapped = item:unwrap()
        validations[#validations + 1] = unwrapped
      end
    end
  end
  for _, item in this.validations do
    local unwrapped = item:unwrap()
    validations[#validations + 1] = unwrapped
  end
  for _, item in request.validations do
    local unwrapped = item:unwrap()
    validations[#validations + 1] = unwrapped
  end
  return validations
end

function Resource:unwrap_links(): {Link.Unwrapped}
  local this = self::ResourceImpl
  local links = Meta:array {}
  for _, link in this.links do
    local unwrapped = link:unwrap()
    links[#links + 1] = unwrapped
  end
  return links
end

function Resource:unwrap_module(): Module.UnwrappedModule
  local this = self::ResourceImpl
  if this.module ~= nil then
    return this.module:unwrap_module()
  end
  return this.unit.module:unwrap_module()
end

function Resource:unwrap_package(): Module.UnwrappedPackage
  local this = self::ResourceImpl
  if this.module ~= nil then
    return this.module:unwrap_package()
  end
  return this.unit.module:unwrap_package()
end

function Resource:unwrap(): Unwrapped
  local this = self::ResourceImpl
  local unit = this.unit::Unit.UnitImpl
  return {
    project = unit.module:unwrap_project(),
    module = this:unwrap_module(),
    unit = unit:unwrap_unit(),
    unit_module = unit.module:unwrap_module(),
    package = this:unwrap_package(),
    unit_package = unit.module:unwrap_package(),
    entity = unit.entity:unwrap(),
    projection = this.projection:unwrap(),
    resource = this:unwrap_resource(),
    signals = this:unwrap_signals(),
    views = this:unwrap_views(),
    requests = this:unwrap_requests(),
    links = this:unwrap_links(),
  }
end

return Resource
