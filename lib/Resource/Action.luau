--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')
local Role = require('./Role')
local Override = require('./Override')
local Filter = require('./Filter')
local Fetch = require('./Fetch')
local Validate = require('./Validate')

local Action = {
  Role = Role,
  Fetch = Fetch,
  Filter = Filter,
  Override = Override,
  Validate = Validate,
}

export type Action = typeof(Action) & Wrapper.Unwrappable<Unwrapped>

export type ActionProps = {
  method: string,
  role: Role.Role,
  route: string?,
  fetches: {Fetch.Fetch},
  filters: {Filter.Filter},
  overrides: {Override.Override},
  validations: {Validate.Validate},
}

export type Unwrapped = {
  method: string,
  route: string?,
  role: Role.Unwrapped,
}

export type ActionImpl = Action & ActionProps


export type ConfigurerFunc = (this: ActionImpl) -> ()

export type AnyChild =
  | Role.Role
  | Fetch.Fetch
  | Filter.Filter
  | Validate.Validate
  | Override.Override

function Action:new(o: ActionProps): Action
  return Meta:type(o, self, "Resource.Action")
end

function Action:from(method: string, role: string): Action
  return Action:new({
    method = method,
    role = Role:from(role),
    overrides = Meta:array {},
    filters = Meta:array {},
    fetches = Meta:array {},
    validations = Meta:array {},
  })
end

function Action:configure(configurer: {ConfigurerFunc}): Action
  local this = self::ActionImpl
  for _, func in configurer do
    func(this)
  end
  return this
end

function Action:setup(children: {AnyChild}): Action
  local this = self::ActionImpl
  for _, child in children do
    this:with_child(child)
  end
  return this
end

function Action:with_child(child: AnyChild): Action
  local this = self::ActionImpl
  local tag = Meta:typeof(child)
  if tag == 'Resource.Role' then
    this.role = child::Role.Role
  elseif tag == 'Resource.Fetch' then
    this.fetches[#this.fetches + 1] = child::Fetch.Fetch
  elseif tag == 'Resource.Filter' then
    this.filters[#this.filters + 1] = child::Filter.Filter
  elseif tag == 'Resource.Validate' then
    this.validations[#this.validations + 1] = child::Validate.Validate
  elseif tag == 'Resource.Override' then
    this.overrides[#this.overrides + 1] = child::Override.Override
  end
  return this
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

function Action:with_route(route: string): Action
  local this = self::ActionImpl
  this.route = route
  return this
end

function Action:unwrap(): Unwrapped
  local this = self::ActionImpl
  return {
    method = this.method,
    route = this.route,
    role = this.role:unwrap(),
  }
end

return Action
