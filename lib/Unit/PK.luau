--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Case = require('@lorry.utils/lib/Case')
local Wrapper = require('@lorry.project/lib/Wrapper')

local PK = {}

export type PK = typeof(PK) & Wrapper.Unwrappable<Unwrapped>

export type PKProps = {
  name: string,
  java_type: string,
  is_composite: boolean,
}

export type Unwrapped = {
  name: string,
  snake_name: string,
  camel_name: string,
  pascal_name: string,
  java_type: string,
  is_composite: boolean,
}

export type PKImpl = PK & PKProps

function PK:new(o: PKProps): PK
  return Meta:type(o, self, "Unit.PK")
end

function PK:unwrap(): Unwrapped
  local this = self::PKImpl
  return {
    name = this.name,
    snake_name = this.name,
    camel_name = Case:snake_to_camel(this.name),
    pascal_name = Case:snake_to_pascal(this.name),
    java_type = this.java_type,
    is_composite = this.is_composite,
  }
end

return PK
