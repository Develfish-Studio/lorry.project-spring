local Meta = require('@develfish-repo.core/Meta')
local Wrapper = require('@develfish-repo.core/Wrapper')
local case = require('@develfish-repo.core/util/string/case')

export type PK = Wrapper.Unwrappable<Unwrapped> & {
  __type: 'PK',
  name: string,
  updatable: string,
  generator_type: string,
  java_type: string,
  db_type: string,
  column_definition: string,
}

export type Unwrapped = {
  name: string,
  snake_name: string,
  camel_name: string,
  pascal_name: string,
  updatable: string,
  generator_type: string,
  java_type: string,
  db_type: string,
  column_definition: string,
}

local PK = {
  __type = 'PK',
  name = nil,
  updatable = "false",
  generator_type = nil,
  java_type = nil,
  db_type = nil,
  column_definition = nil,
}

function PK:new(o): PK
  return Meta:type(o, self)
end

function PK:uuid(name: string): PK
  return PK:new({
    name = name,
    generator_type = "random",
    java_type = "java.util.UUID",
    db_type = "uuid",
    column_definition = "uuid"
  })
end

function PK:text(name: string): PK
  return PK:new({
    name = name,
    java_type = "java.lang.String",
    db_type = "text",
    column_definition = "text"
  })
end

function PK:decimal(name: string): PK
  return PK:new({
    name = name,
    java_type = "java.math.BigDecimal",
    db_type = "numeric(38,2)"
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

function PK.unwrap(self: PK): Unwrapped
  return {
    name = self.name,
    snake_name = self.name,
    camel_name = case.snakeToCamel(self.name),
    pascal_name = case.snakeToPascal(self.name),
    updatable = self.updatable,
    generator_type = self.generator_type,
    java_type = self.java_type,
    db_type = self.db_type,
    column_definition = self.column_definition,
  }
end

return PK
