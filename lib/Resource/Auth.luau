--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Case = require('@develfish-repo.utils/lib/Case')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')

local Auth = {}

export type Auth = typeof(Auth) & Wrapper.Unwrappable<Unwrapped>

export type AuthProps = {
  claim: string,
  name: string,
  column: string,
  java_type: string,
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

export type AuthImpl = Auth & AuthProps

function Auth:new(o: AuthProps): Auth
  return Meta:type(o, self, "Resource.Auth")
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

function Auth:with_claim(claim: string): Auth
  local this = self::AuthImpl
  this.claim = claim
  return this
end

function Auth:with_name(name: string): Auth
  local this = self::AuthImpl
  this.name = name
  return this
end

function Auth:with_column(column: string): Auth
  local this = self::AuthImpl
  this.column = column
  return this
end

function Auth:with_java_type(java_type: string): Auth
  local this = self::AuthImpl
  this.java_type = java_type
  return this
end

function Auth:unwrap_column(): UnwrappedColumn
  local this = self::AuthImpl
  return {
    name = this.column,
    snake_name = this.column,
    camel_name = Case:snake_to_camel(this.column),
    pascal_name = Case:snake_to_pascal(this.column),
  }
end

function Auth:unwrap(): Unwrapped
  local this = self::AuthImpl
  return {
    name = this.name,
    snake_name = this.name,
    camel_name = Case:snake_to_camel(this.name),
    pascal_name = Case:snake_to_pascal(this.name),
    claim = this.claim,
    java_type = this.java_type,
    column = this:unwrap_column(),
  }
end

return Auth
