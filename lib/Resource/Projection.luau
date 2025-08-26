--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')
local Action = require('./Action')
local Auth = require('./Auth')
local Override = require('./Override')
local Filter = require('./Filter')
-- local Link = require('./Link')
local Fetch = require('./Fetch')
local Validate = require('./Validate')

local Projection = {
  Auth = Auth,
  Action = Action,
  Fetch = Fetch,
  Filter = Filter,
  Validate = Validate,
  Override = Override,
}

export type Projection = typeof(Projection) & Wrapper.Unwrappable<Unwrapped>

export type ProjectionProps = {
  name: string,
  context: {Auth.Auth},
  actions: {Action.Action},
  filters: {Filter.Filter},
  fetches: {Fetch.Fetch},
  validations: {Validate.Validate},
  overrides: {Override.Override},
}

export type Unwrapped = {
  name: string,
  actions: UnwrappedIndexedByMethod<Action.Unwrapped>,
}

export type UnwrappedIndexedByName<T> = {
  by_name: {[string]: T},
  array: {T}
}

export type UnwrappedIndexedByMethod<T> = {
  by_method: {[string]: T},
  array: {T}
}

export type ProjectionImpl = Projection & ProjectionProps

export type ConfigurerFunc = (this: ProjectionImpl) -> ()

export type AnyChild =
  | Auth.Auth
  | Action.Action
  | Fetch.Fetch
  | Filter.Filter
  | Validate.Validate
  | Override.Override

function Projection:new(o: ProjectionProps): Projection
  return Meta:type(o, self, "Resource.Projection")
end

function Projection:from(name: string): Projection
  return Projection
    :new({
      name = name,
      context = Meta:array {},
      actions = Meta:array {},
      filters = Meta:array {},
      fetches = Meta:array {},
      overrides = Meta:array {},
      validations = Meta:array {},
    })
end

function Projection:configure(configurer: {ConfigurerFunc}): Projection
  local this = self::ProjectionImpl
  for _, func in configurer do
    func(this)
  end
  return this
end

function Projection:setup(children: {AnyChild}): Projection
  local this = self::ProjectionImpl
  for _, child in children do
    this:with_child(child)
  end
  return this
end

function Projection:with_child(child: AnyChild): Projection
  local this = self::ProjectionImpl
  local tag = Meta:typeof(child)
  if tag == 'Resource.Action' then
    self.actions[#self.actions + 1] = child::Action.Action
  elseif tag == 'Resource.Auth' then
    self.context[#self.context + 1] = child::Auth.Auth
  elseif tag == 'Resource.Override' then
    self.overrides[#self.overrides + 1] = child::Override.Override
  elseif tag == 'Resource.Filter' then
    self.filters[#self.filters + 1] = child::Filter.Filter
  elseif tag == 'Resource.Fetch' then
    self.fetches[#self.fetches + 1] = child::Fetch.Fetch
  elseif tag == 'Resource.Validation' then
    self.validations[#self.validations + 1] = child::Validate.Validate
  end
  return this
end

function Projection:unwrap_actions(): UnwrappedIndexedByMethod<Action.Unwrapped>
  local this = self::ProjectionImpl
  local by_method = {}
  local array = {}
  for i, item in this.actions do
    local unwrapped = item:unwrap()
    array[i] = unwrapped
    by_method[unwrapped.method] = unwrapped
  end
  return {
    by_method = by_method,
    array = array
  }
end

function Projection:unwrap_context(): UnwrappedIndexedByName<Auth.Unwrapped>
  local this = self::ProjectionImpl
  local by_name = {}
  local array = {}
  for i, item in this.context do
    local unwrapped = item:unwrap()
    array[i] = unwrapped
    by_name[unwrapped.name] = unwrapped
  end
  return {
    by_name = by_name,
    array = array
  }
end

function Projection:unwrap(): Unwrapped
  local this = self::ProjectionImpl
  return {
    name = this.name,
    actions = this:unwrap_actions(),
    context = this:unwrap_context(),
  }
end

return Projection
