local Meta = require('@develfish-repo.core/Meta')
local Wrapper = require('@develfish-repo.core/Wrapper')
local Spring = require('@develfish-repo.spring/Spring')
local Unit = require('@develfish-repo.spring/Unit')
-- local Projection = require('@develfish-repo.spring/Projection')
local Entity = require('@develfish-repo.spring/jpa/Entity')
local PK = require('@develfish-repo.spring/jpa/PK')
local Prop = require('@develfish-repo.spring/jpa/Prop')
local Ref = require('@develfish-repo.spring/jpa/Ref')
local Fetch = require('@develfish-repo.spring/resource/Fetch')
local Filter = require('@develfish-repo.spring/resource/Filter')
local Override = require('@develfish-repo.spring/resource/Override')
local Validate = require('@develfish-repo.spring/resource/Validate')

export type Request = Wrapper.Unwrappable<Unwrapped> & Spring.RequestRef & {
  __type: 'Request',

  name: string,
  unit: Unit.Unit,
  filters: {Filter.Filter},
  overrides: {Override.Override},
  fetches: {Fetch.Fetch},
  validations: {Validate.Validate},

  unwrap_overrides: (self: Request, parent_resource: Spring.ResourceRef) -> {[string]: Override.Unwrapped},
  unwrap_filters: (self: Request, parent_resource: Spring.ResourceRef) -> {Filter.Unwrapped},
  unwrap_fetches: (self: Request, parent_resource: Spring.ResourceRef) -> {Fetch.Unwrapped},

  unwrap_keys: (self: Request, overrides: {[string]: Override.Unwrapped}) -> Entity.UnwrappedIndexed<PK.PK>,
  unwrap_columns: (self: Request, overrides: {[string]: Override.Unwrapped}) -> Entity.UnwrappedIndexed<Prop.Unwrapped>,
  unwrap_refs: (self: Request, overrides: {[string]: Override.Unwrapped}) -> Entity.UnwrappedIndexed<Ref.Unwrapped>,
  unwrap_validations: (self: Request, parent_resource: Spring.ResourceRef) -> {Validate.Unwrapped},
}

export type Unwrapped = {
  name: string,
  keys: Entity.UnwrappedIndexed<PK.PK>,
  columns: Entity.UnwrappedIndexed<Prop.Unwrapped>,
  refs: Entity.UnwrappedIndexed<Ref.Unwrapped>,
  overrides: {[string]: Override.Unwrapped},
  filters: {Filter.Unwrapped},
  fetches: {Fetch.Unwrapped},
  validations: {Validate.Unwrapped},
}

export type UnwrappedRequests = {
  [string]: Unwrapped,
}

local Request = {
  __type = 'Request',
  name = nil,
  unit = nil,
  filters = Meta:array {},
  overrides = Meta:array {},
  fetches = Meta:array {},
  validations = Meta:array {},
}

function Request:new(o): Request
  return Meta:type(o, self)
end

function Request:from(name: string, unit: Unit.Unit): Request
  return Request:new({
    name = name,
    unit = unit,
    filters = Meta:array {},
    overrides = Meta:array {},
    fetches = Meta:array {},
    validations = Meta:array {},
  })
end

function Request:create(unit: Unit.Unit): Request
  return Request:from('create', unit)
end

function Request:update(unit: Unit.Unit): Request
  return Request:from('update', unit)
end

function Request:upsert(unit: Unit.Unit): Request
  return Request:from('upsert', unit)
end

function Request:remove(unit: Unit.Unit): Request
  return Request:from('remove', unit)
end

function Request:select(unit: Unit.Unit): Request
  return Request:from('select', unit)
end

function Request:replace(unit: Unit.Unit): Request
  return Request:from('replace', unit)
end

function Request:find(unit: Unit.Unit): Request
  return Request:from('find', unit)
end

