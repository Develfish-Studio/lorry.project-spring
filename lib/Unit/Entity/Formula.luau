--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Case = require('@develfish-repo.utils/lib/Case')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')

local Formula = {}

export type Formula = typeof(Formula) & Wrapper.Unwrappable<Unwrapped>

export type FormulaProps = {
  name: string,
  java_type: string,
  db_type: string,
  user_type: string?,
  is_lob: boolean?,
  column_definition: string?,
  formula: string,
}

export type Unwrapped = FormulaProps & {
  snake_name: string,
  camel_name: string,
  pascal_name: string,
}

export type FormulaImpl = Formula & FormulaProps

function Formula:new(o: FormulaProps): Formula
  return Meta:type(o, self, "Unit.Entity.Formula")
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
  local this = self::FormulaImpl
  this.column_definition = column_definition
  return this
end

function Formula:with_user_type(user_type: string): Formula
  local this = self::FormulaImpl
  this.user_type = user_type
  return this
end

function Formula:with_lob(is_lob: boolean?): Formula
  local this = self::FormulaImpl
  this.is_lob = is_lob == nil or is_lob == true
  return this
end

function Formula:unwrap(): Unwrapped
  local this = self::FormulaImpl
  return {
    name = this.name,
    snake_name = this.name,
    camel_name = Case:snake_to_camel(this.name),
    pascal_name = Case:snake_to_pascal(this.name),
    formula = this.formula,
    java_type = this.java_type,
    db_type = this.db_type,
    user_type = this.user_type,
    is_lob = this.is_lob,
  }
end

return Formula