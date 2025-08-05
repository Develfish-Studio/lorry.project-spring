local Meta = require('@develfish-repo.core/Meta')
local Wrapper = require('@develfish-repo.core/Wrapper')
local Module = require('@develfish-repo.spring/Module')
local case = require('@develfish-repo.core/util/string/case')

export type Ref = Config & Wrapper.Unwrappable<Unwrapped> & {
  __type: 'Ref',
  variant: string,

  unwrap_unit: (self: Ref) -> UnwrappedUnit,
}

export type Config = {
  name: string,
  unit: {
    name: string,
    module: Module.Module,
  },
  column: string,
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

local Ref = {
  __type = 'Ref',
  variant = nil,
  name = nil,
  unit = nil,
  column = nil,
}

function Ref:new(o): Ref
  return Meta:type(o, self)
end

function Ref:one(options: Config): Ref
  return Ref:new({
    variant = 'one',
    name = options.name,
    unit = options.unit,
    column = options.column,
  })
end

function Ref:many(options: Config): Ref
  return Ref:new({
    variant = 'many',
    name = options.name,
    unit = options.unit,
    column = options.column,
  })
end

function Ref.unwrap_unit(self: Ref): UnwrappedUnit
  return {
    package = self.unit.module:unwrap_package(),
    camel_name = case.snakeToCamel(self.unit.name),
    kebab_name = case.snakeToKebab(self.unit.name),
    pascal_name = case.snakeToPascal(self.unit.name),
  }
end

function Ref.unwrap(self: Ref): Unwrapped
  return {
    unit = self:unwrap_unit(),
    variant = self.variant,
    column = self.column,
    name = self.name,
    camel_name = case.snakeToCamel(self.name),
    kebab_name = case.snakeToKebab(self.name),
    pascal_name = case.snakeToPascal(self.name),
  }
end

return Ref
