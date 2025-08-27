--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Case = require('@lorry.utils/lib/Case')
local Wrapper = require('@lorry.project/lib/Wrapper')

local Filter = {}

export type Filter = typeof(Filter) & Wrapper.Unwrappable<Unwrapped>

export type FilterProps = {
  name: string,
  value: string?,
  expression: string?,
  path: string?,
  is_optional: boolean?,
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

export type FilterImpl = Filter & FilterProps

function Filter:new(o: FilterProps): Filter
  return Meta:type(o, self, "Resource.Filter")
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

function Filter:with_optional(is_optional: boolean?): Filter
  local this = self::FilterImpl
  this.is_optional = is_optional == nil or is_optional == true
  return this
end

function Filter:unwrap(): Unwrapped
  local this = self::FilterImpl
  return {
    name = this.name,
    snake_name = this.name,
    camel_name = Case:snake_to_camel(this.name),
    pascal_name = Case:snake_to_pascal(this.name),
    kebab_name = Case:snake_to_kebab(this.name),
    value = this.value,
    expression = this.expression,
    path = Wrapper:unwrap_path(this.path),
    is_optional = this.is_optional,
  }
end

return Filter
