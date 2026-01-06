--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Wrapper = require('@lorry.project/lib/Wrapper')
local Unit = require('../Unit/Unit')
local Entity = require('../Unit/Entity/Entity')
local Key = require('../Unit/Entity/Key')
local Prop = require('../Unit/Entity/Prop')
local Ref = require('../Unit/Entity/Ref')
local Fetch = require('./Fetch')
local Filter = require('./Filter')
local Override = require('./Override')
local Validate = require('./Validate')

local Request = {}

export type Request = typeof(Request)

export type RequestProps = {
  name: string,
  unit: Unit.Unit,
  filters: {Filter.Filter},
  overrides: {Override.Override},
  fetches: {Fetch.Fetch},
  validations: {Validate.Validate},
}

export type Unwrapped = {
  name: string,
  keys: Entity.UnwrappedIndexed<Key.Key>,
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

export type RequestImpl = Request & RequestProps

export type RequestOwner = {
  unwrap_request_overrides: (self: RequestOwner, request: RequestImpl) -> Wrapper.UnwrappedMap<Override.Unwrapped>,
  unwrap_request_filters: (self: RequestOwner, request: RequestImpl) -> {Filter.Unwrapped},
  unwrap_request_fetches: (self: RequestOwner, request: RequestImpl) -> {Fetch.Unwrapped},
  unwrap_request_validations: (self: RequestOwner, request: RequestImpl) -> {Validate.Unwrapped},
}

export type ConfigurerFunc = (this: RequestImpl) -> ()

export type AnyChild =
  | Filter.Filter
  | Fetch.Fetch
  | Validate.Validate
  | Override.Override

function Request:new(o: RequestProps): Request
  return Meta:type(o, self, "Resource.Request")
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

function Request:configure(configurer: {ConfigurerFunc}): Request
  local this = self::RequestImpl
  for _, func in configurer do
    func(this)
  end
  return this
end

function Request:setup(children: {AnyChild}): Request
  local this = self::RequestImpl
  for _, child in children do
    this:with_child(child)
  end
  return this
end

function Request:with_child(child: AnyChild): Request
  local this = self::RequestImpl
  local tag = Meta:typeof(child)
  if tag == 'Resource.Filter' then
    this.filters[#this.filters + 1] = child::Filter.Filter
  elseif tag == 'Resource.Fetch' then
    this.fetches[#this.fetches + 1] = child::Fetch.Fetch
  elseif tag == 'Resource.Override' then
    this.overrides[#this.overrides + 1] = child::Override.Override
  elseif tag == 'Resource.Validate' then
    this.validations[#this.validations + 1] = child::Validate.Validate
  end
  return this
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

function Request:unwrap_keys(overrides: {[string]: Override.Unwrapped}): Entity.UnwrappedIndexed<PK.PK>
  local this = self::RequestImpl
  local unit = this.unit::Unit.UnitImpl
  local columns = unit.entity:unwrap_keys()
  return associate_children(columns.array, overrides)
end

function Request:unwrap_columns(overrides: {[string]: Override.Unwrapped}): Entity.UnwrappedIndexed<Prop.Unwrapped>
  local this = self::RequestImpl
  local unit = this.unit::Unit.UnitImpl
  local columns = unit.entity:unwrap_columns()
  return associate_children(columns.array, overrides)
end

function Request:unwrap_refs(overrides: {[string]: Override.Unwrapped}): Entity.UnwrappedIndexed<Ref.Unwrapped>
  local this = self::RequestImpl
  local unit = this.unit::Unit.UnitImpl
  local columns = unit.entity:unwrap_refs()
  return associate_children(columns.array, overrides)
end

function Request:unwrap_in_context(owner: RequestOwner): Unwrapped
  local this = self::RequestImpl
  local overrides = owner:unwrap_request_overrides(this)
  local filters = owner:unwrap_request_filters(this)
  local fetches = owner:unwrap_request_fetches(this)
  local validations = owner:unwrap_request_validations(this)

  local keys = this:unwrap_keys(overrides)
  local columns = this:unwrap_columns(overrides)
  local refs = this:unwrap_refs(overrides)

  return {
    name = this.name,
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
