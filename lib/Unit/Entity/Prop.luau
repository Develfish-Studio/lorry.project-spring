--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Case = require('@lorry.utils/lib/Case')
local Wrapper = require('@lorry.project/lib/Wrapper')

local Prop = {}

export type Prop = typeof(Prop) & Wrapper.Unwrappable<Unwrapped>

export type PropProps = {
  name: string,
  updatable: string?,
  java_type: string,
  db_type: string,
  column_definition: string?,
  user_type: string?,
  is_lob: boolean?,
}

export type Unwrapped = {
  name: string,
  snake_name: string,
  camel_name: string,
  pascal_name: string,
  updatable: string?,
  java_type: string,
  db_type: string,
  column_definition: string?,
  user_type: string?,
  is_lob: boolean?,
}

export type PropImpl = Prop & PropProps

function Prop:new(o: PropProps): Prop
  return Meta:type(o, self, 'Unit.Entity.Prop')
end

function Prop:uuid(name: string): Prop
  return Prop:new({
    name = name,
    java_type = "java.util.UUID",
    db_type = "uuid",
    column_definition = "uuid"
  })
end

function Prop:text(name: string): Prop
  return Prop:new({
    name = name,
    java_type = "java.lang.String",
    db_type = "text",
    column_definition = "text"
  })
end

function Prop:decimal(name: string): Prop
  return Prop:new({
    name = name,
    java_type = "java.math.BigDecimal",
    db_type = "numeric(38,2)"
  })
end

function Prop:int(name: string): Prop
  return Prop:new({
    name = name,
    java_type = "java.lang.Integer",
    db_type = "int4"
  })
end

function Prop:long(name: string): Prop
  return Prop:new({
    name = name,
    java_type = "java.lang.Long",
    db_type = "int8"
  })
end

function Prop:boolean(name: string): Prop
  return Prop:new({
    name = name,
    java_type = "java.lang.Boolean",
    db_type = "boolean"
  })
end

function Prop:datetime(name: string): Prop
  return Prop:new({
    name = name,
    java_type = "java.time.LocalDateTime",
    db_type = "timestamp(6)"
  })
end

function Prop:datetime_tz(name: string): Prop
  return Prop:new({
    name = name,
    java_type = "java.time.ZonedDateTime",
    db_type = "timestamp(6) with time zone"
  })
end

function Prop:json(name: string): Prop
  return Prop:new({
    name = name,
    java_type = "com.fasterxml.jackson.databind.JsonNode",
    db_type = "json"
  })
end

function Prop:jsonb(name: string): Prop
  return Prop:new({
    name = name,
    java_type = "com.fasterxml.jackson.databind.JsonNode",
    db_type = "jsonb"
  })
end

function Prop:with_column_definition(column_definition: string): Prop
  local this = self::PropImpl
  this.column_definition = column_definition
  return this
end

function Prop:with_user_type(user_type: string): Prop
  local this = self::PropImpl
  this.user_type = user_type
  return this
end

function Prop:with_lob(is_lob: boolean?): Prop
  local this = self::PropImpl
  this.is_lob = is_lob == nil or is_lob == true
  return self
end

function Prop:unwrap(): Unwrapped
  local this = self::PropImpl
  return {
    name = this.name,
    snake_name = this.name,
    camel_name = Case:snake_to_camel(this.name),
    pascal_name = Case:snake_to_pascal(this.name),
    updatable = this.updatable,
    java_type = this.java_type,
    db_type = this.db_type,
    column_definition = this.column_definition,
    user_type = this.user_type,
    is_lob = this.is_lob,
  }
end

return Prop