function Request.with_rules(self: Request, children: {any}): Request
  for _, child in children do
    if child.__type == 'Filter' then
      self.filters[#self.filters + 1] = child::Filter.Filter
    elseif child.__type == 'Override' then
      self.overrides[#self.overrides + 1] = child::Override.Override
    elseif child.__type == 'Fetch' then
      self.fetches[#self.fetches + 1] = child::Fetch.Fetch
    elseif child.__type == 'Validate' then
      self.validations[#self.validations + 1] = child::Validate.Validate
    end
  end

  return self
end

function Request.with_overrides(self: Request, overrides: {Override.Override}): Request
  return Request.with_rules(self, overrides)
end

function Request.with_filters(self: Request, filters: {Filter.Filter}): Request
  return Request.with_rules(self, filters)
end

function Request.unwrap_overrides(self: Request, parent_resource: Spring.ResourceRef): {[string]: Override.Unwrapped}
  local overrides = Meta:table {}

  for _, item in parent_resource.projection.overrides do
    local unwrapped = item:unwrap()
    overrides[unwrapped.name] = unwrapped
  end

  for _, action in parent_resource.projection.actions do
    if action.method == self.name then
      for _, item in action.overrides do
        local unwrapped = item:unwrap()
        overrides[unwrapped.name] = unwrapped
      end
    end
  end

  for _, item in parent_resource.overrides do
    local unwrapped = item:unwrap()
    overrides[unwrapped.name] = unwrapped
  end

  for _, item in self.overrides do
    local unwrapped = item:unwrap()
    overrides[unwrapped.name] = unwrapped
  end

  return overrides
end

function Request.unwrap_filters(self: Request, parent_resource: Spring.ResourceRef): {Filter.Unwrapped}
  local filters = Meta:array {}

  for _, item in parent_resource.projection.filters do
    local unwrapped = item:unwrap()
    filters[#filters + 1] = unwrapped
  end

  for _, action in parent_resource.projection.actions do
    if action.method == self.name then
      for _, item in action.filters do
        local unwrapped = item:unwrap()
        filters[#filters + 1] = unwrapped
      end
    end
  end

  for _, item in parent_resource.filters do
    local unwrapped = item:unwrap()
    filters[#filters + 1] = unwrapped
  end

  for _, item in self.filters do
    local unwrapped = item:unwrap()
    filters[#filters + 1] = unwrapped
  end

  return filters
end

function Request.unwrap_fetches(self: Request, parent_resource: Spring.ResourceRef): {Fetch.Unwrapped}
  local fetches = Meta:array {}

  for _, item in parent_resource.projection.fetches do
    local unwrapped = item:unwrap()
    fetches[#fetches + 1] = unwrapped
  end

  for _, action in parent_resource.projection.actions do
    if action.method == self.name then
      for _, item in action.fetches do
        local unwrapped = item:unwrap()
        fetches[#fetches + 1] = unwrapped
      end
    end
  end

  for _, item in parent_resource.fetches do
    local unwrapped = item:unwrap()
    fetches[#fetches + 1] = unwrapped
  end

  for _, item in self.fetches do
    local unwrapped = item:unwrap()
    fetches[#fetches + 1] = unwrapped
  end

  return fetches
end

function Request.unwrap_validations(self: Request, parent_resource: Spring.ResourceRef): {Validate.Unwrapped}
  local validations = Meta:array {}

  for _, item in parent_resource.projection.validations do
    local unwrapped = item:unwrap()
    validations[#validations + 1] = unwrapped
  end

  for _, action in parent_resource.projection.actions do
    if action.method == self.name then
      for _, item in action.validations do
        local unwrapped = item:unwrap()1
        validations[#validations + 1] = unwrapped
      end
    end
  end

  for _, item in parent_resource.validations do
    local unwrapped = item:unwrap()
    validations[#validations + 1] = unwrapped
  end

  for _, item in self.validations do
    local unwrapped = item:unwrap()
    validations[#validations + 1] = unwrapped
  end

  return validations
end

function associate_children<T, R>(children: {T}, overrides: {[string]: Override.Unwrapped}): Entity.UnwrappedIndexed<R>
  local by_name: {[string]: R} = Meta:table {}
  local array: {R} = Meta:array {}

  for _, column in children do
    local override = overrides[column.name]
    column.override = override

    by_name[column.name] = column
    array[#array + 1] = column
  end

  return {
    by_name = by_name,
    array = array,
  }
end

function Request.unwrap_keys(self: Request, overrides: {[string]: Override.Unwrapped}): Entity.UnwrappedIndexed<PK.PK>
  local columns = self.unit.entity:unwrap_keys()
  return associate_children(columns.array, overrides)
end

function Request.unwrap_columns(self: Request, overrides: {[string]: Override.Unwrapped}): Entity.UnwrappedIndexed<Prop.Unwrapped>
  local columns = self.unit.entity:unwrap_columns()
  return associate_children(columns.array, overrides)
end

function Request.unwrap_refs(self: Request, overrides: {[string]: Override.Unwrapped}): Entity.UnwrappedIndexed<Ref.Unwrapped>
  local columns = self.unit.entity:unwrap_refs()
  return associate_children(columns.array, overrides)
end

function Request.unwrap(self: Request, parent_resource: Spring.ResourceRef): Unwrapped
  local overrides = self:unwrap_overrides(parent_resource)
  local filters = self:unwrap_filters(parent_resource)
  local fetches = self:unwrap_fetches(parent_resource)
  local validations = self:unwrap_validations(parent_resource)

  local keys = self:unwrap_keys(overrides)
  local columns = self:unwrap_columns(overrides)
  local refs = self:unwrap_refs(overrides)

  return {
    name = self.name,
    keys = keys,
    columns = columns,
    refs = refs,
    overrides = overrides,
    filters = filters,
    fetches = fetches,
    validations = validations,
  }
end

return Request
