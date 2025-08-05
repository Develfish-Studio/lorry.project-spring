local Meta = require('@develfish-repo.core/Meta')
local Wrapper = require('@develfish-repo.core/Wrapper')
local case = require('@develfish-repo.core/util/string/case')

export type Filter = Wrapper.Unwrappable<Unwrapped> & {
  __type: 'Filter',
  name: string,
  value: string?,
  expression: string?,
  path: string?,
  is_optional: boolean?,

  with_is_optional: (self: Filter, is_optional: boolean?) -> Filter,
}

export type Unwrapped = {
  name: string,
  snake_name: string,
  camel_name: string,
  pascal_name: string,
  kebab_name: string,
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

local Filter = {
  __type = 'Filter',
  name = nil,
  value = nil,
  expression = nil,
  path = nil,
  is_optional = nil,
}

function Filter:new(o): Filter
  return Meta:type(o, self)
end

function Filter:from(name: string, options: Data?): Filter
  local opts = options or Meta:table {}
  return Filter:new({
    name = name,
    value = opts.value,
    expression = opts.expression,
    path = opts.path,
    is_optional = opts.is_optional,
  })
end

function Filter:from_value(name: string, value: string): Filter
  return Filter:from(name, {
    value = value
  })
end

function Filter:from_expression(name: string, expression: string): Filter
  return Filter:from(name, {
    expression = expression
  })
end

function Filter:from_path(name: string, path: string): Filter
  return Filter:from(name, {
    path = path
  })
end

function Filter.with_is_optional(self: Filter, is_optional: boolean?): Filter
  if is_optional == nil then
    is_optional = true
  end

  self.is_optional = is_optional
  return self
end

function Filter.unwrap(self: Filter): Unwrapped
  return {
    name = self.name,
    snake_name = self.name,
    camel_name = case.snakeToCamel(self.name),
    pascal_name = case.snakeToPascal(self.name),
    kebab_name = case.snakeToKebab(self.name),
    value = self.value,
    expression = self.expression,
    path = Wrapper:unwrap_path(self.path),
    is_optional = self.is_optional,
  }
end

return Filter
