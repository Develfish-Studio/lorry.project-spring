local Meta = require('@develfish-repo.core/Meta')
local Wrapper = require('@develfish-repo.core/Wrapper')
local case = require('@develfish-repo.core/util/string/case')

export type Prop = Wrapper.Unwrappable<Unwrapped> & {
  __type: 'Prop',
  name: string,
  updatable: string?,
  java_type: string,
  db_type: string,
  column_definition: string,
  user_type: string?,
  is_lob: boolean?,

  with_column_definition: (self: Prop, column_definition: string) -> Prop,
  with_user_type: (self: Prop, user_type: string) -> Prop,
  with_lob: (self: Prop, is_lob: boolean) -> Prop,
}

export type Unwrapped = {
  name: string,
  snake_name: string,
  camel_name: string,
  pascal_name: string,
  updatable: string?,
  java_type: string,
  db_type: string,
  column_definition: string,
  user_type: string?,
  is_lob: boolean?,
}

local Prop = {
  __type = 'Prop',
  name = nil,
  updatable = nil,
  java_type = nil,
  db_type = nil,
  column_definition = nil,
  user_type = nil,
  is_lob = nil,
}

function Prop:new(o): Prop
  return Meta:type(o, self)
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

function Prop.with_column_definition(self: Prop, column_definition: string): Prop
  self.column_definition = column_definition
  return self
end

function Prop.with_user_type(self: Prop, user_type: string): Prop
  self.user_type = user_type
  return self
end

function Prop.with_lob(self: Prop, is_lob: boolean): Prop
  if is_lob == nil then
    is_lob = true
  end
  self.is_lob = is_lob
  return self
end

function Prop.unwrap(self: Prop): Unwrapped
  return {
    name = self.name,
    snake_name = self.name,
    camel_name = case.snakeToCamel(self.name),
    pascal_name = case.snakeToPascal(self.name),
    updatable = self.updatable,
    java_type = self.java_type,
    db_type = self.db_type,
    column_definition = self.column_definition,
    user_type = self.user_type,
    is_lob = self.is_lob,
  }
end

return Prop