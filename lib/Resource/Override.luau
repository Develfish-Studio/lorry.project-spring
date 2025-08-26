--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')

local Override = {}

export type Override = typeof(Override) & Wrapper.Unwrappable<Unwrapped>

export type OverrideProps = {
  name: string,
  expression: string?,
  context_value: string?,
  value: string?,
  is_hidden: boolean,
}

export type Unwrapped = {
  name: string,
  value: string?,
  context_value: Wrapper.UnwrappedName?,
  expression: string?,
  is_hidden: boolean,
}

export type Data = {
  value: string?,
  expression: string?,
  context_value: string?,
  is_hidden: boolean,
}

export type UnwrappedContextValue = {
  name: string,
  snake_name: string,
  camel_name: string,
  pascal_name: string,
  kebab_name: string,
}

export type OverrideImpl = Override & OverrideProps

function Override:new(o: OverrideProps): Override
  return Meta:type(o, self, "Resource.Override")
end

function Override:from(name: string, options: Data): Override
  options = options or Meta:table({})
  return Override:new({
    name = name,
    expression = options.expression,
    context_value = options.context_value,
    value = options.value,
    is_hidden = options.is_hidden,
  })
end

function Override:from_context(name: string, context_value: string?): Override
  return Override:from(name, {
    is_hidden = true,
    context_value = context_value or name
  })
end

function Override:from_value(name: string, value: string): Override
  return Override:from(name, {
    is_hidden = true,
    value = value
  })
end

function Override:from_expression(name: string, expression: string): Override
  return Override:from(name, {
    is_hidden = true,
    expression = expression
  })
end

function Override:from_hidden(name: string): Override
  return Override:from(name, {
    is_hidden = true,
  })
end

function Override:with_expression(expression: string): Override
  local this = self::OverrideImpl
  this.expression = expression
  return this
end

function Override:with_context_value(context_value: string): Override
  local this = self::OverrideImpl
  this.context_value = context_value
  return this
end

function Override:with_value(value: string): Override
  local this = self::OverrideImpl
  this.value = value
  return this
end

function Override:with_hidden(is_hidden: boolean?): Override
  local this = self::OverrideImpl
  this.is_hidden = is_hidden == nil or is_hidden == true
  return this
end

function Override:unwrap(): Unwrapped
  local this = self::OverrideImpl
  return {
    name = this.name,
    value = this.value,
    context_value = Wrapper:unwrap_name_or_nil(this.context_value),
    expression = this.expression,
    is_hidden = this.is_hidden,
  }
end

return Override
