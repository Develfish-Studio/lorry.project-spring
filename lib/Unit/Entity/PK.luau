--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Case = require('@lorry.utils/lib/Case')
local Wrapper = require('@lorry.project/lib/Wrapper')

local PK = {}

export type PK = typeof(PK) & Wrapper.Unwrappable<Unwrapped>

export type PKProps = {
  name: string,
  updatable: boolean?,
  generator_type: string?,
  java_type: string,
  db_type: string,
  column_definition: string?,
}

export type Unwrapped = {
  name: string,
  snake_name: string,
  camel_name: string,
  pascal_name: string,
  updatable: boolean?,
  generator_type: string?,
  java_type: string,
  db_type: string,
  column_definition: string?,
}

export type PKImpl = PK & PKProps

function PK:new(o: PKProps): PK
  return Meta:type(o, self, "Unit.Entity.PK")
end

function PK:uuid(name: string): PK
  return PK:new({
    name = name,
    generator_type = "random",
    java_type = "java.util.UUID",
    db_type = "uuid",
    column_definition = "uuid",
  })
end

function PK:text(name: string): PK
  return PK:new({
    name = name,
    java_type = "java.lang.String",
    db_type = "text",
    column_definition = "text",
  })
end

function PK:decimal(name: string): PK
  return PK:new({
    name = name,
    java_type = "java.math.BigDecimal",
    db_type = "numeric(38,2)",
  })
end

function PK:int(name: string): PK
  return PK:new({
    name = name,
    java_type = "java.lang.Integer",
    db_type = "int4"
  })
end

function PK:long(name: string): PK
  return PK:new({
    name = name,
    java_type = "java.lang.Long",
    db_type = "int8"
  })
end

function PK:unwrap(): Unwrapped
  local this = self::PKImpl
  return {
    name = this.name,
    snake_name = this.name,
    camel_name = Case:snake_to_camel(this.name),
    pascal_name = Case:snake_to_pascal(this.name),
    updatable = this.updatable,
    generator_type = this.generator_type,
    java_type = this.java_type,
    db_type = this.db_type,
    column_definition = this.column_definition,
  }
end

return PK
