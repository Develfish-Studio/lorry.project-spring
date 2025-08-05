local Meta = require('@develfish-repo.core/Meta')
local Wrapper = require('@develfish-repo.core/Wrapper')
local case = require('@develfish-repo.core/util/string/case')

export type Formula = Wrapper.Unwrappable<Unwrapped> & {
  __type: 'Formula',
  name: string,
  java_type: string,
  db_type: string,
  user_type: string?,
  is_lob: boolean?,
  formula: string,

  with_column_definition: (column_definition: string) -> Formula,
  with_user_type: (user_type: string) -> Formula,
  with_lob: (is_lob: boolean) -> Formula,
}

export type Unwrapped = {
  name: string,
  snake_name: string,
  camel_name: string,
  pascal_name: string,
  java_type: string,
  db_type: string,
  user_type: string?,
  is_lob: boolean?,
  formula: string,
}

local Formula = {
  __type = 'Formula',
  name = nil,
  java_type = nil,
  db_type = nil,
  user_type = nil,
  is_lob = nil,
  formula = nil,
}

function Formula:new(o): Formula
  return Meta:type(o, self)
end

function Formula:uuid(name: string, formula: string): Formula
  return Formula:new({
    name = name,
    java_type = "java.util.UUID",
    db_type = "uuid",
    formula = formula
  })
end

function Formula:text(name: string, formula: string): Formula
  return Formula:new({
    name = name,
    java_type = "java.lang.String",
    db_type = "text",
    formula = formula
  })
end

function Formula:decimal(name: string, formula: string): Formula
  return Formula:new({
    name = name,
    java_type = "java.math.BigDecimal",
    db_type = "numeric(38,2)",
    formula = formula
  })
end

function Formula:int(name: string, formula: string): Formula
  return Formula:new({
    name = name,
    java_type = "java.lang.Integer",
    db_type = "int4",
    formula = formula
  })
end

function Formula:long(name: string, formula: string): Formula
  return Formula:new({
    name = name,
    java_type = "java.lang.Long",
    db_type = "int8",
    formula = formula
  })
end

function Formula:boolean(name: string, formula: string): Formula
  return Formula:new({
    name = name,
    java_type = "java.lang.Boolean",
    db_type = "boolean",
    formula = formula
  })
end

function Formula:datetime(name: string, formula: string): Formula
  return Formula:new({
    name = name,
    java_type = "java.time.LocalDateTime",
    db_type = "timestamp(6)",
    formula = formula
  })
end

function Formula:datetime_tz(name: string, formula: string): Formula
  return Formula:new({
    name = name,
    java_type = "java.time.ZonedDateTime",
    db_type = "timestamp(6) with time zone",
    formula = formula
  })
end

function Formula:json(name: string, formula: string): Formula
  return Formula:new({
    name = name,
    java_type = "com.fasterxml.jackson.databind.JsonNode",
    db_type = "json",
    formula = formula
  })
end

function Formula:jsonb(name: string, formula: string): Formula
  return Formula:new({
    name = name,
    java_type = "com.fasterxml.jackson.databind.JsonNode",
    db_type = "jsonb",
    formula = formula
  })
end

function Formula:with_column_definition(column_definition: string): Formula
  self.column_definition = column_definition
  return self
end

function Formula:with_user_type(user_type: string): Formula
  self.user_type = user_type
  return self
end

function Formula:with_lob(is_lob: boolean): Formula
  if is_lob == nil then
    is_lob = true
  end
  self.is_lob = is_lob
  return self
end

function Formula.unwrap(self: Formula): Unwrapped
  return {
    name = self.name,
    snake_name = self.name,
    camel_name = case.snakeToCamel(self.name),
    pascal_name = case.snakeToPascal(self.name),
    formula = self.formula,
    java_type = self.java_type,
    db_type = self.db_type,
    user_type = self.user_type,
    is_lob = self.is_lob,
  }
end

return Formula