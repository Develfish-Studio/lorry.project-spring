--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Case = require('@develfish-repo.utils/lib/Case')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')
local Module = require('../../Module/Module')

local Ref = {}

export type Ref = typeof(Ref) & Wrapper.Unwrappable<Unwrapped> & {
  variant: string,
}

export type RefConfig = {
  name: string,
  column: string,
  unit: {
    name: string,
    module: Module.Module,
  },
}

export type RefProps = RefConfig & {
  variant: string,
}

export type Unwrapped = {
  unit: UnwrappedUnit,
  variant: string,
  column: string,
  name: string,
  camel_name: string,
  kebab_name: string,
  pascal_name: string,
}

export type UnwrappedUnit = {
  package: Module.UnwrappedPackage,
  camel_name: string,
  kebab_name: string,
  pascal_name: string,
}

export type RefImpl = Ref & RefProps

function Ref:new(o: RefProps): RefImpl
  return Meta:type(o, self, 'Unit.Entity.Ref')
end

function Ref:one(options: RefConfig): Ref
  return Ref:new({
    variant = 'one',
    name = options.name,
    unit = options.unit,
    column = options.column,
  })
end

function Ref:many(options: RefConfig): Ref
  return Ref:new({
    variant = 'many',
    name = options.name,
    unit = options.unit,
    column = options.column,
  })
end

function Ref:unwrap_unit(): UnwrappedUnit
  local this = self::RefImpl
  return {
    package = this.unit.module:unwrap_package(),
    camel_name = Case:snake_to_camel(this.unit.name),
    kebab_name = Case:snake_to_kebab(this.unit.name),
    pascal_name = Case:snake_to_pascal(this.unit.name),
  }
end

function Ref:unwrap(): Unwrapped
  local this = self::RefImpl
  return {
    unit = this:unwrap_unit(),
    variant = this.variant,
    column = this.column,
    name = this.name,
    camel_name = Case:snake_to_camel(this.name),
    kebab_name = Case:snake_to_kebab(this.name),
    pascal_name = Case:snake_to_pascal(this.name),
  }
end

return Ref
