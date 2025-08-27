--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Project = require('@lorry.project/lib/Project')
local Unit = require('./Unit/Unit')
local Entity = require('./Unit/Entity/Entity')

local DDL = {}

export type DDL = typeof(DDL)

export type DDLProps = {
  project: Project.Project,
  unit: Unit.Unit,
  base_name: string?,
  create_name: string?,
  drop_name: string?,
}

export type Unwrapped = {
  project: Project.UnwrappedProject,
  entity: Entity.Unwrapped,
  directory: {
    base_name: string?,
    create_name: string?,
    drop_name: string?,
  }
}

export type DDLImpl = DDL & DDLProps

function DDL:new(o: DDLProps): DDL
  return Meta:type(o, self, "DDL")
end

function DDL:from(project: Project.Project, unit: Unit.Unit): DDL
  return DDL:new({
    project = project,
    unit = unit,
  })
end

function DDL:with_base_name(base_name: string)
  local this = self::DDLImpl
  this.base_name = base_name
  return this
end

function DDL:with_create_name(create_name: string)
  local this = self::DDLImpl
  this.create_name = create_name
  return this
end

function DDL:with_drop_name(drop_name: string)
  local this = self::DDLImpl
  this.drop_name = drop_name
  return this
end

function DDL:unwrap_directory()
  local this = self::DDLImpl
  return {
    base_name = this.base_name,
    create_name = this.create_name,
    drop_name = this.drop_name,
  }
end

function DDL:unwrap()
  local this = self::DDLImpl
  local unit = this.unit::Unit.UnitImpl
  return {
    project = this.project:unwrap_project(),
    entity = unit.entity:unwrap(),
    directory = this:unwrap_directory()
  }
end

return DDL
