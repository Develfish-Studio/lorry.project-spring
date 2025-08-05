local Meta = require('@develfish-repo.core/Meta')
local Wrapper = require('@develfish-repo.core/Wrapper')
local Project = require('@develfish-repo.core/Project')
local Module = require('@develfish-repo.spring/Module')
local Entity = require('@develfish-repo.spring/jpa/Entity')
local case = require('@develfish-repo.core/util/string/case')

export type Unit = Wrapper.Unwrappable<Unwrapped> & {
  __type: 'Unit',
  module: Module.Module,
  name: string,
  entity: Entity.Entity,

  with_columns: (self: Unit, children: {any}) -> Unit,

  unwrap_unit: (self: Unit) -> UnwrappedUnit,
}

export type Unwrapped = {
  project: Project.UnwrappedProject,
  module: Module.UnwrappedModule,
  unit: UnwrappedUnit,
  package: Module.UnwrappedPackage,
  entity: Entity.Unwrapped,
}

export type UnwrappedUnit = {
  name: string,
  snake_name: string,
  camel_name: string,
  pascal_name: string,
  kebab_name: string,
}

local Unit = {
  __type = 'Unit',
  module = nil,
  name = nil,
  entity = nil,
}

function Unit:new(o): Unit
  return Meta:type(o, self)
end

function Unit:from(module: Module.Module, table_name: string, children: {any}?): Unit
  assert(module ~= nil)
  local name = case.propToSnake(table_name)
  return Unit:new({
    module = module,
    name = name,
    entity = Entity:from(table_name, children or Meta:array {}),
  })
end

function Unit.with_columns(self: Unit, children: {any}): Unit
  self.entity:with_columns(children)
  return self
end

function Unit.unwrap_unit(self: Unit): UnwrappedUnit
  return {
    name = self.name,
    snake_name = self.name,
    camel_name = case.snakeToCamel(self.name),
    pascal_name = case.snakeToPascal(self.name),
    kebab_name = case.snakeToKebab(self.name),
  }
end

function Unit.unwrap(self: Unit): Unwrapped
  return {
    project = self.module.parent.project:unwrap_project(),
    module = self.module:unwrap_module(),
    unit = self:unwrap_unit(),
    package = self.module:unwrap_package(),
    entity = self.entity:unwrap(),
  }
end

return Unit
