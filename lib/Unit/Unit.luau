--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Case = require('@lorry.utils/lib/Case')
local Wrapper = require('@lorry.project/lib/Wrapper')
local Project = require('@lorry.project/lib/Project')
local Module = require('../Module/Module')
local Entity = require('./Entity/Entity')

local Unit = {
  Entity = Entity
}

export type Unit = typeof(Unit) & Wrapper.Unwrappable<Unwrapped> & {
  name: string,
  module: Module.Module,
}

export type UnitProps = {
  name: string,
  module: Module.Module,
  entity: Entity.Entity,
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

export type UnitImpl = Unit & UnitProps

export type ConfigurerFunc = (this: UnitImpl) -> ()

export type AnyChild =
  | Module.Module
  | Entity.Entity
  | Entity.AnyChild

function Unit:new(o: UnitProps): Unit
  return Meta:type(o, self, 'Unit')
end

function Unit:from_table(module: Module.Module, table_name: string, children: {any}?): Unit
  assert(module ~= nil)
  local name = Case:prop_to_snake(table_name)
  return Unit:new({
    module = module,
    name = name,
    entity = Entity:from(table_name, children or Meta:array {}),
  })
end

function Unit:configure(configurer: {ConfigurerFunc}): Unit
  local this = self::UnitImpl
  for _, func in configurer do
    func(this)
  end
  return this
end

function Unit:setup(children: {AnyChild}): Unit
  local this = self::UnitImpl
  for _, child in children do
    this:with_child(child)
  end
  return self
end

function Unit:with_child(child: AnyChild): Unit
  local this = self::UnitImpl
  local tag = Meta:typeof(child)
  if tag == 'Module' then
    this.module = child::Module.Module
  elseif tag == 'Unit.Entity' then
    this.entity = child::Entity.Entity
  else
    this.entity:with_child(child::Entity.AnyChild)
  end
  return this
end

function Unit:unwrap_unit(): UnwrappedUnit
  local this = self::UnitImpl
  return {
    name = this.name,
    snake_name = this.name,
    camel_name = Case:snake_to_camel(this.name),
    pascal_name = Case:snake_to_pascal(this.name),
    kebab_name = Case:snake_to_kebab(this.name),
  }
end

function Unit:unwrap(): Unwrapped
  local this = self::UnitImpl
  return {
    project = this.module:unwrap_project(),
    module = this.module:unwrap_module(),
    package = this.module:unwrap_package(),
    entity = this.entity:unwrap(),
    unit = this:unwrap_unit(),
  }
end

return Unit
