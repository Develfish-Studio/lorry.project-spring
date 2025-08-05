local Meta = require('@develfish-repo.core/Meta')
local Wrapper = require('@develfish-repo.core/Wrapper')
local Module = require('@develfish-repo.spring/Module')
local Unit = require('@develfish-repo.spring/Unit')
local case = require('@develfish-repo.core/util/string/case')

export type Fetch = Wrapper.Unwrappable<Unwrapped> & {
  __type: 'Fetch',
  unit: Unit.Unit,
  name: string,
  value: string?,
  expression: string?,
  path: string?,
  is_optional: boolean?,

  with_is_optional: (self: Fetch, is_optional: boolean?) -> Fetch,
}

export type Unwrapped = {
  name: string,
  snake_name: string,
  camel_name: string,
  pascal_name: string,
  kebab_name: string,
  package: Module.UnwrappedPackage,
  unit: Unit.UnwrappedUnit,
  value: string?,
  expression: string?,
  path: Wrapper.UnwrappedPath?,
  is_optional: boolean?,
}

export type Data = {
  value: string?,
  expression: string?,
  path: string?,
  is_optional: boolean?,
}

local Fetch = {
  __type = 'Fetch',
  unit = nil,
  name = nil,
  value = nil,
  path = nil,
  expression = nil,
  is_optional = nil,
}

function Fetch:new(o): Fetch
  return Meta:type(o, self)
end

function Fetch:from(unit: Unit.Unit, name: string, options: Data?): Fetch
  local opts = options or Meta:table {}
  return Fetch:new({
    unit = unit,
    name = name,
    value = opts.value,
    expression = opts.expression,
    path = opts.path,
    is_optional = opts.is_optional,
  })
end

function Fetch:by_value(unit: Unit.Unit, name: string, value: string): Fetch
  return Fetch:from(unit, name, {
    value = value,
  })
end

function Fetch:by_expression(unit: Unit.Unit, name: string, expression: string): Fetch
  return Fetch:from(unit, name, {
    expression = expression,
  })
end

function Fetch:by_path(unit: Unit.Unit, name: string, path: string): Fetch
  return Fetch:from(unit, name, {
    path = path
  })
end

function Fetch.with_is_optional(self: Fetch, is_optional: boolean?): Fetch
  if is_optional == nil then
    is_optional = true
  end

  self.is_optional = is_optional
  return self
end

function Fetch.unwrap(self: Fetch): Unwrapped
  return {
    name = self.name,
    snake_name = self.name,
    camel_name = case.snakeToCamel(self.name),
    pascal_name = case.snakeToPascal(self.name),
    kebab_name = case.snakeToKebab(self.name),
    package = self.unit.module:unwrap_package(),
    unit = self.unit:unwrap_unit(),
    value = self.value,
    expression = self.expression,
    path = Wrapper:unwrap_path(self.path),
    is_optional = self.is_optional,
  }
end

return Fetch
