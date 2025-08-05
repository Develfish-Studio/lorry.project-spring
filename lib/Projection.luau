local Meta = require('@develfish-repo.core/Meta')
local Wrapper = require('@develfish-repo.core/Wrapper')
local Override = require('@develfish-repo.spring/resource/Override')
local Filter = require('@develfish-repo.spring/resource/Filter')
local Fetch = require('@develfish-repo.spring/resource/Fetch')
local Validate = require('@develfish-repo.spring/resource/Validate')
local Action = require('@develfish-repo.spring/security/Action')
local Auth = require('@develfish-repo.spring/security/Auth')

export type Projection = Wrapper.Unwrappable<Unwrapped> & {
  __type: 'Projection',

  name: string,
  actions: {Action.Action},
  context: {Auth.Auth},
  overrides: {Override.Override},
  filters: {Filter.Filter},
  fetches: {Fetch.Fetch},
  validations: {Validate.Validate},

  with_rules: (self: Projection, children: {any}) -> Projection,

  unwrap_context: (self: Projection) -> UnwrappedIndexedByName<Auth.Unwrapped>,
  unwrap_actions: (self: Projection) -> UnwrappedIndexedByMethod<Action.Unwrapped>,
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

local Projection = {
  __type = 'Projection',

  Override = Override,
  Filter = Filter,
  Validate = Validate,

  name = nil,
  actions = nil,
  context = nil,
  overrides = nil,
  filters = nil,
  fetches = nil,
  validations = nil,
}

function Projection:new(o): Projection
  return Meta:type(o, self)
end

function Projection:from(name: string, children: {any}?): Projection
  local rules = children or Meta:array {}
  return Projection
    :new({
      name = name,
      actions = Meta:array {},
      context = Meta:array {},
      overrides = Meta:array {},
      filters = Meta:array {},
      fetches = Meta:array {},
      validations = Meta:array {},
    })
    :with_rules(rules)
end

function Projection.with_rules(self: Projection, children: {any}): Projection
  for _, child in children do
    if child.__type == 'Action' then
      self.actions[#self.actions + 1] = child::Action.Action
    elseif child.__type == 'Auth' then
      self.context[#self.context + 1] = child::Auth.Auth
    elseif child.__type == 'Override' then
      self.overrides[#self.overrides + 1] = child::Override.Override
    elseif child.__type == 'Filter' then
      self.filters[#self.filters + 1] = child::Filter.Filter
    elseif child.__type == 'Fetch' then
      self.fetches[#self.fetches + 1] = child::Fetch.Fetch
    elseif child.__type == 'Validation' then
      self.validations[#self.validations + 1] = child::Validate.Validate
    end
  end

  return self
end

function Projection.unwrap_actions(self: Projection): UnwrappedIndexedByMethod<Action.Unwrapped>
  local by_method = {}
  local array = {}

  for i, item in self.actions do
    local unwrapped = item:unwrap()
    array[i] = unwrapped
    by_method[item.method] = unwrapped
  end

  return {
    by_method = by_method,
    array = array
  }
end

function Projection.unwrap_context(self: Projection): UnwrappedIndexedByName<Auth.Unwrapped>
  local by_name = {}
  local array = {}

  for i, item in self.context do
    local unwrapped = item:unwrap()
    array[i] = unwrapped
    by_name[item.name] = unwrapped
  end

  return {
    by_name = by_name,
    array = array
  }
end

function Projection.unwrap(self: Projection): Unwrapped
  return {
    name = self.name,
    actions = self:unwrap_actions(),
    context = self:unwrap_context(),
  }
end

return Projection
