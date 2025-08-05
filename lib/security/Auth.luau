local Meta = require('@develfish-repo.core/Meta')
local Wrapper = require('@develfish-repo.core/Wrapper')
local case = require('@develfish-repo.core/util/string/case')

export type Auth = Wrapper.Unwrappable<Unwrapped> & {
  __type: 'Auth',
  claim: string,
  name: string,
  column: string,
  java_type: string,

  with_claim: (self: Auth, claim: string) -> Auth,
  with_name: (self: Auth, name: string) -> Auth,
  with_column: (self: Auth, column: string) -> Auth,
  with_java_type: (self: Auth, java_type: string) -> Auth,

  unwrap_column: (self: Auth) -> UnwrappedColumn,
}

export type Unwrapped = {
  name: string,
  snake_name: string,
  camel_name: string,
  pascal_name: string,
  claim: string,
  java_type: string,
  column: UnwrappedColumn,
}

export type UnwrappedColumn = {
  name: string,
  snake_name: string,
  camel_name: string,
  pascal_name: string,
}

local Auth = {
  __type = 'Auth',
  claim = nil,
  name = nil,
  column = nil,
  java_type = 'java.lang.String',
}

function Auth:new(o): Auth
  return Meta:type(o, self)
end

function Auth:subject(name: string, column: string?): Auth
  return Auth:new({
    name = name,
    claim = 'sub',
    column = column or name,
    java_type = 'java.util.UUID',
  })
end

function Auth:string_claim(name: string, claim: string, column: string?): Auth
  return Auth:new({
    name = name,
    claim = claim,
    column = column or name,
    java_type = 'java.lang.String',
  })
end

function Auth.with_claim(self: Auth, claim: string): Auth
  self.claim = claim
  return self
end

function Auth.with_name(self: Auth, name: string): Auth
  self.name = name
  return self
end

function Auth.with_column(self: Auth, column: string): Auth
  self.column = column
  return self
end

function Auth.with_java_type(self: Auth, java_type: string): Auth
  self.java_type = java_type
  return self
end

function Auth.unwrap_column(self: Auth): UnwrappedColumn
  return {
    name = self.column,
    snake_name = self.column,
    camel_name = case.snakeToCamel(self.column),
    pascal_name = case.snakeToPascal(self.column),
  }
end

function Auth.unwrap(self: Auth): Unwrapped
  return {
    name = self.name,
    snake_name = self.name,
    camel_name = case.snakeToCamel(self.name),
    pascal_name = case.snakeToPascal(self.name),
    claim = self.claim,
    java_type = self.java_type,
    column = self:unwrap_column(),
  }
end

return Auth
