--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Case = require('@develfish-repo.utils/lib/Case')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')
local Module = require('../Module/Module')
local Unit = require('../Unit/Unit')

local Fetch = {}

export type Fetch = typeof(Fetch) & Wrapper.Unwrappable<Unwrapped>

export type FetchProps = {
  unit: Unit.Unit,
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

export type FetchImpl = Fetch & FetchProps

function Fetch:new(o: FetchProps): Fetch
  return Meta:type(o, self, "Resource.Fetch")
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

function Fetch:with_optional(is_optional: boolean?): Fetch
  local this = self::FetchImpl
  this.is_optional = is_optional == nil or is_optional == true
  return this
end

function Fetch:unwrap(): Unwrapped
  local this = self::FetchImpl
  return {
    name = this.name,
    snake_name = this.name,
    camel_name = Case:snake_to_camel(this.name),
    pascal_name = Case:snake_to_pascal(this.name),
    kebab_name = Case:snake_to_kebab(this.name),
    package = this.unit.module:unwrap_package(),
    unit = this.unit:unwrap_unit(),
    value = this.value,
    expression = this.expression,
    path = Wrapper:unwrap_path(this.path),
    is_optional = this.is_optional,
  }
end

return Fetch
