local Meta = require('@develfish-repo.core/Meta')
local Wrapper = require('@develfish-repo.core/Wrapper')
local Role = require('@develfish-repo.spring/security/Role')
local Override = require('@develfish-repo.spring/resource/Override')
local Filter = require('@develfish-repo.spring/resource/Filter')
local Fetch = require('@develfish-repo.spring/resource/Fetch')
local Validate = require('@develfish-repo.spring/resource/Validate')

export type Action = Wrapper.Unwrappable<Unwrapped> & {
  __type: 'Action',

  method: string,
  role: string,
  route: string?,
  overrides: {Override.Override},
  filters: {Filter.Filter},
  fetches: {Fetch.Fetch},
  validations: {Validate.Validate},

  with_rules: (self: Action, children: {any}) -> Action,
  with_route: (self: Action, route: string) -> Action,
}

export type Unwrapped = {
  method: string,
  role: string,
  route: string?,
}

local Action = {
  __type = 'Action',

  Override = Override,
  Role = Role,
  Filter = Filter,
  Fetch = Fetch,
  Validate = Validate,

  method = nil,
  role = nil,
  route = nil,
  overrides = nil,
  filters = nil,
  fetches = nil,
  validations = nil,
}

function Action:new(o): Action
  return Meta:type(o, self)
end

function Action:from(method: string, role: string): Action
  return Action:new({
    method = method,
    role = role,
    overrides = Meta:array {},
    filters = Meta:array {},
    fetches = Meta:array {},
    validations = Meta:array {},
  })
end


function Action:create(role: string): Action
  return Action:from('create', role)
end

function Action:remove(role: string): Action
  return Action:from('remove', role)
end

function Action:delete(role: string): Action
  return Action:from('delete', role)
end

function Action:update(role: string): Action
  return Action:from('update', role)
end

function Action:upsert(role: string): Action
  return Action:from('upsert', role)
end

function Action:replace(role: string): Action
  return Action:from('replace', role)
end

function Action:get(role: string): Action
  return Action:from('get', role)
end

function Action:select(role: string): Action
  return Action:from('select', role)
end

function Action:find(role: string): Action
  return Action:from('find', role)
end

function Action.with_route(self: Action, route: string): Action
  self.route = route
  return self
end

function Action.with_rules(self: Action, children: {any}): Action
  children = children or Meta:array({})

  for _, child in children do
    if child.__type == 'Role' then
      self.role = child.expression
    elseif child.__type == 'Override' then
      self.overrides[#self.overrides + 1] = child::Override.Override
    elseif child.__type == 'Filter' then
      self.filters[#self.filters + 1] = child::Filter.Filter
    elseif child.__type == 'Fetch' then
      self.fetches[#self.fetches + 1] = child::Fetch.Fetch
    elseif child.__type == 'Validate' then
      self.validations[#self.validations + 1] = child::Validate.Validate
    end
  end

  return self
end

function Action.unwrap(self: Action): Unwrapped
  return {
    method = self.method,
    role = self.role,
    route = self.route,
  }
end

return Action
